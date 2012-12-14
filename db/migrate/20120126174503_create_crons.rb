class CreateCrons < ActiveRecord::Migration
  def self.up
    create_table :crons do |t|
      t.integer  "task_program_id"     
      t.string   "min", :limit => 50
      t.string   "hour", :limit => 50
      t.string   "day_of_month", :limit => 50
      t.string   "month", :limit => 50
      t.string   "day_of_week", :limit => 50
      t.timestamps
    end
  end

  def self.down
    drop_table :crons
  end
end
