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
//*************************************************** RELATIONS 1 ***************************************************

//-------------GLOBAL VARIABLES----------------//
  var from_array = new Array;  // Suite Scripts
  var to_array = new Array;   // Script to relate

//Draw line between 2 points
  var clicks = 1;  //selected cell
  var Ax = 0;
  var Bx = 0;
  var Ay = 0;
  var By = 0;

//send form with selected scripts
  function  submitCircuits(){

    select = document.getElementById('yyy');
    if(select.options.length != 2){
	 alert (msgtext);
	return false;
    }
    form = document.getElementById('formRelation')

    elemento = document.createElement('input');
    elemento.id = 'circuit_1';
    elemento.name = 'circuit_1';
    elemento.type = 'text';
    elemento.value = circuitIdFromName()[ select.options[0].value ];
    elemento.setAttribute('style', 'display:none');
    form.appendChild(elemento);

    elemento = document.createElement('input');
    elemento.id = 'circuit_2';
    elemento.name = 'circuit_2';
    elemento.type = 'text';
    elemento.value = circuitIdFromName()[ select.options[1].value ];
    elemento.setAttribute('style', 'display:none');
    form.appendChild(elemento);

    form.submit();

  }

//verify only 2 script was selected
   function validarCantidad(){
     select = document.getElementById('yyy');
     if(select.options.length < 2){
        return true;
     }else{
     alert(msgtext);
        return false;
     }
   }

//-------------Move between list----------------//

//to move between list (From - To)
  function moveoutid(){
     var sda = document.getElementById('xxx');;
     var len = sda.length;
     var sda1 = document.getElementById('yyy');
     for(var j=0; j<len; j++){
        if(sda[j].selected){
          var tmp = sda.options[j].text;
          var tmp1 = sda.options[j].value;
          sda.remove(j);
          j--;
          len--;
          var y=document.createElement('option');
          y.setAttribute('style', 'color:#31576F; font-size:11px;font-family:sans-serif;');
          y.text=tmp;
          y.value=tmp1;
          try
          {sda1.add(y,null);
          }catch(ex){
          sda1.add(y);}
       }
    }
}

//to move between list (To - From)
  function moveinid()
  {
     var sda = document.getElementById('xxx');
     var sda1 = document.getElementById('yyy');
     var len = sda1.length;
     for(var j=0; j<len; j++){
        if(sda1[j].selected){
          var tmp = sda1.options[j].text;
          var tmp1 = sda1.options[j].value;
          sda1.remove(j);
          j--;
          len--;
          var y=document.createElement('option');
          y.setAttribute('style', 'color:#31576F; font-size:11px;font-family:sans-serif;');
          y.text=tmp;
          y.value=tmp1;
          try{
            sda.add(y,null);}
            catch(ex){
            sda.add(y);
          }

       }
    }
 }


