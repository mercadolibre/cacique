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
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//Function to genete a popup (miLink: window to open, windowname: window id)
  function popup(mylink, windowname)
  {
  if (! window.focus)return true;
  var href;
  if (typeof(mylink) == 'string')
  href=mylink;
  else
  href=mylink.href;
  window.open(href,windowname,'width=400,height=200,scrollbars=0,directories=0');
  return false;
  }
  
//Select Init with an ID
  function initializeSelect(nombre){
    select = document.getElementById(nombre); 
    select.selectedIndex = 0;
  } 

  //create an array from a collection(select options)
  function armararray(option)
  {
     var ary = [];
     for(n=0; n < option.length; n++){
        ary[n] = option[n].value; 
     }
     return ary;  
  }

    
//To add an opcion in any select_list
  function addselect(objeto,name)
  {
  	objeto.length++;
  	objeto.options[objeto.length-1].text =name;
  	objeto.options[objeto.length-1].value=name;
  }
  
  
//To find and element in an array
Array.prototype.inArray = function (value) {
	var i;
	for (i=0; i < this.length; i++) {
		if (this[i] === value) {
			return true;
		}
	}
	return false;
};
 
 
 
//ON LOAD EVENT!!!!!!!!!!!!!!!!!!!! 
  
//Function to the table a zebra style
//to work, the table must have :name=>'table_zebra'

//when load page, all tables with name 'table_zebra'
////assigned zebra style
function onload(){
  // zebras Tables
  var tables = document.getElementsByName("table_zebra");
  for (var i = 0; i < tables.length; i++) {
    zebra(tables[i]);  
  }	
}


function zebra(table) {
  var current = "oddRow";
  var trs = table.getElementsByTagName("tr");
  for (var i = 1; i < trs.length; i++) {
    trs[i].className += " " + current;
    current = current == "evenRow" ? "oddRow" : "evenRow";
  }
}  
  

//To mark any File y Zebra Table
  function marcar(obj,color) {
  /* despinto anterior */
  if (anterior) {anterior.style.backgroundColor=color_anterior; anterior.style.color = '#668AA2';}
  /* Color del marcado */ 
  color_anterior = obj.style.backgroundColor;  
  anterior = obj;  
  marcado  = obj.id;
  obj.style.backgroundColor=color;
  obj.style.color= '#FFFFFF';
  
  }
 

//To verify if is selected any file in table (suite index + case templates),
//or in Category tree (category index)
  function is_marked(marcado, entidad){
  
  if(marcado)return true;
  else{alert(msgjs13 + entidad); return false;}
  
  } 
  
 
  //To Codify a Text
  //Must send by parameters: encodeURI(encoded_value)
  // and then: encode_value .split("_")[1..-1].map{|x| decode_char(x) }.join
  function encode_text(value){
    var encoded_value = "";
	  for (i=0; i<value.length; i++) {

		  var chrcode = value.charCodeAt(i);
		  if (chrcode != 0) {
			  if (chrcode < 127  && chrcode >= 0) {
				  encoded_value = encoded_value + "_x" + value.charCodeAt(i).toString(16);
			  } else {
				  encoded_value = encoded_value + "_" + value.charAt(i);
			  }
		  }
	  }
	  return encoded_value 
  }
    
//Cacique Ui
var CCQUI = {};

//Toggle text
CCQUI.toggle_text = function(element, text1, text2) {
  var new_text =  ( element.text().search(text1) == -1 )? text1 : text2;
  element.text(new_text); 
};

//Hide and show elements
var CCQUI = {};
CCQUI.show_and_hide = function(show, hide) {
    $j(hide).hide();
    $j(show).show();
};