class FillingNilProjectwIdOnCircuit < ActiveRecord::Migration
   def self.up
       Circuit.all_by_project_id(nil).each do |c|
       c.project_id=c.category.project_id
       c.save
     end
   end

  end

  def self.down
  end
end
