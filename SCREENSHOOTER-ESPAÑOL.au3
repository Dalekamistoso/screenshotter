; Aqui fuerzo los permisos administrativos

  #RequireAdmin

; Aquí quito el icono del systray para pausar el script

  #NoTrayIcon


; Aqui incluyo las funciones que voy a usar

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <file.au3>
#include <WinAPIFiles.au3>
#include <StaticConstants.au3>
#Include <GuiButton.au3>
#include <String.au3>
#include <Misc.au3>

; Borro los ficheros que no deberian estar a fin de verificar su presencia despues y evitar errores de dependencias

   FileDelete ( "lista.txt" ) ; Borro este por si algún proceso anterior se quedase pillado (por si las moscas)

; Verifico que no haya otra instancia del programa funcionando para evitar colisiones
; OJITO CON ESTO porque la funcion singleton usa como parametro el nombre que hayas puesto a la ventana de titulo del GUICreate
; Si lo cambias hay que cambiarlo en el singleton tambien

If _Singleton("SCREENSHOTS & TCL TOOL FOR OPENMSX 0.8 (C) 2018 BY DRWH0", 1) = 0 Then
    MsgBox($MB_ICONWARNING, "AVISO DE EJECUCION", "YA HAY UNA INSTANCIA DE SCREENSHOOTER FUNCIONADO")
    Exit
EndIf
;MsgBox($MB_SYSTEMMODAL, "OK", "the first occurrence of test is running")



; Aqui activo el menu

   Opt("GUIOnEventMode", 1)

; Aqui añado un icono para el ejecutable

   #AutoIt3Wrapper_icon=pinguino.ico

;Defino variable de salida

   Global $idExit

   _Main()

Func _Main() ;Funcion principal del menu MAIN <----------- MENU PRINCIPAL ----------->

	Global $idListar, $idEditar, $idFormato, $idTcl, $idRuta, $idDonar, $idEmuweb ; Defino ambito de los nombres de las funciones

 	GUICreate("SCREENSHOTS & TCL TOOL FOR OPENMSX 0.8 (C) 2018 BY DRWH0", 500, 340)

	$idRuta = GUICtrlCreateButton("SELECCIONAR DIRECTORIO DE ROMS", 140, 40, 230, 20)
	GUICtrlSetOnEvent($idRuta, "OnRuta")

    $idFormato = GUICtrlCreateButton("CREAR LISTA AUTOMATIZADA", 140, 80, 230, 20)
	GUICtrlSetOnEvent($idFormato, "OnFormato")

	$idTcl = GUICtrlCreateButton("EJECUTAR SCRIPT", 140, 120, 230, 20)
	GUICtrlSetOnEvent($idTcl, "OnTcl")

	GUICtrlCreateGraphic(140,150,230,1,$SS_SUNKEN) ; SEPARA LAS OPCIONES SECUNDARIAS
	GUICtrlCreateGraphic(0,270,500,1,$SS_BLACKRECT) ; SEPARA LAS ETIQUETAS DE INFORMACION DE RUTA Y DONACION (ARRIBA)
    ;GUICtrlCreateGraphic(0,260,500,1,$SS_BLACKRECT) ; SEPARA LAS ETIQUETAS DE INFORMACION DE RUTA Y DONACION (ABAJO)

	$idEditar = GUICtrlCreateButton("CREAR O EDITAR SCRIPT TCL", 140, 160, 230, 20)
	GUICtrlSetOnEvent($idEditar, "OnEditar")

    $idDonar = GUICtrlCreateButton("DONAR AL AUTOR SI SOY UTIL PARA TI", 140, 200, 230, 20)
	GUICtrlSetOnEvent($idDonar, "Ondonar")

    $idEmuweb = GUICtrlCreateButton("IR A WEB DE RECURSOS DE OPENMSX", 140, 240, 230, 20)
	GUICtrlSetOnEvent($idEmuweb, "Onemuweb")


; Etiquetas meramente informativas del GUI

    GUICtrlCreateLabel("PULSE LOS TRES PRIMEROS BOTONES - DESDE ARRIBA HACIA ABAJO", 60, 10, BitOR ($SS_CENTER, $SS_CENTERIMAGE) )
    GUICtrlCreateLabel('PULSE "SELECCIONAR DIRECTORIO DE ROMS" PARA GENERAR LA LISTA A PROCESAR', 20, 280, BitOR ($SS_CENTER, $SS_CENTERIMAGE) )

