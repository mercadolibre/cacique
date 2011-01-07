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
/*Javascript que se utiliza para seleccionar todos los checkbox de un formulario,
en index, case_template*/  

function listItems(circuit_id,form){
  if (document.getElementById('todos_'+circuit_id).checked){
  	for (i=0;i<form.elements.length;i++) {
  		if (form.elements[i].type == "checkbox" && form.elements[i].id == ("case_"+circuit_id)){	
  			form.elements[i].checked=true;
  		}
  	}
  }
  else{
  	for (i=0;i<form.elements.length;i++) {
  		if (form.elements[i].type == "checkbox" && form.elements[i].id == ("case_"+circuit_id)){
  			form.elements[i].checked=false;
  		}
  	}
  }
}
