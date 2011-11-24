class ChangingEngineTables < ActiveRecord::Migration
  def self.up
  	ActiveRecord::Migration::say 'Setting all tables to InnoDB engine'
    	result = ActiveRecord::Migration::execute 'show tables'
    	while table = result.fetch_row
      		execute("ALTER TABLE #{table.to_s} TYPE = InnoDB") unless table.to_s == 'schema_info'
    	end
  end

  def self.down
 	raise ActiveRecord::IrreversibleMigration  
  end
end