; Viejo botón de salida pero es redundante teniendo la X""
	;$idExit = GUICtrlCreateButton("Salir", 160, 60, 50, 20)
	;GUICtrlSetOnEvent($idExit, "OnExit")

; Aqui le digo que si detecta el evento de pulsar el aspa cierre el programa

	GUISetOnEvent($GUI_EVENT_CLOSE, "OnExit")

	GUISetState() ; display the GUI

	While 1
		Sleep(1000)
	 WEnd

EndFunc   ;==>_Main

; --------------- Funciones de los botones, con nombre OnXXXX ---------------

; <----------- CODIGO DE DEBUG DE CONSOLA NO BORRAR ----------->
; La siguiente linea está comentada pues se usaba para debug de comandos
; MsgBox($MB_ICONINFORMATION, "parametro ejecutado ", "" & $CMD)
; EndFunc   ;==>OnListar
; <----------- CODIGO DE DEBUG DE CONSOLA NO BORRAR ----------->

Func Onruta() ; <----------- BOTON "SELECCIONAR DIRECTORIO DE ROMS" ----------->

; Defino la variable Global

   Global $sFileSelectFolder

; Aquí ejecuto un dir que hace el listado en modo compacto y ordenado por orden alfabetico direccionandolo a un fichero de texto")
; El codigo original solo con soporte ZIP---> $PARAMETROS = '*.zip" /b /on >lista.txt'

   $LISTADO = 'dir "' & $sFileSelectFolder & '\'
   $PARAMETROS = '*.zip" /b /on >lista.txt'
   $CMD = $LISTADO & $PARAMETROS ; Basicamente hago un "dir /b /on *.zip >lista.txt" con el cambio nuevo SUPRIMIDO TENDRIA QUE PONER *.*
   RunWait(@ComSpec & " /c " & $CMD , @SW_HIDE) ; Oculto la ventana DOS para que sea mas rapido y bonito añadiendo , @swhide

   Local Const $sMessage = "SELECCIONA EL DIRECTORIO CON TUS FICHEROS DE MSX "
   Global $sFileSelectFolder = FileSelectFolder($sMessage, ".") ; Abro una ventana de dialogo para buscar el directorio de las roms

