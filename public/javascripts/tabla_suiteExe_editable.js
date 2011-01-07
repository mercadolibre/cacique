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
// prepare the table for editing
function iniciarTabla(){
  //Inputs
  celdas = document.getElementsByName('edit_cell');
  for (i=0; i<celdas.length; i++) {
    celdas[i].ondblclick = function() {crearInput(this)} 
  }
 
  //zebra Table
  table = document.getElementById("executions");
  if(table !=null)zebra(table);
 }
  

// create input for data editing
function crearInput(celda) {
  celda.ondblclick = function() {return false}
  txt = celda.title;
  celda.innerHTML = '';
  obj = celda.appendChild(document.createElement('input'));
  obj.setAttribute('style', 'width:100%; ');
  obj.value = txt;
  obj.focus();
  suite_id = (celda.getAttribute('id'));
  obj.onblur = function() {
    sendChange(suite_id,celda.id, obj.value);
    celda.title= obj.value;
    txt = this.value;
    celda.removeChild(obj);
    celda.innerHTML = txt;
    celda.ondblclick = function() {crearInput(celda)}   
  }
  
  obj.onkeypress = function(e) {
    //If you press enter, you should not send the form
    tecla = (document.all) ? e.keyCode : e.which;
    if (tecla ==13){    
        sendChange(suite_id,celda.id, obj.value);
        celda.title= obj.value;
        txt = this.value;
        celda.removeChild(obj);
        celda.innerHTML = txt;
        celda.ondblclick = function() {crearInput(celda)}   
        return false;
    }
  }  
}

//Make the AJAX call
  function sendChange(suite_id, column, new_value){
      var url = '/suite_executions/update_data';
      var params = 'suite_id=' + suite_id +'&new_value=' + new_value;
      var ajaxRequest = new Ajax.Request(
                        url,
                        {
                                method: 'get',
                                parameters: params,
                                asynchronous: true,
                                onComplete: showResponse
                        });

    } 
    
    function showResponse(xmlHttpRequest, responseHeader)
     {// Function that receives the result of the request
     }




    
     
