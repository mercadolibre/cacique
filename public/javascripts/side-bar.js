/***********************************************
* Dynamic Countdown script- © Dynamic Drive (http://www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/

var slideDuration = 10;
function extendContract(){
	if(isExtended == 0){
		document.getElementById('sideBarTab').style.background = "url(/images/menu/slide-button.png) repeat-y";
		document.getElementById('vertical_img').style.backgroundImage = "url(/images/menu/slide-arrow-active.png)";
	  	$j('#sideBarTab').animate({ left: '290px'},slideDuration);
		$j('#sideBarContents').animate({ width: '270px'},slideDuration);
		$j('#sideBarTab').height($j('#sideBar').height());
		$j('#sideBar').animate({ left: '-32px'},slideDuration);
		//height = $j(window).height() -140;
        width  = $j(window).width() -350;
		$j('#layout_content').width(width);
		$j('#layout_content').css( 'float','right' )
		//document.getElementById('layout_content').setAttribute('style', 'width:80%; padding-left:0%;float:right; height:' +height +'px;'  );
		isExtended = 1;
    		$j.cookie("cacique_slider_menu", "1",  { path: '/'});
	}
	else{		
		document.getElementById('sideBar').style.backgroundImage = "url(/images/menu/slide-button.png) repeat-y";
	  document.getElementById('vertical_img').style.backgroundImage = "url(/images/menu/slide-arrow.png)";
	  $j('#sideBar').animate({ left: '-2px'},10);
		$j('#sideBarTab').animate({ left: '0px'},10);
		$j('#sideBarContents').animate({ width: '0px'},slideDuration);
		$j('#layout_content').width('95%');
		isExtended = 0;
		$j.cookie("cacique_slider_menu", "0",  { path: '/'});		
	}

}