; Verifico si la ruta se ha especificado o no y en caso contrario selecciono \

   If @error Then ; Si hay error de ruta muestra un mensaje de error y atribuye un valor por defecto aunque estoy por cambiarlo a que vuelva al menu

	  GUICtrlCreateLabel("RUTA SELECCIONADA:" & @CRLF & "" & @CRLF & "NINGUNA - (SE USARA EL DIRECTORIO RAIZ DEL DISCO ACTUAL)", 10, 280, BitOR ($SS_CENTER, $SS_CENTERIMAGE))

   Else

	  GUICtrlCreateLabel("RUTA SELECCIONADA: " & @CRLF & "" & @CRLF & $sFileSelectFolder & "\", 10, 280, BitOR ($SS_CENTER, $SS_CENTERIMAGE))

	  EndIf

;Finalizo el if y ejecuto el comando dos dirigiendolo al fichero lista.txt para su posterior tratamiento

   $LISTADO = 'dir "' & $sFileSelectFolder & '\'
   $PARAMETROS = '*.zip" /b /on >lista.txt'
   $CMD = $LISTADO & $PARAMETROS
   RunWait(@ComSpec & " /c " & $CMD)
   FileDelete ( "tcl.bat" ) ; Borro el TCL.BAT por si este estuviera preexistente y generar uno nuevo sin problemas

EndFunc   ;==>Onruta

Func OnFormato()  ; <----------- BOTON "CREAR LISTA AUTOMATIZADA" ----------->

;~ -CODIGO OBSOLETO CUANDO USABA SED.EXE Y VERIFICABA SU PRESENCIA
;~ if not FileExists("sed.exe") then
;~ 	  MsgBox($MB_ICONERROR, "COMPONENTE NO ENCONTRADO", "NO SE ENCUENTRA SED.EXE" & @CRLF & "REINSTALE LA APLICACION")
;~ 	  	  GUICtrlSetOnEvent($idExit, "OnExit")
;~ 	  Return
;~    Else
;~ EndIf

; Verifico que NO HAYA un TCL.BAT ya generado por si el usuario es un torpon y le ha dado dos veces al generar fichero de lotes

   if FileExists ("tcl.bat") then
	  MsgBox($MB_ICONWARNING, "YA HAS GENERADO ANTES EL SCRIPT", "YA HAS GENERADO EL SCRIPT ANTES" & @CRLF & "" & @CRLF & "NO ES NECESARIO HACERLO DOS VECES", BitOR ($SS_CENTER, $SS_CENTERIMAGE))
	  Return
   Else
	  EndIf

; Verifico que este el fichero de lista lista.txt

   if not FileExists("lista.txt") then
	  MsgBox($MB_ICONERROR, "RUTA NO SELECCIONADA O INVALIDA", "NO SE ENCUENTRA LA LISTA DE ARCHIVOS" & @CRLF & "" & @CRLF & "SELECCIONE DIRECTORIO VALIDO ANTES")
	  GUICtrlSetOnEvent($idExit, "OnExit")
	  Return
   Else
	  EndIf

; Verifico que el lista.txt no tenga tamaño 0 (directorio vacio o malcreado) para ello creo la variable $lista y veo si tiene valor 0

   $lista = "lista.txt"
   $string = FileRead ($lista)

   If $string = "" Then
 	  MsgBox($MB_ICONERROR, "ERROR RECUPERANDO EL LISTADO DE FICHEROS", "EL DIRECTORIO SELECCIONADO NO CONTIENE FICHEROS VALIDOS" & @CRLF & "" & @CRLF & "ASEGURESE DE SELECCIONAR UN DIRECTORIO CORRECTO QUE" & @CRLF & "" & @CRLF & "CONTENGA FICHEROS ZIP VALIDOS", BitOR ($SS_CENTER, $SS_CENTERIMAGE))
	  Return
   Else
	  EndIf

; Cojo el fichero de listado, busco las extensiones .ZIP y las reemplazo con los parametros del openmsx al final del fichero

   $szFile = "lista.txt" ;Defino el fichero
   $szText = FileRead($szFile,FileGetSize($szFile)) ; Indico el fichero a leer con sus atributos lo cargo en memoria y le asigno un valor

; Reemplazo la cadena que haya al final de cada linea con los parametros (pero solo los formatos admitidos, asi corrijo la guarreria)
; Comento dicho codigo porque no se manejan dobles o multiples extensiones validas dentro del mismo nombre de fichero

   $szText = StringReplace($szText, ".zip", '.zip" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".mx1", '.mx1" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".mx2", '.mx2" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".dsk", '.dsk" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".rom", '.rom" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".tsx", '.tsx" -script autoscr.tcl')
   ;$szText = StringReplace($szText, ".cas", '.cas" -script autoscr.tcl')

   FileDelete($szFile)        ;Borro el fichero del disco
   FileWrite($szFile,$szText) ;Escribo el fichero modificado en memoria

;~ ------------------------; CODIGO OBSOLETO DE CUANDO USABA SED, AHORA LO SUSTITUYO POR UNA MATRIZ CON UN BUCLE DINAMICO
;;$CMD = 'sed -i -e "s/^/openmsx /" lista.txt'
;;RunWait(@ComSpec & " /c " & $CMD)
;~ ---------- fin de codigo obsoleto

; Aqui añado texto al inicio de cada linea

   Local $aArray ; DEFINO LA MATRIZ DEL FICHERO Y CREO UN FICHERO TEMPORAL LISTA2.TXT POR SI CASCA ALGO

   $sFileName = "lista.txt"
   $sNewFileName = "lista2.txt"

; Aqui defino lo que añado al principio de cada linea que es openmsx.exe " y concatenado el valor del directorio y concateno el simbolo \

   $sPrePend = 'openmsx.exe "' & $sFileSelectFolder & "\"
   $hNewFile = FileOpen($sNewFileName, 1)
   _FileReadToArray($sFileName, $aArray)

; Aqui comienzo el iterativo del array

   For $i = 1 To $aArray[0]
    FileWriteLine($hNewFile, $sPrePend & $aArray[$i])
   Next

   FileClose($hNewFile) ; Cierro el fichero lista2.txt

; Renombre el lista2.txt a lista.txt y sigo con el resto de sustituciones de texto

   FileMove ("lista2.txt", "lista.txt", $FC_OVERWRITE + $FC_CREATEPATH)

; Aqui añado texto al final de cada linea

   $szFile = "lista.txt"
   $szText = FileRead($szFile,FileGetSize($szFile)) ; Indico el fichero a leer con sus atributos lo cargo en memoria y le asigno un valor
   $szText = StringReplace($szText, "openmsx ", 'openmsx "') ;Reemplazo la cadena que haya al final de cada linea con los parametros

   FileDelete($szFile) ;Borro el fichero del disco
   FileWrite($szFile,$szText) ;Escribo el fichero modificado final en memoria de nuevo porque yo lo valgo para futura funcionalidad de ruta del emulador
   FileMove ("lista.txt", "tcl.bat", $FC_OVERWRITE + $FC_CREATEPATH) ;Renombro el fichero y creo el fichero de lotes que llama al TCL, o sea ahora renombre el lista.txt a tcl.bat

; Nueva ruta especificada vuelvo a abrir y sustituir openmsx " con el valor de la variable $sFileSelectFolder

   $szFile = "tcl.bat"
   $szText = FileRead($szFile,FileGetSize($szFile))
   $szText = StringReplace($szText, 'openmsx "', 'openmsx "' & $sFileSelectFolder & "\")

;$szText = StringReplace($szText, 'openmsx "', $sFileSelectFolder)

   FileDelete($szFile)
   FileWrite($szFile,$szText)

; INSERTO UNA CABECERA VARIABLE DEL CABECERA.TXT PARA PERSONALIZAR EL .BAT

   _FileWriteToLine("tcl.bat", 1, '@ECHO OFF', 0)
   _FileWriteToLine("tcl.bat", 2, 'TITLE INICIANDO SCRIPT - CIERRE ESTA VENTANA PARA ABORTAR', 0)
   _FileWriteToLine("tcl.bat", 3, 'CLS', 0)
   _FileWriteToLine("tcl.bat", 4, 'ECHO.', 0)

;Notificación de finalización con 3 sg de timeout

   MsgBox($MB_ICONINFORMATION, "GENERACION DE AUTOMATIZACION COMPLETADA", "FICHERO DE AUTOMATIZADO GENERADO EXITOSAMENTE",3)

;Vuelvo al menu principal una vez generado el .bat

   Return

EndFunc   ;==>Onformato

Func OnEditar() ; <----------- BOTON "CREAR O EDITAR SCRIPT TCL" ----------->

; Editamos el TCL, pero si no hay ninguno creo uno nuevo

; Si el fichero no existe creo uno nuevo con 5 lineas añadidas y luego abro el TCL con el notepad

   if not FileExists("autoscr.tcl") then
	  _FileCreate("autoscr.tcl")
	  $szFile2 = "autoscr.tcl"

; Las lineas de marras para el TCL

	  FileWriteLine("autoscr.tcl", "# <----------------------- INICIO DEL FICHERO TCL ------------------------------->" & @CRLF)
      FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# La documentación está disponible en https://openmsx.org/manual/commands.html" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "set throttle off" & @CRLF)
	  FileWriteLine("autoscr.tcl", "set mute on" & @CRLF)
	  FileWriteLine("autoscr.tcl", "after time 15 {screenshot -raw -guess-name; exit}" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# Atención debes usar la última versión de Notepad de Windows 10 o Nano/Vim ya que" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# versiones anteriores no soportan el formato de cambio de linea Unix usado por" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# OpenMSX es decir @LF en vez de @CR que sólo se usa en Windows y el script fallará.." & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# También puedes escribir en estas lineas con # al principio y borrar el simbolo # al final" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# pero sin pulsar ENTER para cambiar de linea si lo haces es posible sortear esta limitación" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# <--------------------- Fichero autogenerado por Screenshooter ----------------->" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# <----------------------- FINAL DEL FICHERO TCL -------------------------------->" & @CRLF)

	; FileWrite("autoscr.tcl") Comentado porque lo pongo con FileClose
	  FileClose ($szFile2) ; Cerramos el fichero con las modificaciones autoscr.tcl si estuviera vacio
	  EndIf

; Abro el notepad y edito el autoscr.tcl
   $sRun = "notepad autoscr.tcl"
   Run($sRun)

EndFunc   ;==>Onditar


Func OnTcl() ; <-----------BOTON "EJECUTAR SCRIPT" ----------->

; Funciones a realizar en el TCL con el lenguaje de scripting del openmsx

; Verifico otra vez si el fichero no existe y creo uno nuevo con 5 lineas añadidas

	if not FileExists("autoscr.tcl") then
	_FileCreate("autoscr.tcl")
    $szFile2 = "autoscr.tcl"

; Las lineas de marras para el TCL

	  FileWriteLine("autoscr.tcl", "# <----------------------- INICIO DEL FICHERO TCL ------------------------------->" & @CRLF)
      FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# La documentación está disponible en https://openmsx.org/manual/commands.html" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "set throttle off" & @CRLF)
	  FileWriteLine("autoscr.tcl", "set mute on" & @CRLF)
	  FileWriteLine("autoscr.tcl", "after time 15 {screenshot -raw -guess-name; exit}" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# Atención debes usar la última versión de Notepad de Windows 10 o Nano/Vim ya que" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# versiones anteriores no soportan el formato de cambio de linea Unix usado por" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# OpenMSX es decir @LF en vez de @CR que sólo se usa en Windows y el script fallará.." & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# También puedes escribir en estas lineas con # al principio y borrar el simbolo # al final" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# pero sin pulsar ENTER para cambiar de linea si lo haces es posible sortear esta limitación" & @CRLF)
	  FileWriteLine("autoscr.tcl", "#" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# <--------------------- Fichero autogenerado por Screenshooter ----------------->" & @CRLF)
	  FileWriteLine("autoscr.tcl", "# <----------------------- FINAL DEL FICHERO TCL -------------------------------->" & @CRLF)

    ; FileWrite("autoscr.tcl") Comentado porque lo pongo con FileClose

; Cerramos el fichero con las modificaciones autoscr.tcl

   FileClose ($szFile2)
   Else
	  EndIf

; <--OBSOLETO--> Verificaciones de ficheros, en este if busco el sed.exe
; <--OBSOLETO--> if not FileExists("sed.exe") then
; <--OBSOLETO--> MsgBox($MB_ICONERROR, "COMPONENTE NO ENCONTRADO", "NO SE ENCUENTRA SED.EXE" & @CRLF & "REINSTALE LA APLICACION")
; <--OBSOLETO--> GUICtrlSetOnEvent($idExit, "OnExit")
; <--OBSOLETO--> Return
; <--OBSOLETO--> Else
; <--OBSOLETO--> EndIf

; Comprobar si openmsx.exe y si no encuentro el emulador en la ruta actual mando una ventana de error

   if not FileExists("openmsx.exe") then
	  MsgBox($MB_ICONERROR, "OPENMSX NO ENCONTRADO", "NO SE ENCUENTRA EL FICHERO DEL EMULADOR OPENMSX.EXE" & @CRLF & @CRLF & "" & "HA INSTALADO LA APLICACION EN UN DIRECTORIO DIFERENTE" & @CRLF & "" & "COPIE LOS FICHEROS DEL PROGRAMA DONDE ESTE OPENMSX")
	  Return
   Else
	  EndIf

; Comprobar si ademas del SED.EXE, OPENMSX.EXE existe el TCL.BAT y si no esta mando esta ventana de error
   if not FileExists("tcl.bat") then
	  MsgBox($MB_ICONERROR, "FICHERO DE AUTOMATIZACION NO ENCONTRADO", "NO SE ENCUENTRA EL FICHERO PARA AUTOMATIZACION" & @CRLF & @CRLF & "" & "ASEGURATE DE HABER SELECCIONADO LA RUTA DE ROMS ANTES " & @CRLF & @CRLF & "" & "Y CREADO EL FICHERO AUTOMATIZACION")
	  Return
   Else
   	  EndIf

; Fin de comprobacion de openmsx.exe, tcl.bat y sed.exe

; Ejecucion del .bat que se ejecuta una vez aseguradas las dependencias (autoscr.tcl, OPENMSX.EXE SED.EXE) con el script tcl creado

; MsgBox($MB_ICONWARNING, "LA AUTOEJECUCION SE INICIARA DENTRO DE 5 SEGUNDOS", "CIERRE ESTA VENTANA SI DESEA CANCELAR" & @CRLF & "" & @CRLF & "PULSE ACEPTAR O ESPERE PARA INICIAR" & @CRLF & "" & @CRLF & "PUEDE CANCELAR PULSANDO CTRL+C EN LA VENTANA TERMINAL" ,5)
   ;MsgBox($MB_ICONWARNING, "INICIANDO EN 10 SEGUNDOS", "CIERRE ESTA VENTANA SI DESEA CANCELAR" & @CRLF & "" & @CRLF & "PULSE ACEPTAR O ESPERE PARA CONTINUAR" & @CRLF & "" & @CRLF & "PUEDE DETENER EL PROCESO CERRANDO LA VENTANA" & @CRLF & "" & @CRLF & "DE INFORMACION MINIMIZADA EN LA BARRA DE TAREAS",10)
   GUICtrlCreateLabel("SCRIPT EN MARCHA.................................................." & @CRLF & "" & @CRLF & "" , 10, 280, BitOR ($SS_CENTER, $SS_CENTERIMAGE))
   GUICtrlCreateLabel('CIERRE LA VENTANA DE INFORMACION DOS PARA CANCELAR', 10, 300, BitOR ($SS_CENTER, $SS_CENTERIMAGE) )

; Deshabilito los botones que puedan causar problemas

GUICtrlSetState($idFormato, $GUI_DISABLE)
GUICtrlSetState($idTcl, $GUI_DISABLE)
GUICtrlSetState($idRuta, $GUI_DISABLE)



$CMD = "tcl.bat"
   RunWait(@ComSpec & " /c " & $CMD , @ScriptDir, @SW_MINIMIZE) ;Aqui ejecuto y minimizo la debug windows o sea el script que estoy ejecutando
   GUICtrlCreateLabel("SCRIPT FINALIZADO.................................................." & @CRLF & "" & @CRLF & "" , 10, 280, BitOR ($SS_CENTER, $SS_CENTERIMAGE))
   GUICtrlCreateLabel('PULSE "SELECCIONAR DIRECTORIO DE ROMS" PARA COMENZAR DE NUEVO', 10, 300, BitOR ($SS_CENTER, $SS_CENTERIMAGE) )

; Fin del proceso

   MsgBox($MB_ICONINFORMATION, "FINALIZADO", "SE HA TERMINADO CON LA EJECUCION DEL SCRIPT")

; Y luego lo borro el .bat

    Local $iDelete = FileDelete("TCL.BAT")

; Habilito de nuevo los botones ya que ahora no pueden dar problemas

GUICtrlSetState($idFormato, $GUI_ENABLE)
GUICtrlSetState($idTcl, $GUI_ENABLE)
GUICtrlSetState($idRuta, $GUI_ENABLE)


EndFunc   ;==>Fin de funcion

Func OnDonar() ; <----------- BOTON "DONAR AL AUTOR SI SOY UTIL PARA TI" ----------->

; Funcion para ir a paypal y que me donen dinerito

   ShellExecute("https://www.paypal.me/CarlosRom") ; Abro el navegador por defecto a mi paypal
   Return

EndFunc   ;==>OnExit

Func OnEmuweb() ; <----------- BOTON "IR A WEB DE RECURSOS DE OPENMSX" ----------->
; Funcion para ir a la web del openmsx

; Abro el navegador por defecto a http://openmsx.org/

   ShellExecute("http://openmsx.org/")

Return

EndFunc   ;==>OnExit

Func OnExit()

;Funcion de salida con algo de debug puesto

; Si estan los procesos del openmsx.exe y/o del script activos los cierra antes de salir para evitar catastrofes ;)


   If ProcessExists("tcl.bat") Then
	  ProcessClose ("tcl.bat")  ; Verifico si esta el openmsx.exe andando y lo mato con saña
   Else
	  EndIf

   If ProcessExists("openmsx.exe") Then
	  ProcessClose ("openmsx.exe")  ; Verifico si esta el openmsx.exe andando y lo mato con saña
   Else
	  EndIf

; Borro cualquier fichero temporal que pudiera haber quedado

   FileDelete ( "lista.txt" )
   FileDelete ( "lista2.txt" )
   FileDelete ( "tcl.bat" )

   Exit ; El comando de salida propiamente dicho

; <--OBSOLETO--> If @GUI_CtrlId = $idExit Then
; <--OBSOLETO--> MsgBox($MB_SYSTEMMODAL, "Pinchaste en", "Exit")
; <--OBSOLETO--> experimentos con modales y codigos de error
; <--OBSOLETO--> Else
; <--OBSOLETO--> MsgBox($MB_SYSTEMMODAL, "Pinchaste en", "Close")

EndFunc   ;==>OnExit

