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

function validarSeleccion(){
  checks = document.getElementsByName('execution_run[]');
  for(i=0;i<checks.length;i++) {
     if(checks[i].checked) return true;
  }
  alert(msgjs14);
  return false;
}

function validarSeleccionSinAlert(){
  checks = document.getElementsByName('execution_run[]');
  for(i=0;i<checks.length;i++) {
     if(checks[i].checked) return true;
  }
  return false;
}

//Run or Stop Selected Script
function submitForm(action){
     if(validarSeleccion()){
       form = document.getElementById('ejecutar_circuitos');
       form.action = action;
       form.submit();
     }

}

//Verify Cehckbox & submit
function submit_delete(){
  	if(validarSeleccionSinAlert()){
  		if(confirm(msgjs15 + '?'))submitForm('/case_templates/delete');
  	}
  	else{
  		if(marcado){
  			if(confirm(msgjs15 + marcado + '?'))location='/case_templates/delete/'+ marcado;
  		}
  		else{
  			alert(msgjs14);
  			return false;
  		}
  	}

}

function submit_play(project_id, circuit_id){
  	if(validarSeleccionSinAlert()){
	  		submitForm('/suite_executions/create?project_id=' + project_id);
  	}
  	else{
  		if(marcado){
  			location='/suite_executions/create?case_template_id='+ marcado + '&where_did_i_come=case_templates_index' + '&project_id=' + project_id + '&circuit_id=' + circuit_id;
  		}
  		else{
  			alert(msgjs14);
  			return false;
  		}
  	}
}

 
//-------------------------------------------------ABM column---------------------------------------------/

function habilitarSolapa(name){

  if(name == 'add'){
    document.getElementById('add_column').style.display='block';
    document.getElementById('delete_column').style.display='none';
    document.getElementById('modify_column').style.display='none';
    document.getElementById('t_add').style.backgroundColor='#E0E0F8';
    document.getElementById('t_delete').style.backgroundColor='#FFFFFF';
    document.getElementById('t_modify').style.backgroundColor='#FFFFFF';
  }
  else{
    if(name == 'delete'){
    	document.getElementById('delete_column').style.display='block';
    	document.getElementById('add_column').style.display='none';
    	document.getElementById('modify_column').style.display='none';
    	document.getElementById('t_add').style.backgroundColor='#FFFFFF';
    	document.getElementById('t_delete').style.backgroundColor='#E0E0F8';
    	document.getElementById('t_modify').style.backgroundColor='#FFFFFF';
    }
    else{
    	document.getElementById('delete_column').style.display='none';
    	document.getElementById('add_column').style.display='none';
    	document.getElementById('modify_column').style.display='block';
    	document.getElementById('t_add').style.backgroundColor='#FFFFFF';
    	document.getElementById('t_delete').style.backgroundColor='#FFFFFF';
    	document.getElementById('t_modify').style.backgroundColor='#E0E0F8';
    }
  }
 
}  

 

