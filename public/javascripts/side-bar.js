 /* *  @Authors:     *      Brizuela Lucia                  lula.brizuela@gmail.com *      Guerra Brenda                   brenda.guerra.7@gmail.com *      Crosa Fernando                  fernandocrosa@hotmail.com *      Branciforte Horacio             horaciob@gmail.com *      Luna Juan                       juancluna@gmail.com *       *  @copyright (C) 2010 MercadoLibre S.R.L * * *  @license        GNU/GPL, see license.txt *  This program is free software: you can redistribute it and/or modify *  it under the terms of the GNU General Public License as published by *  the Free Software Foundation, either version 3 of the License, or *  (at your option) any later version. * *  This program is distributed in the hope that it will be useful, *  but WITHOUT ANY WARRANTY; without even the implied warranty of *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the *  GNU General Public License for more details. * *  You should have received a copy of the GNU General Public License *  along with this program.  If not, see http://www.gnu.org/licenses/. */var slideDuration = 10;
function extendContract(){
	if(isExtended == 0){
		document.getElementById('sideBarTab').style.background = "url(/images/menu/slide-button.png) repeat-y";
		document.getElementById('vertical_img').style.backgroundImage = "url(/images/menu/slide-arrow-active.png)";
	  $j('#sideBarTab').animate({ left: '300px'},slideDuration);
		$j('#sideBarContents').animate({ width: '270px'},slideDuration);
		$j('#sideBarTab').height($j('#sideBar').height());
		$j('#sideBar').animate({ left: '-32px'},slideDuration);
		height = $j(window).height() -140;
		document.getElementById('layout_content').setAttribute('style', 'width:73%; padding-left:0%;float:right; height:' +height +'px;'  );
		isExtended = 1;
    $j.cookie("cacique_slider_menu", "1",  { path: '/'});
	}
	else{		
		document.getElementById('sideBar').style.backgroundImage = "url(/images/menu/slide-button.png) repeat-y";
	  document.getElementById('vertical_img').style.backgroundImage = "url(/images/menu/slide-arrow.png)";
	  $j('#sideBar').animate({ left: '-2px'},10);
		$j('#sideBarTab').animate({ left: '0px'},10);
		$j('#sideBarContents').animate({ width: '0px'},slideDuration);
		document.getElementById('layout_content').setAttribute('style', 'width:95%;')
		isExtended = 0;
		$j.cookie("cacique_slider_menu", "0",  { path: '/'});		
	}

}





