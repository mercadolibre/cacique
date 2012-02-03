function show_output(link, execution_id){
	CCQUI.toggle_text(link, 'Format', 'No format');
	$j('#formated_output_' + execution_id + ', #raw_output_' + execution_id).toggle();
}