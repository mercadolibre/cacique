

winwait("[REGEXPTITLE:(Identificación requerida)|(Confirmar)|(Alerta de seguridad)|(Close Firefox)|(Quit Firefox)|(Cerrar Firefox)|(Salir de Firefox))|(Advertencia de seguridad)|(Firefox - Restaurar sesión anterior)|(Confirm)|(Aviso de seguridad)|(Server Certificate Expired)|(Security Error: Domain Name Mismatch)|(Website Certified by an Unknown Authority)|(El certificado del servidor expiró)|(Error de seguridad: No coincide el nombre de dominio)|(Error de seguridad: El nombre del dominio no coincide)]")

BlockInput(1)
if WinExists("Identificación requerida","") then ControlSend("Identificación requerida","","",'{enter}')
	

if WinExists("Confirmar","") then ControlSend("Confirmar","","",'{enter}')
	
if WinExists("Alerta de seguridad","") Then
	ControlClick( "Alerta de seguridad", "", "&Sí" )
EndIf

if WinExists("Firefox - Restaurar sesión anterior","") then WinClose("Firefox - Restaurar sesión anterior","")

if WinExists("Aviso de seguridad","") then ControlSend("Aviso de seguridad","","",'{enter}')
if WinExists("Advertencia de seguridad","") then ControlSend("Advertencia de seguridad","","",'{enter}')	
	
if WinExists("Close Firefox","") then ControlSend("Close Firefox","","",'{enter}')
	
if WinExists("El certificado del servidor expiró","") then ControlSend("El certificado del servidor expiró","","",'{enter}')

if WinExists("Error de seguridad: No coincide el nombre de dominio","") then 
	ControlSend("Error de seguridad: No coincide el nombre de dominio","","",'{left}')
	ControlSend("Error de seguridad: No coincide el nombre de dominio","","",'{enter}')
EndIf

if WinExists("Error de seguridad: No coincide el nombre de dominio","") then 
	ControlSend("Error de seguridad: No coincide el nombre de dominio","","",'{left}')
	ControlSend("Error de seguridad: No coincide el nombre de dominio","","",'{enter}')
EndIf

if WinExists("The page at http://www.mercadolibre.com.ar says:","") then 
	ControlSend("Deseas dar por finalizada la venta de los artculos seleccionados? Utilizar esta opcin no tiene costo adicional","","",'{enter}')
EndIf

if WinExists("The page at http://www.mercadolivre.com.br says:","") then 
	ControlSend("Deseja finalizar a venda dos produtos selecionados? Utilizar esta op no tem custo adicional","","",'{enter}')
EndIf

if WinExists("The page at http://www.mercadolibre.cl says:","") then 
	ControlSend("Deseas dar por finalizada la venta?","","",'{enter}')
EndIf

if WinExists("Confirm","") Then
	ControlSend("Confirm","","",'{enter}')
EndIf

if WinExists("Website Certified by an Unknown Authority","") Then
	ControlSend("Website Certified by an Unknown Authority","","",'{enter}')
EndIf

if WinExists("Security Error: Domain Name Mismatch","") Then
	ControlSend("Security Error: Domain Name Mismatch","","",'{left}')
	ControlSend("Security Error: Domain Name Mismatch","","",'{enter}')
EndIf

if WinExists("Server Certificate Expired","") Then
	ControlSend("Server Certificate Expired","","",'{enter}')
EndIf

if WinExists("Quit Firefox","") then 
	ControlSend("Quit Firefox","","",'{left}')
	ControlSend("Quit Firefox","","",'{enter}')
EndIf

if WinExists("Cerrar Firefox","") then 
	ControlSend("Cerrar Firefox","","",'{left}')
	ControlSend("Cerrar Firefox","","",'{enter}')
EndIf

if WinExists("Salir de Firefox","") then 
	ControlSend("Salir de Firefox","","",'{left}')
	ControlSend("Salir de Firefox","","",'{enter}')
EndIf

BlockInput(0)

run("fireclicker.exe")

