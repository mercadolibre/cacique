class CreateTaskPrograms < ActiveRecord::Migration
  def self.up
    	create_table  :task_programs do |t|
      		t.integer :user_id
      		t.text    :suite_execution_ids
      		t.integer :suite_id
      		t.integer :project_id      		
      		t.timestamps
    	end
	add_column :delayed_jobs, :task_program_id, :integer
  end

  def self.down
    	drop_table :task_programs
	remove_column :delayed_jobs, :task_program_id
  end
end
