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
//Only generated global variable to keep count of the new arguments are added
//So do not repeat ids of the inputs of arguments.
var cant_args_add = 0;

//Used to add parameters in the new, add an input to the table
  function add_argument(){
  		table = document.getElementById('arguments_table');

  		row = table.insertRow(table.rows.length);
  		row.id = 'row_' + table.rows.length;
  		cell = row.insertCell(0);
	    cell.innerHTML = '<input name=user_function[args][' + cant_args_add + '] id=user_function_args_' + cant_args_add + '>';
	    cell = row.insertCell(1);
	    
		elemento = document.createElement('img');
		elemento.name = 'row_' + table.rows.length;
  	    elemento.src = '/images/icons/cross.png';
  	    elemento.alt = 'cross.png';
  	    elemento.setAttribute('style', 'cursor:pointer; height:12px; width:12px; margin-left:10px;');
        elemento.onclick = function(){
            	   eliminarArgument(this.name);
        }
  	    cell.appendChild(elemento);
	    
  	    //Div that will contain the table
  	    div = document.getElementById('div_arguments_table');
  	    div.appendChild(table);
  	    
  	    cant_args_add += 1;
  }
  
  //Delete function Argument
  function eliminarArgument(row_id){
  	row = document.getElementById(row_id);
  	row.parentNode.removeChild(row);
  }

//Function to send the modified script
  function sendContent(){
    content = script_content.getValue();
    encoded_content = encode_text(content);
    params = "content=" + encodeURI(encoded_content) 
    document.getElementById('user_function_code').value=encoded_content
  }

function respond(xmlHttpRequest, responseHeader){
}

