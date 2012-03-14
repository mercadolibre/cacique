class FillingSuitesOnTaskProgramFromDelayedJobs < ActiveRecord::Migration
  def self.up
    task_programs = TaskProgram.all
    task_programs.each do |task_program|
      #Suite                                       
      task_program.suites << Suite.find(task_program.suite_id)
      task_program.save
    end
  end

  def self.down
  end
end
