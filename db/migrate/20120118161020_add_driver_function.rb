class AddDriverFunction < ActiveRecord::Migration
  def self.up

    UserFunction.reset_column_information
    @user = User.find_by_login("cacique")
	  @user = User.first if @user.nil?
	  raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?

  	@user_function = UserFunction.new( 	
  	          :project_id => 0,
  						:user_id => @user.id,
  						:name => "driver",
  						:description => "Returns the open controller of webdriver.",
  						:cant_args => 0,
  						:source_code => "def new_object.driver();raise \"webdriver_init not called or was called incorrectly\" unless @driver\nWebdriverLogger.new(@driver,self)\n \n end;",
  						:example => "driver",
              :hide=> true, 
              :visibility=> true,
              :native_params=> true)
    raise "Error: No es posible crear la función driver\n" + @user_function.errors.full_messages.join("\n") if !@user_function.save
  end

  def self.down
  end
end
