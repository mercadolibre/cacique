class SeleniumInitFix < ActiveRecord::Migration
  def self.up
	@user = User.find_by_login("cacique")
	@user = User.first if @user.nil?
	raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?

@user_function = UserFunction.find_by_name('selenium_init')
        
        @user_function.source_code = "def new_object.selenium_init( url );

	unless url.instance_of? String
		raise \"Direccion \#\{url.inspect\} invalida en selenium_init\"
	end

	if @selenium
		@selenium.stop
	end

      # verificar si existe un remote control de esa plataforma
	@selenium = Selenium::SeleniumDriver.new( remote_control_addr, remote_control_port , platform, url, 50000)
	@selenium.start
	@selenium_started = true
end;"

	@user_function.save

  end

  def self.down
  end
end





