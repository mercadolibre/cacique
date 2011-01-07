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
  //Show Alerts and Submit Form
  function submit_form(){
	form = document.getElementById('move_form');
	ok = false;
	circuits    = document.getElementsByName('circuits_ids[]');
	category_to = document.getElementById('category_to');

  //Validations
    //at least any Script Selected
	  for(i=0;i<circuits.length;i++){
		  if (circuits[i].checked == true ){
		      ok = true; 
		      break;
		  }	
	  }
	//Destiny Category Complete
	if(ok == false){
	     alert(msgjs27);
	     ok = false;
	}else{
	    if(ok == true && category_to.value == ''){
	       alert(msgjs28);
	       ok = false;
	    }
	}
	
	if(ok){
		text_confirm = msgjs29 + category_to.options[category_to.selectedIndex].text;
		(confirm(text_confirm)?form.submit():"");
	}	


  }//end Function

