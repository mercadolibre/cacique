 #
 #  @Authors:    
 #      Brizuela Lucia                  lula.brizuela@gmail.com
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
class DataFile 

 def self.create(upload)
     #Create directory if not exist
     system "mkdir -p #{SHARED_DIRECTORY}/project_#{upload[:project_id]}" 
     directory = "#{SHARED_DIRECTORY}/project_#{upload[:project_id]}"
     #Create file path
     path = File.join(directory, upload[:name])
     #Verify if not exists
     if !FileTest.exists?(SHARED_DIRECTORY + "/project_#{upload[:project_id]}/#{upload[:name]}") 
        # Write file
        File.open(path, "wb") { |f| f.write(upload[:fileUpload]) }        
     else
        return false
     end
 end


 #Upload Selenium script
 def self.save(upload)

   text = upload[:fileUpload]
   #Verify class name (without spaces)
   if upload[:file_name].match(" ")
     #Se quita la extensión
       file_name_with_extension  = upload[:file_name].split(".")
       file_name = file_name_with_extension[0..file_name_with_extension.length-2]
     #Class
       class_name =  "class #{file_name} < Test::Unit::TestCase"
       valid_name =  "class test_cacique < Test::Unit::TestCase"
     #Method
       method_name  =  "def test_#{file_name}"
       valid_method =  "def test_cacique"
     #Reemplace
     text = upload[:fileUpload].gsub( class_name, valid_name).gsub( method_name , valid_method)
   end
   
   name = upload[:name]
   directory = "#{RAILS_ROOT}/lib/temp"
   # create the file path
   path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(text) }
    return true
 end

 def self.save_import(upload)
   name = upload[:name]
   directory = "#{RAILS_ROOT}/public"
   path = File.join(directory,name)

   File.open(path, "wb"){|f| f.write(upload[:fileUpload])}
   return true
 end

end
