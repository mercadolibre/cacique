
# Schema version: 20110630143837
#
# Table name: queue_observers
#
#  id         :integer(4)      not null, primary key
#  values     :string(600)
#  created_at :datetime
#  updated_at :datetime
#

 #
 #  @Authors:    
 #      Brizuela Lucia                  lula.brizuela@gmail.com
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #      
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #
require "socket"

class QueueObserver < ActiveRecord::Base
    #send a signal to refresh workers on cache
    def self.refresh_workers
      Rails.cache.read("registred_workers").keys.each do |ip|
      begin
        cn = TCPSocket::new( ip,33133)
        cn.print "refresh"
        cn.close
        rescue Errno::ECONNREFUSED
          hash=Rails.cache.read "registred_workers"
          hash.delete(ip)
          Rails.cache.write "registred_workers", hash
      end
      
      end
    end

    def after_initialize
        begin
         @connection=Starling.new("#{IP_QUEUE}:#{PORT_QUEUE}")
        rescue
         puts "Conection Error"
        end
    end

   #it will return all running task
   def get_running_info
      SuiteExecution
      Execution
      Circuit
      Suite
      DataRecoveryName
      ExecutionConfigurationValue
      task_running={}
      workers_hash=Rails.cache.read("registred_workers")
      if workers_hash
        workers_hash.each do |ip,pids|
          pids.each do |pid|
             task=Rails.cache.read "worker_#{ip}_#{pid}"
             if (!task.instance_of? String) && (task != nil)
               #Not Dry!!! this need refactoring, should be the same as queue
               task_value={}
               task_value[:circuit]=task.circuit.name 
               task_value[:user_name]=task.user.login
               task_value[:project]=task.suite_execution.project.name
               task_value[:suite_execution_id]= task.suite_execution_id
               if task.suite_execution.suite.nil?
                 task_value[:suite]="" 
               else
                 task_value[:suite]=task.suite_execution.suite.name
               end
             task_running["#{ip}_#{pid}"]=task_value
             else
               task_running["#{ip}_#{pid}"]="Empty"
             end
          end
      end
      task_running
      else
        task_value={}
        task_value[:circuit]="No hay workers disponibles" 
        task_value[:user_name]=""
        task_value[:project]=""
        task_value[:suite_execution_id]=""
        task_value[:suite]=""
      end
    end


    def get_values
        info=QueueObserver.run
        self.values=""      
        info.each_pair {|u,v| self.values << "#{u}=#{v};"}
    end

    def read_values
       arr=self.values.split ";"
       info=Hash.new
       arr.each  do |value| 
           aux=value.split("=")
           info[aux[0].to_sym]=aux[1].to_s
       end
       info      
    end

    def self.run
        begin 
         @conection=Starling.new("#{IP_QUEUE}:#{PORT_QUEUE}")
          info=@conection.sizeof(:all)
          info[:total_queued_task]=info.values.sum
        rescue 
          info={:error => _("Conection Error")}
        end
        info
    end

    #Delete all queued task from a queue
    def clear_queue(queue)
      @connection.flush(queue)    
    end

    #it will return user friendly information about tasks in all queues
    def  get_named_tasks
      tasks=self.get_raw_tasks
      named_tasks=Hash.new
      tasks.each do |queue_name, task_collection|
      task_info=Array.new
      tasks[queue_name].each do |task|
        task_values=Hash.new
        if task[:suite_execution_id]
         suite_exe=SuiteExecution.find task[:suite_execution_id].to_i
        elsif task[:execution_id]
         #if it a reexecution
         suite_exe=Execution.find(task[:execution_id].to_i).suite_execution 
        else
         suite_exe=tasks[:execution_workers__run_n_times].first[:suite_executions].first
        end
        #TODO aca tengo que ver que onda cuando es unitaria
        task_values[:suite_execution_id]=suite_exe.id
        task_values[:username]=suite_exe.user.login
        task_values[:project]=suite_exe.project.name
        #task_name will be suite's name or circuit's name
        unless suite_exe.suite.nil?
          task_values[:task_name]=suite_exe.suite.name 
        else
          task_values[:task_name]=suite_exe.executions.first.circuit.name
        end
        #task_values[:circuit]=Execution.find().circuit.name
        task_info << task_values
      end
      named_tasks[queue_name]=task_info
      end
      named_tasks
    end
    #pull all queued task, store them and refill queue, and return a hash filled with all task and arguments
    def get_raw_tasks
      tasks=self.get_queued_data
      self.refill_queued_data(tasks)
      tasks
    end
    #deletes an execution form a queue
    def delete_execution(id)
      tasks=self.get_queued_data
      @connection.available_queues.each do |queue|
      	tasks[queue.to_sym].delete_if  do |task| 
          task[:suite_execution_id].to_i == id.to_i
        end
      end
      self.refill_queued_data(tasks)
      SuiteExecution.cancel id.to_i
    end

    #pull all task 
    def get_queued_data
      ExecutionConfigurationValue
      SuiteExecution
      tasks=Hash.new
      #tasks will be formed by the queue's name as key and all his task will be his values
      #task will be filled as a LIFO (stack) and then will be reverted to wokr as FIFO (queue)
      @connection.available_queues.each do |queue|
        stack=Array.new
        task=0
        #geting task values
        while task != nil
            task = @connection.fetch(queue)
            stack.push task unless task.nil?
        end
        #stack.reverse!
        tasks[queue.to_sym]=stack
      end
      #refilling starling queue
      tasks
    end
    #refill all task on a hash 
    def refill_queued_data(tasks)
     @connection.available_queues.each do |queue|
        unless tasks[queue.to_sym].nil?
          tasks[queue.to_sym].each do |t|
           @connection.set(queue.to_s,t)
          end
        end
      end
    end

end
