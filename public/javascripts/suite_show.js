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
function showDiv(div_show){
     $j(".div_show").hide();
     $j('#' + div_show).show();               
     //Mark the button
     $j("div[name='button_only']").attr( 'class', 'default_button');
     $j('#button_' + div_show.split('_')[1]).attr( 'class', 'selected_button');                                              
}


//shows all cases selected with the primary circuit
//(circuit_pcipal, circuit_select, select_type)  = (Script to see their relationships, script clicked, if the parent or child is clicked)
 function showCases(div) {
   //They hide all the divs of the circuits
   $j('.div_circuit_cases').hide();
   //It shows only the selected
   $j('#' + div).show();   
  }

//Divs function that activates the circuit selected in the select
function showCircuit(){
   circuit_selected = $j('#select_circuits').val();
   //Hide all Divs
   $j('.div_relations').hide();
   //Hide All
   $j('.div_circuit_cases').hide();
   //Show only selected
   $j('#div_circuit' + circuit_selected).show();   
}








