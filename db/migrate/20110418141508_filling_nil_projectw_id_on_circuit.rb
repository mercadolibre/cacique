class FillingNilProjectwIdOnCircuit < ActiveRecord::Migration
   def self.up
       Circuit.find_all_by_project_id(nil).each do |c|
       c.project_id=c.category.project_id
       c.save
     end
   end

  end

  def self.down
  end
