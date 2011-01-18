class AddAnExampleInAllUserFunctions < ActiveRecord::Migration
  def self.up
	UserFunction.all.each do |user_function|
		user_function.example = "complete with an example"
		user_function.save
	end
  end

  def self.down
  end
end
