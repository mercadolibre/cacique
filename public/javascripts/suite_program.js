//Inputs created dynamically depending on the number of repetitions to specify the time of the runs 
function specific_hours(){
  div = $j('#specific')
  cant = parseInt($j('#repeat').val())
  div.html("");
  for(var nro = 0; nro < cant;nro++){
    div.append('<div>'+ msgjs40 + nro + ' <input name=program[specific_hour_' + nro + '] value = 12:00 style= width:50px;text-align:center></input> Hs.<br></div>')
  }
}

//if the number of repeats exceeds 1 shows the selection of time range of each
function change_repeat(value){
   if(parseInt(value) >1){
      $j('#range_repeat').show(); 
      if( $j('#specific').css('display') != 'none') specific_hours();
   }else{
     $j('#range_repeat').hide()
   };

}

//shows the options selected time range may be specific or every x number of hours
function change_select_range_each(value){
  $j('.range_each').hide();
  $j('#' + value).show();
  if(value == "specific")specific_hours();
}

