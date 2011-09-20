  var add_event = true;
  var add_asterisk = true;
  var TABKEY = 9; 
   
    
function restrictEnterKey(event) {
  var key=(event.charCode)?event.charCode:((event.keyCode)?event.keyCode:((event.which)?event.which:0));
  if (add_asterisk){
     //  0: Win, Alt gr, 20: Mayús, 112-123: f1-f12 
     if((key != 0) && (key != 20) && !(112 <= key && key <= 122) ){
        document.getElementById('modified_file').innerHTML = "<image src='/images/icons/s-edit.png'></img>";
    	document.getElementById('save_button').style.visibility = "visible"; 
	    document.getElementById('savewc_button').style.visibility = "visible"; 		
        add_asterisk = false;
     }
  }
}
