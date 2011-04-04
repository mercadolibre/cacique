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
//*************************************************** RELATIONS 3 ***************************************************

//-------------GLOBAL VARIABLES----------------//
  var relation_pairs = new Array(); //IDs for cases relations
  
  //Generate String with Ids pairs
  function send_relation(next_action){
	var texto="";

	if(relation_pairs.length == 0){
		alert(msgjs32);
		return false;
	}

	for (i=0; i<relation_pairs.length; i++) {
		rel = relation_pairs[i];
		texto += rel[0] + "," + rel[1] + ";";
	}

	form = document.getElementById("send_relations");
	form.content.value = texto;
	form.next_action.value = next_action;
	form.submit();

	relation_pairs.splice(0,relation_pairs.length);
	table = document.getElementById("relationListTable");

  }


  //Remove ids pairs
  function delete_relation( id ) {
	old_relation_pairs = relation_pairs;
	relation_pairs = new Array();

	for (i=0; i<old_relation_pairs.length; i++) {
		if (i != id ) {
			relation_pairs[relation_pairs.length] = old_relation_pairs[i];
		}
	}

	tabla = document.getElementById("relationListTable");
	actualizar_tabla(tabla);

  }

  //add relation as ids pairs
  function agregar_relacion_onclick() {
	var seleccionado_1 = -1;
	var seleccionado_2 = -1;

	//get Script Cases
	casos_1 = get_casos("caso_1_group");
	casos_2 = get_casos("caso_2_group");

	//get selected element from case_1
	for (i=0; i<casos_1.length;i++) {
		elem = document.getElementById(casos_1[i]);
		if (elem.checked) {
			seleccionado_1 = casos_1[i];
		}
	}

	//get selected element from case_2
	for (i=0; i<casos_2.length;i++) {
		elem = document.getElementById(casos_2[i]);
		if (elem.checked) {
			seleccionado_2 = casos_2[i];
		}
	}

	if (seleccionado_1 == -1 || seleccionado_2 == -1 ) {
		alert(msgjs33);
		return false;
	}

	if(verificar_repetidos(seleccionado_1, seleccionado_2)){
		relation_pairs[relation_pairs.length] = new Array(seleccionado_1, seleccionado_2);
		tabla = document.getElementById("relationListTable");
		actualizar_tabla(tabla);
	}
	else{
		alert(msgjs34);
		return false;
	}
  }

  // return ids array with names
  function get_casos(name_radio){
	var casos = new Array();
	elementos = document.getElementsByName(name_radio);
	for(i=0;i<elementos.length;i++){
		casos[casos.length] = elementos[i].id;
	}
	return casos
  }

  //refresh info when add or remove relations
  function actualizar_tabla(tabla) {

	for (i=tabla.rows.length-1; i>0; i-- ) {
		tabla.deleteRow(i);
	}

	for (i=0; i<relation_pairs.length; i++) {

		seleccionado_1 = relation_pairs[i][0];
		seleccionado_2 = relation_pairs[i][1];

		seleccionado1 = document.getElementById(seleccionado_1);
		seleccionado2 = document.getElementById(seleccionado_2);


		new_row = tabla.insertRow( tabla.rows.length );
		new_cell = new_row.insertCell(0);
	  new_cell.setAttribute('style', ' color:#31576F; text-align: left; border-bottom: #EAECEE 0.5px solid;');
		new_cell.style.width = '50px';
    new_cell.title     = seleccionado1.value;
    new_cell.innerHTML = seleccionado1.value.truncate([length = 25]);

		new_cell = new_row.insertCell(1);
		new_cell.setAttribute('style', 'padding-left: 10px;color:#31576F; text-align: left; border-bottom: #EAECEE 0.5px solid;' );
		new_cell.style.width = '50px';
		new_cell.innerHTML = seleccionado2.value;
		new_cell.title     = seleccionado2.value;
    new_cell.innerHTML = seleccionado2.value.truncate([length = 25]);

		new_cell = new_row.insertCell(2);
		new_cell.style.width = '5px';

		elemento = document.createElement('img');
		elemento.id = 'img_delete_' + i;
		elemento.name = i;
		elemento.src = '/images/icons/cross.png';
		elemento.alt = 'cross.png';
		elemento.style.display = 'block';

		elemento.onclick = function(){
			delete_relation( this.name );
		}

		new_cell.appendChild(elemento);

	}
  }

  //verify repeated relations
  function verificar_repetidos(id1, id2){
	var bandera = true;

	for(i=0;i<relation_pairs.length;i++){
		if(relation_pairs[i][0] == id1 && relation_pairs[i][1] == id2){
			bandera = false;
		}
	}
	return bandera;
  }

