function buscar_argumentos(){text='';div=document.getElementById('functions').value;if(div!='-Select-'){arguments=document.getElementsByName(div);for(i=0;i<arguments.length;i++){if(arguments[i].style.display!='none'){if(arguments[i].value!=''){text+=arguments[i].value+',';}}}
armado_funcion(text);}}
function armado_funcion(arguments){div=document.getElementById('functions').value;cantRows=0;text_function='';if(arguments!=false){arguments=arguments.substring(0,arguments.length-1);}
text_function=div+'('+arguments+')';insertarTexto(text_function);document.getElementById('div_with_functions').toggle();}
function insertarTexto(text){actual_pos=script_content.getCursor();script_content.replaceRange(text,actual_pos);}
function activarDiv(id){desactivarDivs();if(id!='-Select-'){div=document.getElementById(id);div.style.display="";}}
function desactivarDivs(){divs=document.getElementsByName('div_function');for(n=0;n<divs.length;n++){divs[n].style.display='none';}}
function changeFunctionsInput(div,arg){input=document.getElementById(div+'_input_'+arg).style.display;if(input=='none'){document.getElementById(div+'_select_'+arg).style.display='none';document.getElementById(div+'_input_'+arg).style.display='block';}else{document.getElementById(div+'_select_'+arg).style.display='block';document.getElementById(div+'_input_'+arg).style.display='none';}}
function sendCircuitUpdate(){c_name=document.getElementById('circuit_name').value;c_description=document.getElementById('circuit_description').value;if(c_name==''||c_description=='')alert('Debe completar los campos');else{document.getElementById('form_edit_circuit').submit();document.getElementById('update_circuit').style.display='none';}}
function changeInput(){if(document.getElementById('data_recovery_name_code').style.display=='none'){document.getElementById('data_recovery_name_code').style.display='block';document.getElementById('data_recovery_name_code_2').style.display='none';}else{document.getElementById('data_recovery_name_code').style.display='none';document.getElementById('data_recovery_name_code_2').style.display='block';}}
function change_default(elem,value){options_name=".options_of_"+value;checkboxs=$j(options_name);if(elem.checked){checkboxs.attr('disabled',true);checkboxs.attr('checked',false);}
else{checkboxs.attr('disabled',false);}}
function ch_select_all(checker,attr_class){$j("."+attr_class).attr('checked',checker.checked);}
function disable_all(disabled,attr_class){$j("."+attr_class).attr('disabled',disabled);}
function has_changed(){$j('#pencil_icon').show();$j('#save_button').show();changed_flag=true;}