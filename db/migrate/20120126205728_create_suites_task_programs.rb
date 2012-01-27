class CreateSuitesTaskPrograms < ActiveRecord::Migration
  def self.up
    create_table :suites_task_programs, :id=>false do |t|
	  t.integer  "task_program_id"
	  t.integer  "suite_id"
    end
  end

  def self.down
    drop_table :suites_task_programs
  end
end
