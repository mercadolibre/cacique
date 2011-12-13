 #
 #  @Authors:    
 #      Guerra Brenda                   brenda.guerra.7@gmail.com
 #      Crosa Fernando                  fernandocrosa@hotmail.com
 #      Branciforte Horacio             horaciob@gmail.com
 #      Luna Juan                       juancluna@gmail.com
 #      
 #  @copyright (C) 2010 MercadoLibre S.R.L
 #
 #
 #  @license        GNU/GPL, see license.txt
 #  This program is free software: you can redistribute it and/or modify
 #  it under the terms of the GNU General Public License as published by
 #  the Free Software Foundation, either version 3 of the License, or
 #  (at your option) any later version.
 #
 #  This program is distributed in the hope that it will be useful,
 #  but WITHOUT ANY WARRANTY; without even the implied warranty of
 #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #  GNU General Public License for more details.
 #
 #  You should have received a copy of the GNU General Public License
 #  along with this program.  If not, see http://www.gnu.org/licenses/.
 #

#####################################################################################################
  Steps to create a new Parser:
#####################################################################################################

1 - Generate a model with the new parser in the folder lib/parsers.
     This model should have two methods:
     A) data_collector
     B) generate_script

     A- data_collector (content) => Returns an Array with candidate values ​​as variables in the file
     B- generate_script (content, data) => Returns an String containing the script code

     Parameters:
     content: File content
     data: data selected variables in the format: {column name => value}, example: {color => red}
     used to replace the variables (values) for "data[:column name]"

2 - In the model Parser  found in app/models, you must add the following:
     * Add the start up required the generated file in 1
     * Add the new parser to the variable @parsers that contains the parser available as follows:
       Class Name => regular extresion
       The regular expression is used to identify which files should be treated with the new parser.

3 - Functions:
     If necessary, create a migration that generates those functions used by the new parser.
     Por ejemplo, el parser de Selenium al generar el script para Cacique agrega la función selenium_init al principio del script; esta función se encuentra agregada en una migración para que la función pueda ser utilizada a la hora de la ejecución.
    For example, Selenium parser adds the function selenium_init to Cacique at the beginning of the script when generating it, this function is added in a migration so the function could be used at runtime.
     Example:
      user_function = UserFunction.new ( :project_id => project function (0: general),
                                         :user_id => owner function,
                                         :name => "selenium_init"
                                         :description => description,
                                         :cant_args => number of arguments,
                                         :source_code => "def new_object.selenium ();
                                                              [function code]
                                                          end; "
                                         :example => example of use)
      user_function.save

#####################################################################################################
  Pasos para crear un nuevo Parser:
#####################################################################################################

1 - Generar un modelo con el nuevo parseador dentro de la carpeta lib/parsers.
    Este modelo debera tener dos métodos principales:
    A) data_collector
    B) generate_script

    A- data_collector(content)       => Retorna un Array con las variables candidatas
    B- generate_script(content,data) => Retorna un String con el código que contendrá el script

    Parámetros:
    content : contenido del archivo
    data    : datos seleccionados como variables, con el formato: {nombre de columna=> valor}, ej: {color=>red}
    utilizado para reemplazar las variables (valores) por "data[:nombre de columna]"

2 - En el modelo Parser que se encuentra en app/models, se deben agregar lo siguiente:
    * Agregar al inicio el require del archivo generado en el punto 1
    * Agregar el nuevo parser a la variable @parsers que contiene los parser disponibles, de la siguiente manera:
      Nombre de la clase => extresion regular 
      La expresion regular se utilizará para identificar que archivos deberan tratarse con el nuevo parser.

3 - Funciones:
    Si fuera necesario, crear una migración que genere aquellas funciones utilizadas por el nuevo parser.
    Por ejemplo, el parser de Selenium al generar el script para Cacique agrega la función selenium_init al principio del script; esta función se encuentra agregada en una migración para que la función pueda ser utilizada a la hora de la ejecución.
    Ejemplo:
	   user_function = UserFunction.new( 	:project_id => proyecto al que pertenece la función (0:general),
						                            :user_id => usuario al que pertenece la función,
						                            :name => "selenium_init",
					                              :description => descripción,
						                            :cant_args => cantidad de argumentos,
						                            :source_code => "def new_object.selenium();
                                                             [código de la función]
                                                          end;",
						                              :example => ejemplo de uso)
	  user_function.save

