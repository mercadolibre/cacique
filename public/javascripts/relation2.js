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
//*************************************************** RELATIONS 2 ***************************************************\\

// GLOBAL VARIABLES

//total of added arrows
var cantidad_flechas = 0;

  //Load Page:
  //Drag and Drop init
  window.onload = initDragDropScript;

//total arrow init
  function  inicializar_cant_flechas(){
    for(n=0; document.getElementById('flecha_' + n) != null; n++){
        cantidad_flechas++;
      }
  }

//Send Form with related Scripts
  function  submitCircuits2(){

    enviar_relaciones = false;
    form = document.getElementById('formRelation2');

    //Obtain Related Fields

      //obtain number of items from Box2
      div_box2 = document.getElementById('box2');
      elements_box2 = div_box2.getElementsByTagName('LI');

      //obtain number of items from Box3
      div_box3 = document.getElementById('box3');
      elements_box3 = div_box3.getElementsByTagName('LI');

      //empty box?
      if( (elements_box3.length != 0 ) && (elements_box2.length != 0) ){

         //same number of items in both box
         if (elements_box3.length == elements_box2.length){
           for(n=0; n < elements_box2.length; n++){

             elemento = document.createElement('input');
	     elemento.name = 'relations[' + n +'][origin]';
             elemento.type = 'text';
             elemento.value = elements_box2[n].id;
             elemento.setAttribute('style', 'display:none');
             form.appendChild(elemento);

             elemento = document.createElement('input');
	     elemento.name = 'relations[' + n +'][destination]';
             elemento.type = 'text';
             elemento.value = elements_box3[n].id;
             elemento.setAttribute('style', 'display:none');
             form.appendChild(elemento);
          }
          enviar_relaciones = true;
       }else{
          //Obtain less numbers of item
            alert(msgjs30)
           enviar_relaciones = false;
      }
    //any box is empty
    }else{enviar_relaciones = confirm(msgjs31);}

    if (enviar_relaciones)form.submit();
  }

