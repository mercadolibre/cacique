class AddSomeUserFunctions < ActiveRecord::Migration
  def self.up
	@user = User.find_by_login("cacique")
	@user = User.first if @user.nil?
	raise "Error: No se encontro 'cacique' ni ningun otro usuario para asociarle las funciones" if @user.nil?

	######### Funciones Initilize y Finalize ###########

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "initialize_run_script",
						:description => "Funcion que se ejecuta SIEMPRE antes de correr un script",
						:cant_args => 0,
						:source_code => "def new_object.initialize_run_script();
end;",
						:example => "initialize_run_script()")
	@user_function.save
	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "finalize_run_script",
						:description => "Funcion que se ejecuta SIEMPRE despues de correr un script",
						:cant_args => 0,
						:source_code => "def new_object.finalize_run_script();
end;",
						:example => "finalize_run_script()")
	@user_function.save
	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "error_run_script",
						:description => "Funcion que se ejecuta SIEMPRE que la corrida de un script da error",
						:cant_args => 0,
						:source_code => "def new_object.error_run_script();
end;",
						:example => "error_run_script()")
	@user_function.save


	############### returned_values ###########################
	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "remote_control_port",
						:description => "Retorna el puerto seteado en el panel de configuracion de corrida.",
						:cant_args => 0,
						:source_code => "def new_object.remote_control_port();
@remote_control_port || 4444
end;",
						:example => "port = remote_control_port()")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "remote_control_addr",
						:description => "Retorna la ip seteada en el panel de configuracion de corrida.",
						:cant_args => 0,
						:source_code => "def new_object.remote_control_addr();
@remote_control_addr || \"127.0.0.1\"
end;",
						:example => "ip = remote_control_addr()")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "select_popup",
						:description => "Espera que aparezca un popup y posiciona a selenium sobre el popup. En caso de no encontrarlo queda posicionado sobre la pagina principal.",
						:cant_args => 0,
						:source_code => "def new_object.select_popup();
selenium.wait_for_pop_up selenium.get_all_window_names[1], \"30000\"
selenium.select_window(selenium.get_all_window_names[1])
end;",
						:example => "selenium.click \"abro_pop_up\"
select_popup()")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "select_window_main",
						:description => "Posiciona a selenium en la pagina principal.",
						:cant_args => 0,
						:source_code => "def new_object.select_window_main();
selenium.select_window(selenium.get_all_window_names[0])
end;",
						:example => "select_window_main()")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "wait_for_element_present",
						:description => "Espera que aparezca un elemento de HTML en la pagina que se esta cargando en Selenium. En caso de pasar el tiempo maximo de espera y no encontrar el elemento retorna error. Recibe por parametro el elemento a esperar y el tiempo maximo de espera en segundos, por default son 60 seg.",
						:cant_args => 2,
						:source_code => "def new_object.wait_for_element_present( str_element, seconds=60 );
seconds.times{ break if (selenium.is_element_present(str_element) rescue false); sleep 1 }
raise \"Se espero al elemento \'\#\{str_element\}\' durante \#\{seconds\} y no aparecio\"
end;",
						:example => "selenium.click \"button\"
wait_for_element_present(\"login\")")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "wait_for_text_present",
						:description => "Espera que aparezca texto en el HTML en la pagina que se esta cargando en Selenium. En caso de pasar el tiempo maximo de espera y no encontrar el texto retorna error. Recibe por parametro el texto a esperar y el tiempo maximo de espera en segundos, por default son 60 seg.",
						:cant_args => 2,
						:source_code => "def new_object.wait_for_text_present( text, seconds=60 );
seconds.times{ break if (selenium.is_text_present(text) rescue false); sleep 1 }
raise \"Se espero al texto \'\#\{text\}\' durante \#\{seconds\} y no aparecio\"
end;",
						:example => "selenium.click \"button\"
wait_for_text_present(\"Felicidades, Te has registrado\")")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "selenium_stop",
						:description => "Se cierra el browser abierto.",
						:cant_args => 0,
						:source_code => "def new_object.selenium_stop();
@selenium.stop if @selenium
@selenium = nil
end;",
						:example => "selenium_stop()")
	@user_function.save


	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "selenium_init",
						:description => "Funcion que inicializa Selenium. Se encarga de abrir un browser en la configuracion seteada.",
						:cant_args => 1,
						:source_code => "def new_object.selenium_init( url );

	unless url.instance_of? String
		raise \"Direccion \#\{url.inspect\} invalida en selenium_init\"
	end

	if @selenium
		@selenium.stop
	end

      # verificar si existe un remote control de esa plataforma
	@selenium = Selenium::SeleniumDriver.new( remote_control_addr, remote_control_port , platform, url, 10000000000)
	@selenium.start
	@selenium_started = true
end;",
						:example => "selenium_init \"http://www.mercadolibre.com\"")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "selenium",
						:description => "Devuelve el controlador de selenium que se encuentre abierto. En caso de no estar abierto correctamente retorna un error con una leyenda.",
						:cant_args => 0,
						:source_code => "def new_object.selenium();
raise \"selenium_init no se llamo o se llamo incorrectamente\" unless @selenium
if self.debug_mode
	WrapperSelenium.new(FakeSeleniumLogger.new(@selenium,self), self)
else
	WrapperSelenium.new(@selenium,self)
end
end;",
						:example => "selenium")
	@user_function.save

	@user_function = UserFunction.new( 	:project_id => 0,
						:user_id => @user.id,
						:name => "selenium_html_snapshot",
						:description => "Saca una copia del HTML de la pagina en la cual se encuentra selenium posicionado y lo retorna.",
						:cant_args => 1,
						:source_code => "def new_object.selenium_html_snapshot( name = \"unnamed\" );
return unless @selenium_started

html_source = \"\"
if @selenium
begin
	html_source = @selenium.get_html_source()
	# preconcatenar a html_source la url base para mostrar bien el snapshot
	hpricot = Hpricot(html_source)
	elem = hpricot.at(\"base\")
	if elem
		unless elem.get_attribute :href
			html_source = \"<base href=\'\#\{@selenium.get_location\}\' />\\n\" + html_source
		end
	else
		html_source = \"<base href=\'\#\{@selenium.get_location\}\' />\\n\" + html_source
	end
rescue Exception => e
	html_source = \"<html> <title> \#\{CGI.escapeHTML(e.to_s)\} </title> </html>\"
end

snapshot = self.execution.execution_snapshots.new
snapshot.name = name
snapshot.content = html_source
snapshot.save

end
html_source
end;",
						:example => "selenium_html_snapshot(\"first_snapshot\")")
	@user_function.save
  end

  def self.down
  end
end
