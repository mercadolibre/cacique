class AddWebdriverUserFunctions < ActiveRecord::Migration
  def self.up
    UserFunction.reset_column_information
    @user = User.find_by_login("cacique")
	  @user = User.first if @user.nil?
	  raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?

  	@user_function = UserFunction.new( 	:project_id => 0,
  						:user_id => @user.id,
  						:name => "webdriver_init",
  						:description => "Función para comenzar utilizar el nodo de WD",
  						:cant_args => 1,
  						:source_code => "def new_object.webdriver_init(iii);#------------------------------------------------------------------------------------------------------\n#Librerias\n#------------------------------------------------------------------------------------------------------\nrequire \"rubygems\"\nrequire \"selenium/client\"\nrequire \"selenium-webdriver\"\n\n#brows=brows.downcase\n\n#urlhub = \"http://10.4.255.99:5555/wd/hub\"\n\n     case platform\n       when \"Firefox3.6 on Windows\"\n         brows = \"firefox\"\n         vrsn = \"3.6\"\n       when \"IE7 on Windows\"\n         brows = \"iexplore\"\n         vrsn = \"7\"\n       when \"IE8 on Windows\"\n         brows = \"iexplore\"\n         vrsn = \"8\"\n       when \"Chrome on Windows\"\n         brows = \"googlechrome\"\n         vrsn = \"\"\n     end\n\n\n#------------------------------------------------------------------------------------------------------\n#Creacion de Capabilities\n#------------------------------------------------------------------------------------------------------\n\n\tif brows.match(/ie/) or brows.match(/explorer/) or brows.match(/iexplore/) or brows.match(\"internet explorer\")\n        caps = Selenium::WebDriver::Remote::Capabilities.ie(:javascript_enabled => true)\n\telsif brows.match(/chrome/) or brows.match(\"googlechrome\")\n        caps = Selenium::WebDriver::Remote::Capabilities.chrome(:javascript_enabled => true)\n\telsif brows.match(/firefox/)\n\tcaps = Selenium::WebDriver::Remote::Capabilities.firefox(:javascript_enabled => true)\n\telsif brows.match(/htmlunit/)\n\tcaps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)\n\tend\n\n\nif (remote_control_addr == HUB_IP )\n#------------------------------------------------------------------------------------------------------\n#Ejecución automática\n#------------------------------------------------------------------------------------------------------\n\turlhub = \"http://10.4.255.99:5555/wd/hub\"\nelse\n#------------------------------------------------------------------------------------------------------\n#Ejecución Cacique en mi PC\n#------------------------------------------------------------------------------------------------------\n\turlhub = \"http://\#{remote_control_addr}:\#{remote_control_port}/wd/hub\"\nend\n\n\n@webdriver = Selenium::WebDriver.for :remote,:url => urlhub , :desired_capabilities => caps\n@webdriver.navigate.to url\n \n \n@driver = @webdriver\n  \n end;",
  						:example => "webdriver_init(\"http://www.mercadolibre.com\", \"IE9 on Windows\")",
              :hide=> true, 
              :visibility=> true,
              :native_params=> true)

    raise "Error: No es posible crear la función webdriver_init\n" + @user_function.errors.full_messages.join("\n") if !@user_function.save

  end

  def self.down
  end
end
