  var add_event = true;
  var add_asterisk = true;
  var TABKEY = 9; 
   
    
function restrictEnterKey(event) {
  var key=(event.charCode)?event.charCode:((event.keyCode)?event.keyCode:((event.which)?event.which:0));
  if (add_asterisk){
     if((key == 13) || (key == 8) || (key == 9) || ( (key >= 41) && (key <= 255) ) || (key == 32)){
        document.getElementById('modified_file').innerHTML = "<image src='/images/icons/s-edit.png'></img>";
    	document.getElementById('save_button').style.visibility = "visible"; 
	document.getElementById('savewc_button').style.visibility = "visible"; 		
        add_asterisk = false;
     }
  }
}




