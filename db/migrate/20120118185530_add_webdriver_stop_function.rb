class AddWebdriverStopFunction < ActiveRecord::Migration
  def self.up
    UserFunction.reset_column_information
    @user = User.find_by_login("cacique")
	  @user = User.first if @user.nil?
	  raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?
  	@user_function = UserFunction.new( 	
  	        :project_id => 0,
  				  :user_id => @user.id,
  				  :name => "webdriver_stop",
  				  :description => "Close the browser open.",
  				  :cant_args => 1,
  			    :source_code => "def new_object.webdriver_stop();@driver.close if @driver\n@driver = nil\n end;",
  			    :example => "webdriver_stop",
            :hide=> true, 
            :visibility=> true,
            :native_params=> true)
    raise "Error: No es posible crear la función webdriver_stop\n" + @user_function.errors.full_messages.join("\n") if !@user_function.save

  end

  def self.down
  end
end
