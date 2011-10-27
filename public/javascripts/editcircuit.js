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
//Function that checks the entered text to enter a function
function buscar_argumentos(){
    text = '';  //Function arguments

    //You get the selected option of select
     div = document.getElementById('functions').value;
    //If different from "-Select-"
    if (div != '-Select-'){
      //You get the arguments of the function selected
      arguments = document.getElementsByName(div);
      for(i=0;i<arguments.length;i++){
         if(arguments[i].style.display != 'none' ){
			if( arguments[i].value != ''){
	        	text += arguments[i].value + ',';
			}     
         }
      } 
      armado_funcion(text);
    }
}

//Function to arming the text to be inserted
  function armado_funcion( arguments ) {
    //You get the selected option of select
    div = document.getElementById('functions').value;

    //The text is assembled according to the corresponding function
    cantRows = 0;
    text_function = '';
    //Function + arguments
       //If the function has arguments
       if (arguments != false){
         //It will remove the last "," to the arguments, if arguments ==''=> function without arguments
         arguments = arguments.substring(0,arguments.length - 1);
       }
      text_function = div + '(' + arguments + ')';

   //Adding new function text
   insertarTexto(text_function);

   //Hides the div to add row
   document.getElementById('div_with_functions').toggle();

}

//-------------------------- ADD FUNCTIONS -----------------------//

  function insertarTexto(text) { 
    actual_pos= script_content.getCursor();
    script_content.replaceRange(text, actual_pos);
  }

//Function to activate the hidden div selected in the SELECT
  function activarDiv(id) {
    //Se ocultan los demas divs
    desactivarDivs();
    //Se activa solo el seleccionado
    if (id != '-Select-'){
      div = document.getElementById(id);
      div.style.display = "";
    }
  }

//Function to disable the hidden div selected in the select
  function desactivarDivs() {
    divs = document.getElementsByName('div_function');
    for(n=0; n < divs.length; n++){
      divs[n].style.display='none';
    }
  }

//Function to show or hide the select input in FUNCTIONS
  function changeFunctionsInput(div, arg){
  input= document.getElementById(div + '_input_'+ arg).style.display;
  if (input == 'none'){
    document.getElementById(div + '_select_'+ arg).style.display='none';
    document.getElementById(div + '_input_'+ arg).style.display = 'block';
    }else{
    document.getElementById(div + '_select_'+ arg).style.display='block';
    document.getElementById(div + '_input_'+ arg).style.display ='none';
  }
}



//-------------------------- SEND CHANGES -------------------------//
//Function to send the name and description of the circuit
function sendCircuitUpdate(){
  c_name        = document.getElementById('circuit_name').value;
  c_description = document.getElementById('circuit_description').value;
  if(c_name == '' || c_description == '')alert('Debe completar los campos');
  else {
         document.getElementById('form_edit_circuit').submit();
         document.getElementById('update_circuit').style.display = 'none';
       }
}

//--------------------------- DATA RECOVERY --------------------------------//

//Function to show or hide the select input in DATA_RECOVERIES
  function changeInput(){   
      if (document.getElementById('data_recovery_name_code').style.display == 'none'){
          document.getElementById('data_recovery_name_code').style.display = 'block';   
          document.getElementById('data_recovery_name_code_2').style.display = 'none';  
      } else {
          document.getElementById('data_recovery_name_code').style.display = 'none';   
          document.getElementById('data_recovery_name_code_2').style.display = 'block';  
      }
}





