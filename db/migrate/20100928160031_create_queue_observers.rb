class CreateQueueObservers < ActiveRecord::Migration
  def self.up
    create_table :queue_observers do |t|
       t.column :values, :string, :limit => 600
      t.timestamps
    end
  end

  def self.down
    drop_table :queue_observers
  end
end
