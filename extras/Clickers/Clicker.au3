
WinWait( "[REGEXPTITLE:(Connect to)|(Enter Network Password)|(Security Alert)|(Security Information)|(Internet Explorer)|(Conectar a)|(Selenium Remote Control v1.0-SNAPSHOT [1123], with Core v@VERSION@ [@REVISION@])|(Alerta de Seguridad)|(Alerta de seguridad)|(Advertencia de seguridad)|(Información de seguridad)|(la pagina en http://)|(Error en el script de Internet Explorer)|(Error de secuencia de comandos de Internet Explorer)|(Security Warning)]" )

If     WinExists( "Connect to", "IPCop" ) == 1 Then
	ControlClick( "Connect to", "IPCop", "OK" )
ElseIf WinExists( "Microsoft Internet Explorer", "seguro que deseas eliminar la preferencia?" ) == 1 Then
	ControlClick( "Microsoft Internet Explorer", "seguro que deseas eliminar la preferencia?", "OK" )
ElseIf WinExists( "Enter Network Password", "IPCop" ) == 1 Then
	ControlClick( "Enter Network Password", "IPCop", "OK" )
ElseIf WinExists( "Security Alert", "" ) == 1 Then
	ControlClick( "Security Alert", "", "&Yes" )
ElseIf WinExists( "Security Information", "" ) == 1 Then
	ControlClick( "Security Information", "", "&Yes" )
ElseIf WinExists( "Alerta de Seguridad", "" ) == 1 Then
	ControlClick( "Alerta de Seguridad", "", "Sí" )
ElseIf WinExists( "Alerta de seguridad", "" ) == 1 Then
	ControlSend("Alerta de seguridad","","",'{left}')
	ControlSend("Alerta de seguridad","","",'{enter}')
ElseIf WinExists( "Conectar a", "" ) == 1 Then
	ControlClick( "Conectar a", "", "Aceptar" )
ElseIf WinExists( "Información de seguridad", "" ) == 1 Then
	ControlClick( "Información de seguridad", "", "&Sí" )	
ElseIf WinExists( "la pagina", "" ) == 1 Then
	ControlClick( "la pagina", "", "&Aceptar" )
ElseIf WinExists("Advertencia de seguridad","") == 1 Then
	ControlClick("Advertencia de seguridad","","Sí" )	
ElseIf WinExists("Aviso de seguridad","") == 1 Then
	ControlClick("Aviso de seguridad","","&Continuar" )	
ElseIf WinExists("Selenium Remote Control v1.0-SNAPSHOT [1123], with Core v@VERSION@ [@REVISION@]","") == 1 Then
	ControlClick("Selenium Remote Control v1.0-SNAPSHOT [1123], with Core v@VERSION@ [@REVISION@]","","&Aceptar")
EndIf

if WinExists("Security Warning","") then 
	ControlSend("Security Warning","","",'{enter}')
EndIf



if WinExists("Error en el script de Internet Explorer","") then 
	ControlSend("Error en el script de Internet Explorer","","",'{enter}')
EndIf

if WinExists("Error de secuencia de comandos de Internet Explorer","") then 
	ControlSend("Error de secuencia de comandos de Internet Explorer","","",'{enter}')
EndIf

if WinExists("Internet Explorer","") Then
	ControlSend("Internet Explorer","","",'{enter}')
EndIf

Run( "Clicker.exe" )
