class DeleteTaskProgramsWithoutDelayedJobs < ActiveRecord::Migration
  def self.up
    task_programs =  TaskProgram.find(:all, :joins => "LEFT OUTER JOIN delayed_jobs on delayed_jobs.task_program_id = task_programs.id", :group => "task_programs.id having count(delayed_jobs.id) = 0")
    TaskProgram.destroy(task_programs.map(&:id))
  end

  def self.down
  end
end
