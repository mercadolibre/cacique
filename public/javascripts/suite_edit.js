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
  function update_cases_all(suite_id,circuit_id,todos){
  	checks = document.getElementsByName('case_templates[]');
  	for(u=0;u<checks.length;u++){
  		if(todos.checked == true){
  			if(checks[u].id == 'case_' + circuit_id && checks[u].checked != true){
  				update_cases(true,suite_id,checks[u].value);
  			}
  		}
  		else{
  			if(checks[u].id == 'case_' + circuit_id){
  				update_cases(false,suite_id,checks[u].value);
  			}
  		}
  	}
  }
  
 
//It is updated for the suite (was added or removed)
  //Make the AJAX call
  function update_cases(agregar, suite_id,case_id){
      var url = '';
      (agregar)?url = '/suites/add_suite_case' : url = '/suites/delete_suite_case';
      
      var params = 'suite_id=' + suite_id + '&case_id='+ case_id;
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

//-------------------------------------- CREATE NEW CASE ----------------------------------//

 function showResponseData(xmlHttpRequest, responseHeader)
     {// Function that receives the result of the request
  }
 
 