//-------------Drag and Drop Cell Relations--------------//


    /* VARIABLES YOU COULD MODIFY */
    var boxSizeArray = [8,8,8,8];	// Array indicating how many items there is rooom for in the right column ULs

    var arrow_offsetX = -5;	// Offset X - position of small arrow
    var arrow_offsetY = 0;	// Offset Y - position of small arrow

    var arrow_offsetX_firefox = -6;	// Firefox - offset X small arrow
    var arrow_offsetY_firefox = -13; // Firefox - offset Y small arrow

    var verticalSpaceBetweenListItems = 3;	// Pixels space between one <li> and next



    // Same value or higher as margin bottom in CSS for #dhtmlgoodies_dragDropContainer ul li,#dragContent li
    var indicateDestionationByUseOfArrow = true;	// Display arrow to indicate where object will be dropped(false = use rectangle)
    var cloneSourceItems = false;	// Items picked from main container will be cloned(i.e. "copy" instead of "cut").
    var cloneAllowDuplicates = false;	// Allow multiple instances of an item inside a small box(example: drag Student 1 to team A twice

    /* END VARIABLES YOU COULD MODIFY */

    var dragDropTopContainer = false;
    var dragTimer = -1;
    var dragContentObj = false;
    var contentToBeDragged = false;	// Reference to dragged <li>
    var contentToBeDragged_src = false;	// Reference to parent of <li> before drag started
    var contentToBeDragged_next = false; 	// Reference to next sibling of <li> to be dragged
    var destinationObj = false;	// Reference to <UL> or <LI> where element is dropped.
    var dragDropIndicator = false;	// Reference to small arrow indicating where items will be dropped
    var ulPositionArray = new Array();
    var mouseoverObj = false;	// Reference to highlighted DIV

    var MSIE = navigator.userAgent.indexOf('MSIE')>=0?true:false;
    var navigatorVersion = navigator.appVersion.replace(/.*?MSIE (\d\.\d).*/g,'$1')/1;


    var indicateDestinationBox = false;


    function getTopPos(inputObj)
    {
    var returnValue = inputObj.offsetTop;
    while((inputObj = inputObj.offsetParent) != null){
    if(inputObj.tagName!='HTML')returnValue += inputObj.offsetTop;
    }
    return returnValue;
    }

    function getLeftPos(inputObj)
    {
    var returnValue = inputObj.offsetLeft;
    while((inputObj = inputObj.offsetParent) != null){
    if(inputObj.tagName!='HTML')returnValue += inputObj.offsetLeft;
    }
    return returnValue;
    }

    function cancelEvent()
    {
    return false;
    }


    function initDrag(e)	// Mouse button is pressed down on a LI
    {

    if(document.all)e = event;
    var st = Math.max(document.body.scrollTop,document.documentElement.scrollTop);
    var sl = Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);

    dragTimer = 0;

    dragContentObj.style.left = e.clientX + sl + 'px';
    dragContentObj.style.top = e.clientY + st + 'px';
    contentToBeDragged = this;
    contentToBeDragged_src = this.parentNode;
    contentToBeDragged_next = false;
    if(this.nextSibling){
    contentToBeDragged_next = this.nextSibling;
    if(!this.tagName && contentToBeDragged_next.nextSibling)contentToBeDragged_next = contentToBeDragged_next.nextSibling;
    }
    timerDrag();
    return false;
    }

    function timerDrag()
    {
    if(dragTimer>=0 && dragTimer<10){
    dragTimer++;
    setTimeout('timerDrag()',10);
    return;
    }
    if(dragTimer==10){

    if(cloneSourceItems && contentToBeDragged.parentNode.id=='allItems'){
    newItem = contentToBeDragged.cloneNode(true);
    newItem.onmousedown = contentToBeDragged.onmousedown;
    contentToBeDragged = newItem;
    }
    dragContentObj.style.display='block';
    dragContentObj.appendChild(contentToBeDragged);
    }
    }

    function moveDragContent(e)
    {
    if(dragTimer<10){
    if(contentToBeDragged){
    if(contentToBeDragged_next){
    contentToBeDragged_src.insertBefore(contentToBeDragged,contentToBeDragged_next);
    }else{
    contentToBeDragged_src.appendChild(contentToBeDragged);
    }
    }
    return;
    }
    if(document.all)e = event;
    var st = Math.max(document.body.scrollTop,document.documentElement.scrollTop);
    var sl = Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);


    dragContentObj.style.left = e.clientX + sl + 'px';
    dragContentObj.style.top = e.clientY + st + 'px';

    if(mouseoverObj)mouseoverObj.className='';
    destinationObj = false;
    dragDropIndicator.style.display='none';
    if(indicateDestinationBox)indicateDestinationBox.style.display='none';
    var x = e.clientX + sl;
    var y = e.clientY + st;
    var width = dragContentObj.offsetWidth;
    var height = dragContentObj.offsetHeight;

    var tmpOffsetX = arrow_offsetX;
    var tmpOffsetY = arrow_offsetY;
    if(!document.all){
    tmpOffsetX = arrow_offsetX_firefox;
    tmpOffsetY = arrow_offsetY_firefox;
    }

    for(var no=0;no<ulPositionArray.length;no++){
    var ul_leftPos = ulPositionArray[no]['left'];
    var ul_topPos = ulPositionArray[no]['top'];
    var ul_height = ulPositionArray[no]['height'];
    var ul_width = ulPositionArray[no]['width'];

    if((x+width) > ul_leftPos && x<(ul_leftPos + ul_width) && (y+height)> ul_topPos && y<(ul_topPos + ul_height)){
    var noExisting = ulPositionArray[no]['obj'].getElementsByTagName('LI').length;
    if(indicateDestinationBox && indicateDestinationBox.parentNode==ulPositionArray[no]['obj'])noExisting--;
    if(noExisting<boxSizeArray[no-1] || no==0){
    dragDropIndicator.style.left = ul_leftPos + tmpOffsetX + 'px';
    var subLi = ulPositionArray[no]['obj'].getElementsByTagName('LI');

    var clonedItemAllreadyAdded = false;
    if(cloneSourceItems && !cloneAllowDuplicates){
    for(var liIndex=0;liIndex<subLi.length;liIndex++){
    if(contentToBeDragged.id == subLi[liIndex].id)clonedItemAllreadyAdded = true;
    }
    if(clonedItemAllreadyAdded)continue;
    }

    for(var liIndex=0;liIndex<subLi.length;liIndex++){
    var tmpTop = getTopPos(subLi[liIndex]);
    if(!indicateDestionationByUseOfArrow){
    if(y<tmpTop){
    destinationObj = subLi[liIndex];
    indicateDestinationBox.style.display='block';
    subLi[liIndex].parentNode.insertBefore(indicateDestinationBox,subLi[liIndex]);
    break;
    }
    }else{
    if(y<tmpTop){
    destinationObj = subLi[liIndex];
    dragDropIndicator.style.top = tmpTop + tmpOffsetY - Math.round(dragDropIndicator.clientHeight/2) + 'px';
    dragDropIndicator.style.display='block';
    break;
    }
    }
    }

    if(!indicateDestionationByUseOfArrow){
    if(indicateDestinationBox.style.display=='none'){
    indicateDestinationBox.style.display='block';
    ulPositionArray[no]['obj'].appendChild(indicateDestinationBox);
    }

    }else{
    if(subLi.length>0 && dragDropIndicator.style.display=='none'){
    dragDropIndicator.style.top = getTopPos(subLi[subLi.length-1]) + subLi[subLi.length-1].offsetHeight + tmpOffsetY + 'px';
    dragDropIndicator.style.display='block';
    }
    if(subLi.length==0){
    dragDropIndicator.style.top = ul_topPos + arrow_offsetY + 'px'
    dragDropIndicator.style.display='block';
    }
    }

    if(!destinationObj)destinationObj = ulPositionArray[no]['obj'];
    mouseoverObj = ulPositionArray[no]['obj'].parentNode;
    mouseoverObj.className='mouseover';
    return;
    }
    }
    }
    }

    /* End dragging
    Put <LI> into a destination or back to where it came from.
    */


    function dragDropEnd(e)
    {
       origen  = contentToBeDragged_src.id;
       agregar_flecha = false;
       quitar_flecha = false;
       valor_fila = "";
       actualizar_momento = true; //If validations = false, do not refresh

   //---VALIDATE---

     //Se fija si el el destino el UL o LI, si es UL--> box, si es LI-->entre otros 2 elementos de un box (hay que averiguar su padre)
     if (destinationObj.tagName == 'LI'){
        //Obtain Destiny box
        destino = destinationObj.parentNode;
     }else{//UL
        destino = destinationObj;
     }

    //No mover en las columnas entre los circuitos, en ese caso vuelven a donde corresponden (entre box1 y box4)
    if( (origen == 'box1' ||  origen == 'box4') &&  (destino.id == 'box1' || destino.id == 'box4') ) {
      destinationObj = contentToBeDragged_src;
    }
   //move between Columns (box2 - box3)
    if( (origen == 'box2' ||  origen == 'box3') && (destino.id == 'box2' ||  destino.id == 'box3') ){
      destinationObj = contentToBeDragged_src;
    }

   //do not Move from box1 to box3 and box4 to box2
    if( (origen == 'box1' &&  destino.id == 'box3' ) || ( origen == 'box4' &&  destino.id == 'box2') ){
       actualizar_momento = false;
       //obtain Scripts
       (origen == 'box1')? destinationObj = document.getElementById('box1'): destinationObj = document.getElementById('box4') ;
    }

    //refresh to add Arrows
    //If box1 is Origin == box1 or box4 and Destiny == box2 or box3 add relations
    if( (origen == 'box1' ||  origen == 'box4') && (destino.id == 'box2' || destino.id == 'box3') && actualizar_momento )   {

            //obtain number of items from box2
            div_box2 = document.getElementById('box2');
            cant_box2 = div_box2.getElementsByTagName('LI').length;

            //obtain number of items from box3
            div_box3 = document.getElementById('box3');
            cant_box3 = div_box3.getElementsByTagName('LI').length;

            //if obtain number of items in Origin < Destiny add arrows
            if (destino.id == 'box2'){(cant_box2  < cant_box3)? agregar_flecha = true: agregar_flecha = false;}
            if (destino.id == 'box3'){(cant_box3  < cant_box2)? agregar_flecha = true: agregar_flecha = false;}

            //if number of arrows == max number of items else do not add arrows
            (cant_box2 >= cant_box3)? mayor_cantidad = cant_box2 :  mayor_cantidad =  cant_box3;
            if ( (cantidad_flechas == mayor_cantidad) && (cantidad_flechas!= 0) ) agregar_flecha = false;

            //if number of arrows > max number of Origin items else do not add arrows
            (destino.id == 'box2')? cantidad_destino = cant_box2: cantidad_destino = cant_box3;
            if( cantidad_flechas > cantidad_destino ) agregar_flecha = false;


    }
    //remove relations?
      if( (origen == 'box2' ||  origen == 'box3')  &&  (destino.id == 'box1' ||  destino.id == 'box4')   )  {
         //verify if return to correspondent Scripts
         //obtain correspondent Script
         (origen == 'box2')? circuito_padre = 'box1' : circuito_padre = 'box4';
        //if not return to correspondent Scripts
         if ( circuito_padre != destino.id ){
             (origen == 'box2')? destinationObj = contentToBeDragged_src: destinationObj = contentToBeDragged_src;
         }else{ //if remove relation
                  //remove arrow
                     //obtain number of items from box2
                     div_box2 = document.getElementById('box2');
                     cant_box2 = div_box2.getElementsByTagName('LI').length;

                     //obtain number of items from box3
                     div_box3 = document.getElementById('box3');
                     cant_box3 = div_box3.getElementsByTagName('LI').length;

                    //if number of arrows > maximun number of items else remove arrows
                    (cant_box2 >= cant_box3)? mayor_cantidad = cant_box2 :  mayor_cantidad =  cant_box3;
                    ( cantidad_flechas > mayor_cantidad )? quitar_flecha = true: quitar_flecha = false ;

                     //remove arrows
                     if(quitar_flecha){
                       div_flechas = document.getElementById('contenedor_flechas');
                       flecha_nro = cantidad_flechas - 1;
                       div_flechas.removeChild( document.getElementById('flecha_' + flecha_nro) );
                       //number of arrows refresh
                       cantidad_flechas--;
                     }
        }//else
    }




    if(dragTimer==-1){
      return;
    }

    if(dragTimer<10){
    dragTimer = -1;
    return;
    }
    dragTimer = -1;
    if(document.all)e = event;


    if(cloneSourceItems && (!destinationObj || (destinationObj && (destinationObj.id=='allItems' || destinationObj.parentNode.id=='allItems')))){
    contentToBeDragged.parentNode.removeChild(contentToBeDragged);
    }else{

    //if destiny == UL --> box, if is LI--> between other elements
    if(destinationObj){
    if(destinationObj.tagName=='UL'){
    destinationObj.appendChild(contentToBeDragged);
    }else{
    destinationObj.parentNode.insertBefore(contentToBeDragged,destinationObj);
    }

  //Add Arrows when add the second script in relation columns
    if(agregar_flecha) {
         document.getElementById('contenedor_flechas').innerHTML += '<div id=\'flecha_' + cantidad_flechas + '\' style="height:28px; width: 40px; margin:0px; border:none;" ><img  src="/images/icons/icon_flecha.png" style="width:23px; height:20px;"></div>';
    agregar_flecha = false;
    cantidad_flechas++;
    relacion_agregada = 0;
    }

    mouseoverObj.className='';
    destinationObj = false;
    dragDropIndicator.style.display='none';
    if(indicateDestinationBox){
    indicateDestinationBox.style.display='none';
    document.body.appendChild(indicateDestinationBox);
    }
    contentToBeDragged = false;

    //set div when move LI to (0,0)
    document.getElementById('dragContent').style.left = 0;
    document.getElementById('dragContent').style.top = 0;

    return;
    }
    if(contentToBeDragged_next){
    contentToBeDragged_src.insertBefore(contentToBeDragged,contentToBeDragged_next);
    }else{
    contentToBeDragged_src.appendChild(contentToBeDragged);
    }
    }
    contentToBeDragged = false;
    dragDropIndicator.style.display='none';
    if(indicateDestinationBox){
    indicateDestinationBox.style.display='none';
    document.body.appendChild(indicateDestinationBox);
    }
    mouseoverObj = false;
    }




    function initDragDropScript()
    {
    //init number of arrows
    inicializar_cant_flechas();
    dragContentObj = document.getElementById('dragContent');
    dragDropIndicator = document.getElementById('dragDropIndicator');
    dragDropTopContainer = document.getElementById('dhtmlgoodies_dragDropContainer');

    //Set acontainer heigh according number of Files
    cant_columns = (fields1_cant > fields2_cant)? fields1_cant : fields2_cant;
    container_height = (cant_columns*20) + (cant_columns*8);
    dragDropTopContainer.setAttribute('style', 'height:'+ container_height + 'px;');
    document.documentElement.onselectstart = cancelEvent;
    var listItems = dragDropTopContainer.getElementsByTagName('LI');	// Get array containing all <LI>
    var itemHeight = false;
    for(var no=0;no<listItems.length;no++){
    listItems[no].onmousedown = initDrag;
    listItems[no].onselectstart = cancelEvent;
    if(!itemHeight)itemHeight = listItems[no].offsetHeight;
    if(MSIE && navigatorVersion/1<6){
    listItems[no].style.cursor='hand';
    }
    }

    var mainContainer = document.getElementById('dhtmlgoodies_mainContainer');
    var uls = mainContainer.getElementsByTagName('UL');
    itemHeight = itemHeight + verticalSpaceBetweenListItems;
    //box size according number of fields
    cant_columns = (fields1_cant > fields2_cant)? fields1_cant : fields2_cant;
    boxSizeArray = [cant_columns,cant_columns,cant_columns,cant_columns];
    for(var no=0;no<uls.length;no++){
    //sum files space
    uls[no].style.height =  itemHeight * boxSizeArray[no] + 'px';
    }



    var leftContainer = document.getElementById('dhtmlgoodies_listOfItems');
    var itemBox = leftContainer.getElementsByTagName('UL')[0];

    document.documentElement.onmousemove = moveDragContent;	// Mouse move event - moving draggable div
    document.documentElement.onmouseup = dragDropEnd;	// Mouse move event - moving draggable div

    var ulArray = dragDropTopContainer.getElementsByTagName('UL');
    for(var no=0;no<ulArray.length;no++){
    ulPositionArray[no] = new Array();
    ulPositionArray[no]['left'] = getLeftPos(ulArray[no]);
    ulPositionArray[no]['top'] = getTopPos(ulArray[no]);
    ulPositionArray[no]['width'] = ulArray[no].offsetWidth;
    ulPositionArray[no]['height'] = ulArray[no].clientHeight;
    ulPositionArray[no]['obj'] = ulArray[no];
    }

    if(!indicateDestionationByUseOfArrow){
    indicateDestinationBox = document.createElement('LI');
    indicateDestinationBox.id = 'indicateDestination';
    indicateDestinationBox.style.display='none';
    document.body.appendChild(indicateDestinationBox);

    }
    }






