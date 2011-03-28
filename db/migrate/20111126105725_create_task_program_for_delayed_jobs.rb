class CreateTaskProgramForDelayedJobs < ActiveRecord::Migration
  def self.up
      #For existing Delayed jobs
      if DelayedJob.all.count > 0
         user = User.find_by_login("cacique")
         if user.nil?
	     user = User.first
	     raise "Error: No active user was found to assign the scheduled" if user.nil?
             puts  "User not found Cacique, previously scheduled tasks will be assigned to the user #{user.name}"
         end
         user_id = user.id  

	 DelayedJob.all.each do |delayed_job|
             if !delayed_job.suite_id.nil? and Suite.exists?(delayed_job.suite_id)
               project_id   = Suite.find(delayed_job.suite_id).project_id
               task_program = TaskProgram.create({:user_id => user_id, :suite_execution_ids => nil, :suite_id => delayed_job.suite_id, :project_id=>project_id})
               delayed_job.task_program_id = task_program.id
	       delayed_job.save
             else
               delayed_job.delete  
             end
	 end
      end
  end

  def self.down
  end
end
