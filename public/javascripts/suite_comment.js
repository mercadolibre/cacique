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
function showCircuit(){
     circuit = $j('#select_circuits').val() 
     $j('.div_circuit_cases').hide();
     $j('#div_circuit_' + circuit ).show();
     $j('.div_circuit').hide(); //Relations                         
}

//Function that defines the relationships affected (broken) to uncomment a case of a circuit
  function  RelacionesRotas(check, circuito, caso){
  
    div_circuit_relations = $j('#div_relation_broken_' + $j('#select_circuits').val() );
    relation=$j('#broken_' + caso);
   //If comments
   if (!check.checked){
      document.getElementById(caso).style.background = "#FDAFAF";
      relation.show();
      //Just shows the broken relationships div that circuit if you have
      if( div_circuit_relations.find('.broken_relation').length != 0)div_circuit_relations.show();    
   }else{
      document.getElementById(caso).style.background = "#FFFFFF";
      relation.hide();
      //If it was the only visible, it hides the entire span of broken relationships that circuit
      if( div_circuit_relations.find('.broken_relation:visible').length == 0) {
         div_circuit_relations.hide(); 
      }   
   }
  }
  
  //Continue clicking is called, sends the selected cases to run the driver SuiteExecution
  function submit_form(){
	form = document.getElementById('send_comment')
	form.submit();

  }
  
  //Function that adds the ids of the cases discussed at an input form
  function addFormCaseCommentIds(){
  	checkboxs = document.getElementsByName('cases[]');
  	input = document.getElementById('execution_case_comment');
  	marked = ""
  	for(i=0;i<checkboxs.length;i++){
  		if(!checkboxs[i].checked){
  			marked += checkboxs[i].value + ";"
  		}
  	}
  	input.value = marked;	
  	comment_div = document.getElementById('div_suite_comment');
  	comment_div.style.display = 'none';
  }
  
  
  
  
