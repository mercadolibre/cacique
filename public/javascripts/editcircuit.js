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
    codepress_content_free.editor.insertCode(text);
    //Add *
    if(add_asterisk){
    	document.getElementById('modified_file').innerHTML = "<image src='/images/icons/s-edit.png'></img>";
    	document.getElementById('save_button').style.visibility = "visible"; 
	document.getElementById('savewc_button').style.visibility = "visible"; 
	add_asterisk = false;

    }
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

//Function to show or hide the select input in DATA_RECOVERIES
  function changeInput(){
  visual = document.getElementById('return_2'  ).style.display;
  if (visual == 'none'){
    document.getElementById('return_3').style.display='none';
    document.getElementById('return_2' ).style.display = 'block';
    }else{
    document.getElementById('return_3' ).style.display = 'block';
    document.getElementById('return_2').style.display='none';
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

//Function to validate the data entered in data recoveries
  function checkNewDataRecovery(){

    input1 = document.getElementById( 'return_1');  //Input1
    input2 = document.getElementById('return_2');   //Select
    input3 = document.getElementById('return_3' ); //Input2

    //If the values are not completed
    if ( input1.value == "" || (input3.style.display != 'none' && input3.value == "" )|| (input2.style.display != 'none' &&  input2.value == ""  ) ) 
    {alert(msgjs6);return false;}
    //It verifies that does not repeat
      //You get all those in the table
      names = document.getElementsByName('data_recovery_names');
      exists_names = [];
      for(i=0;i< names.length;i++){exists_names[i] = names[i].parentNode.id.split('_')[1];}
      if(exists_names.inArray(input1.value)){alert(msgjs7 + input1.value +" "+ msgjs8);return false;}
      
    return true;

 }
 
 //Function that searches for the parameters to send for Ajax to create a DataRecovery
   function findParamsDataRecovery(){
   	  input1  = document.getElementById('return_1');  //Input1
      input2  = document.getElementById('return_2');  //Select
      input3  = document.getElementById('return_3'); //Input2
      new_name=input1.value;
      new_value = '';
       
      //If the INPUT is visible
      if ( input2.style.display == 'none'){
           new_value  = input3.value;
      }else{//If the SELECT is visible
           new_value         = input2.value ;
      }
      return 'name='+ new_name + '&code='+ new_value;
   }

//Function to add a data recovery to the table
  function addDataRecoveryIntoTable(circuit_id){
      input1  = document.getElementById('return_1');  //Input1
      input2  = document.getElementById('return_2');  //Select
      input3  = document.getElementById('return_3'); //Input2
      new_name=input1.value;
      new_value = '';
       
      //If the INPUT is visible
      if ( input2.style.display == 'none'){
           new_value  = input3.value;
      }else{//If the SELECT is visible
           new_value         = input2.value ;
      }
      
     table = document.getElementById('data_recovery_table');
     
     //creates the table if not exists (there was no data recovered)
     if(!table){
         //table is created
	      table = document.createElement('table');
	      table.setAttribute('style', 'margin: 0 auto; margin-top:0px; margin-bottom: 10px; padding: 10px;text-align:left; width:95%;');
	      table.setAttribute('class', 'detail');
	      table.setAttribute('CELLSPACING', '0');
	      table.id = 'data_recovery_table';   

		 //Titles
		  tr=document.createElement('tr');
         //Name
         th=document.createElement('th');
         th.innerHTML =   msgjs36;
         tr.appendChild(th);
         //Value
         th=document.createElement('th');
         th.innerHTML = 'Data';
   	     tr.appendChild(th); 
		    //Delete
		    th=document.createElement('th');
	      tr.appendChild(th);   
	         	      
        container = document.getElementById('campos_ya_ingresados');
        container.innerHTML = '';
        container.appendChild(table);   
        table = document.getElementById('data_recovery_table');  
        table.appendChild(tr);   
     }
  
     //Recovered data is added to the table
     row = table.insertRow(table.rows.length);
     row.id =  'row_' + new_name;
 	    
     //Name
	   cell = row.insertCell(0);
     cell.innerHTML =  new_name.truncate([length = 20]);
     cell.title= new_name;
     cell.setAttribute('name','data_recovery_names');
     //Value
	   cell = row.insertCell(1);
	   cell.title= new_value;
     cell.innerHTML = new_value.truncate([length = 20]);
     
     //Delete
	   cell = row.insertCell(2);
	   cell.setAttribute('style','width:10px;padding:0 10px;');
     elemento = document.createElement('img');
     elemento.src = '/images/icons/cross.png';
     elemento.alt = 'cross.png';
     elemento.name = new_name;
     elemento.setAttribute('style', 'cursor:pointer; height:12px; width:12px;margin:0 auto;');
     elemento.onclick = function(){ if(confirm(msgjs10)){new Ajax.Request('/circuits/deleteDataRecovery/' + circuit_id , {asynchronous:true, evalScripts:true, onComplete:function(request){deleteDataRecoveryTable( row.rowIndex );}, parameters:'name=' + new_name }) } }
  	 cell.appendChild(elemento);
  	    
}

//Function to delete a data recovery
function deleteDataRecoveryTable(rowIndex){
  //Are removed from the table
  table = document.getElementById('data_recovery_table');
  table.deleteRow(rowIndex);
  
  //If the elimination of all
  if(table.tBodies[0].rows.length == 1) { 
         container= table.parentNode; 
         container.removeChild(table); 
         container.innerHTML= '<br> ' + msgjs11 + ', <br> '+ msgjs12;
  }
}
 
