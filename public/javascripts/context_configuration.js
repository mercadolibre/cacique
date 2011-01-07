 /*
 *  @Authors:    
 *      Brizuela Lucia                  lula.brizuela@gmail.com
 *      Guerra Brenda                   brenda.guerra.7@gmail.com
 *      Crosa Fernando                  fernandocrosa@hotmail.com
 *      Branciforte Horacio             horaciob@gmail.com
 *      Luna Juan                       juancluna@gmail.com
 *      
 *  @copyright (C) 2010 MercadoLibre S.R.L
 *
 *
 *  @license        GNU/GPL, see license.txt
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */
  //Generate Values by Select option
  function changeValuesView(indice){
  	value = document.getElementById('context_configuration_view_type').options[indice].value;
  	//Generate View by option
  	switch ( value ){ 
	     case 'checkbox': 	{document.getElementById('multiple_values').style.display='block';
	     	                 document.getElementById('context_configuration_field_default').checked = false;
	                         document.getElementById('default_value').style.display='block';
	     					 document.getElementById('one_value').style.display='none';}
			                    break;
		 case 'radiobutton':{document.getElementById('multiple_values').style.display='block';
		 	                 document.getElementById('context_configuration_field_default').checked = false;
	                         document.getElementById('default_value').style.display='block';
		 					 document.getElementById('one_value').style.display='none';}
			                    break;
		 case 'select': 	{document.getElementById('multiple_values').style.display='block';
		 		 	         document.getElementById('context_configuration_field_default').checked = false;
	                         document.getElementById('default_value').style.display='block';
		 					 document.getElementById('one_value').style.display='none';}
			                    break;
		 case 'input': 		{document.getElementById('one_value').style.display='block';
		 		 	         document.getElementById('context_configuration_field_default').checked = false;
		 		 	         document.getElementById('default_value').style.display='none';
		 					 document.getElementById('multiple_values').style.display='none';}
		 						break;
		 case 'boolean': 	{document.getElementById('one_value').style.display='block';
		 		 	         document.getElementById('context_configuration_field_default').checked = false;
		 		 	         document.getElementById('default_value').style.display='none';
		 					 document.getElementById('multiple_values').style.display='none';}
		 						break;
   }
  }
  
  //Add an input
  function addOption(){
  	table = document.getElementById('multiple_values');

  	row = table.insertRow(table.rows.length);
  	cell = row.insertCell(0);
	cell.innerHTML = '<input name=values[value' + table.rows.length + '] id=values_value' + table.rows.length + ' size=30 >';
	cell = row.insertCell(1);
	cell.innerHTML = '';
	
  }
  
  //Delete File from Values Table
  function eliminarValue(row_id){
  	row = document.getElementById(row_id);
  	row.parentNode.removeChild(row);
  }
  
  //Get all Old Elements
  function addOldValuesAndSubmit(){
  	table = document.getElementById('table_old_values');
  	values = "";
  	for(i=0;i<table.rows.length;i++) {
  		values += table.rows[i].cells[0].childNodes[2].data.strip();
  	    if((i+1) != table.rows.length){
  	      values +=";";
  	    }
  	}

  	input = document.getElementById('old_values_');
  	input.value = values;
  
  	form = document.getElementById('save_context_configuration');
    form.submit(); 
  }
