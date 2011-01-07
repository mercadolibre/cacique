class AddContextConfigurations < ActiveRecord::Migration
  def self.up
	#Se crea la configuracion de platform
	platforms = ["IE7 on Windows","IE8 on Windows","Firefox3 on Windows","Firefox3.6 on Windows","Firefox on Ubuntu","Chrome on Windows"]
	@cc = ContextConfiguration.create({	:name => "platform",
						:view_type => "checkbox",
						:field_default => false,
						:values => platforms.join(";")})
	@cc.add_configuration_to_all_user
		
  end

  def self.down
  end
end
