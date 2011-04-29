class FillingRelationsFromProjectsAndScripts < ActiveRecord::Migration
  def self.up
    Circuit.all.each do |c|
      c.project_id=c.category.project_id
      c.save
    end
  end

  def self.down
     Circuit.all.each do |c|
       c.project_id=nil
       c.save
     end
  end
end
