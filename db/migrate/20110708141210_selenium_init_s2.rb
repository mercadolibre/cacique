class SeleniumInitS2 < ActiveRecord::Migration
  def self.up
	@user = User.find_by_login("cacique")
	@user = User.first if @user.nil?
	raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?

@user_function = UserFunction.find_by_name('selenium_init')
        
        @user_function.source_code = 'def new_object.selenium_init( url );

require "rubygems"
require "selenium/client"

	unless url.instance_of? String
		raise "Direccion #{url.inspect} invalida en selenium_init"
	end

	if @selenium
		@selenium.stop
	end

      # verificar si existe un remote control de esa plataforma
#	@selenium = Selenium::SeleniumDriver.new( remote_control_addr, remote_control_port , platform, url, 50000)


case platform
when "Firefox3.6 on Win..."
 broWser = "*firefox"
when "IE7 on Windows"
 broWser = "iexplorer"
when "IE8 on Windows"
 broWser = "*iexplore"
when "Chrome on Windows"
 broWser = "*googlechrome"
end

puts broWser



        @selenium = Selenium::Client::Driver.new \
		:host => remote_control_addr, 
		:port => remote_control_port, 
		:browser => broWser, 
		:url => url, 
		:timeout_in_second => 50

	@selenium.start_new_browser_session
	@selenium_started = true
end;'

  end

  def self.down
  end
end
