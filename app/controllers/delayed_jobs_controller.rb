 #
 #  @Authors:    
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


class DelayedJobsController < ApplicationController

   def index
    Suite    

    @projects     = Project.all
    @users        = User.all   
    @project_id   = params[:project_id] = (params[:filter] && params[:filter][:project_id])? params[:filter][:project_id].to_i : params[:project_id].to_i

    #Suites
    suites_ids = Rails.cache.fetch("project_suites_#{@project_id}"){Project.find(@project_id).suite_ids}
    @suites    = Suite.find(suites_ids)  

    #Dates
    params[:init_date]=(params[:filter] && params[:filter][:init_date]) ? DateTime.strptime(params[:filter][:init_date], "%d.%m.%Y %H:%M"): 
DateTime.now.in_time_zone
    params[:finish_date]= params[:filter] && params[:filter][:finish_date]? DateTime.strptime(params[:filter][:finish_date], "%d.%m.%Y %H:%M") : DateTime.now.in_time_zone + (1*24*60*60) #1 day after    
    @weekly_trans = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}
    
    #DelayedJobs
    @task_programs = DelayedJob.filter(params)

   end

   #Removes a collection of Delayed Jobs
   def destroy
    if params[:id]
      delayed_job = DelayedJob.find params[:id] 
      delayed_job.destroy if current_user.has_role?("root") or delayed_job.task_program.user_id == current_user.id
    end
    redirect_to url_for( :controller=>:delayed_jobs, :action=>:index, :filter=>params[:filter])
   end

  def get_list
      #Scheduled suites are obtained
      task_programs = TaskProgram.find(:all, :conditions =>["project_id = ? and user_id = ?",params[:project_id],current_user.id])
      suite_ids=[]
      task_programs.each{|t| suite_ids += t.suite_ids}
      suite_ids.uniq!
      suites = Suite.find(suite_ids)
      render :partial => "list" , :locals=>{:suites=>suites}  
  end

  def get_detail_list
        #Get all task program for the suite
        task_programs = Suite.find(params[:program][:suite_id]).task_programs
        task_program_info = Hash.new
        task_programs.each do |tp|
          #Get name of suite and the next expiration
          next_expiration = tp.delayed_jobs.find_by_status 0
          task_program_info[tp.id] = next_expiration if next_expiration
        end
      render :partial => "detail" , :locals=>{:task_program_info=>task_program_info}          
  end

  def confirm_program
    @task_program  = TaskProgram.find params[:id]
    @confirm       = params[:confirm]? params[:confirm] : false
    @delayed_jobs  = @task_program.delayed_jobs.paginate :page => params[:page], :per_page => 14, :order => 'run_at ASC'
    @weekly_trans  = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}    
  end

  def save_confirm_program
    @task_program = TaskProgram.find params[:id]
    #Schedules are confirmed as of today up to one month 
    @task_program.confirm_delayed_jobs_until(DateTime.now >> 1)
    redirect_to :action => :confirm_program, :id => @task_program.id, :confirm => true
  end

  def show
    task_program = TaskProgram.find( params[:id].to_i)
    delayed_jobs = DelayedJob.build_structure(task_program)
    weekly_trans = {"Sunday"=>_("Sunday"),"Monday"=>_("Monday"),"Tuesday"=>_("Tuesday"),"Wednesday"=>_("Wednesday"),"Thursday"=>_("Thursday"),"Friday"=>_("Friday"),"Saturday"=>_("Saturday")}
    render :partial => "show" , :locals=>{:delayed_jobs=>delayed_jobs, :weekly_trans=>weekly_trans}   
  end
  
end
