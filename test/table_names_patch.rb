require "active_record/fixtures.rb"

class Fixtures
	class << self
	attr_accessor	:original_create_fixtures
	end
end

Fixtures.original_create_fixtures = Fixtures.method(:create_fixtures)

def Fixtures.create_fixtures(path,table_names,class_names)
	# llamar al create fixtures original, pero filtrando los nombres de tabla ""
	if block_given?
		if table_names.instance_of? Array
			return original_create_fixtures.call(path,table_names.select{|t| t!=""},class_names) do |*x|
					yield(*x)
				end
		elsif table_names == true or table_names == false
			
		elsif table_names == nil
			return original_create_fixtures.call(path,[],class_names) do |*x|
					yield(*x)
				end
		else
			return original_create_fixtures.call(path,table_names,class_names) do |*x|
					yield(*x)
				end
		end
	else
		if table_names.instance_of? Array
			return original_create_fixtures.call(path,table_names.select{|t| t!=""},class_names)
		elsif table_names == true or table_names == false
			
		elsif table_names == nil
			return original_create_fixtures.call(path,[],class_names)
		else
			return original_create_fixtures.call(path,table_names,class_names)
		end
	end
end
