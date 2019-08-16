;script pesca v1.0 Obus
version := "1.0.1 (Obus)"
titulo = I'm Batman %version%

if A_IsCompiled
  Menu, Tray, Icon, BATMAN.ico, -159

IfExist, settings.ini
existe := 1
IfNotExist, settings.ini
existe := 0

IfExist, sesion.log
FileDelete, sesion.log

Gui,+AlwaysOnTop
Gui, Add, Text, x15 y20 w100 h100, F9 = setear zona`rF10 = Pausar script`rF11 = Reiniciar script`rF12 = salir
Gui, Add, Edit, x15 y75 w175 h100 vLogbox readonly,
Gui, font,bold
Gui, Add, Text, x15 y199 w165 h20, Version: %version%
Gui, Show, % "x" 0 " y" 0 " w" 200 " h" 220, %titulo%

If (existe == 0){
	;InputBox,logfile,Fichero logs.txt,Selecciona la ruta absoluta del fichero log.txt`rEjemplo: E:\Documentos\RIFT\log.txt
	FileSelectFile, logfile
	IniWrite %logfile%, settings.ini,logfile
} Else {
	IniRead logfile, settings.ini, logfile
	updatelog("Fichero settigs.ini cargado correctamente")
	updatelog("Ruta Log.txt: "logfile)
}


WinGet Gui_ID, ID, A 
GuiControl Focus, logbox
ControlGetFocus logboxclass, ahk_id %Gui_ID% 

lure := 0

Main:

RodL := 1
BaitL := 2

F8::MouseGetPos, canyaX, canyaY
F9::
MouseGetPos, ratonX, ratonY
updatelog("Posicion fijada")
Inicio:
IfWinNotActive, RIFT, , WinActivate, RIFT,
WinWaitActive, RIFT,

Random, randX, 0, 25
Random, randY, 0, 25
posX := (randX+ratonX)
posY := (randY+ratonY)
FileDelete, %logfile%
Last_Line :=0
if lure = 1
Goto, bait
updatelog("Casteando...")
Timer := A_TickCount
MouseMove, posX, posY, 20
Sleep, 1000
Send, %RodL%
Sleep, 400
MouseClick, left, posX, posY
Sleep, 200
CurrentMouseCode := QueryMouseCursor()

bucle:
Loop
	{
		If (FishMouseCode = "")
		{
			While (FishMouseCode = "")
			{
				If (QueryMouseCursor() != CurrentMouseCode)
				FishMouseCode := QueryMouseCursor()
			}
		}
		Else If (QueryMouseCursor() = FishMouseCode)
		{
			updatelog("Intento de captura...")
			Sleep, 200
			Send, %RodL%
			Sleep, 500
		}
		Else
		{
			FileRead, last_line, %logfile%
			Sleep, 200
			IfInString, Last_Line, away
			Goto, Inicio
			IfInString, Last_Line, lure has decayed
			{
				;updatelog("Lure has decayed")
				lure :=1
			}
			IfInString, Last_Line, stop fishing
			Goto, Inicio
			IfInString, Last_Line, received
			{
				updatelog("Received!")
				Goto, Inicio
			}
			If A_TickCount - Timer < 20000
			Goto, bucle
		}
	}
	
QueryMouseCursor(byRef numP=0)
{
	NumPut(VarSetCapacity(CurrentCursorStruct, A_PtrSize + 16), CurrentCursorStruct, "uInt")
	DllCall("GetCursorInfo", "ptr", &CurrentCursorStruct)
	return (numP:=NumGet(CurrentCursorStruct,  8))
}
return

updatelog(LogString)
{
 global logboxclass
 global Gui_ID
 GuiControlGet, logbox, , logbox
 FormatTime, timestamp, A_Now, HH:mm:ss
 guicontrol,,logbox, %logbox%`n%timestamp%: %logstring%
 ControlSend %logboxclass%, ^{End}, ahk_id %Gui_ID% ;Cou
 FileAppend, `n%timestamp%: %logstring%, sesion.log
}
queryURL(url){
                req := ComObjCreate("Msxml2.XMLHTTP")
                req.open("GET", url, true)
                req.send()
                while (req.readyState != 4){
                               Sleep, 1000
                }
                return req.responseText
}
Bait:
{
        lure :=0
		updatelog("Aplicando lure")
        Sleep, 200
        Send, %BaitL%
        Sleep, 200
		
		If (QueryMouseCursor() = CurrentMouseCode)
		{
			Goto, Inicio
		}
		Else
		{
			MouseClick, left, canyaX, canyaY
			Sleep, 4000
			updatelog("lure aplicado!")
			Goto, Inicio
		}
}

;Funcion captura de cursor

;Bindeos
F10::Pause
F11::Reload
F12::ExitApp