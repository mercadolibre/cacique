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
var hour
//Generar PDF
  function EnviarFormulario(){
  form = document.getElementById('generar_pdf');
  if (validarSeleccion())
  form.submit();
  }
  
  function validarSeleccion(){
  checks = document.getElementsByName('suite_executions[]');
  for(i=0;i<checks.length;i++) {
     if(checks[i].checked) return true;
  }
  alert(msgjs38);
  return false;
  }

//Exportar historial
  function popup(mylink, windowname){
   if (! window.focus)return true;
   var href;
   if (typeof(mylink) == 'string')href=mylink;
   else href=mylink.href;
   window.open(href,windowname,'width=400,height=200,scrollbars=0,directories=0');
   return false;
  }
  function ModificarTodos(box){
    checks = document.getElementsByName('suite_executions[]');
    for (i=0; i<checks.length;i++)
      checks[i].checked = box.checked ;
  }
  function set_date(id){
    check_minute = document.getElementsByClassName("minute")[0];
    check_hour = document.getElementsByClassName("hour")[0];
    check_minute.value="59";
    check_hour.value ="23";
    box=document.getElementById('filter[finish_date]');
    hour=box.value
  }
  function set_hour(){
    var hour;
    hour = document.getElementsByClassName("cds_footer")[0].childNodes[0].textContent.replace("00:00","23:59");
    document.getElementById("filter[finish_date]").value=hour;
    document.getElementsByClassName("cds_footer")[0].childNodes[0].textContent=hour;
  }
  
