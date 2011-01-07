class AddFirstUser < ActiveRecord::Migration
  def self.up
	@user = User.create({	:login => "cacique",
				:name => "Cacique Generico",
				:email => "cambiar_mail@delogueo.com",
				:password => "admin",
				:password_confirmation => "admin"})
	@user.has_role("root")
	@user.save
  end

  def self.down
	@user = User.find_by_login("cacique")
	@user.destroy
  end
end
