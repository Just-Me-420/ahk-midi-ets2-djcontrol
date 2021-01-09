;;"#defines"
DeviceID := 0
CALLBACK_WINDOW := 0x10000


#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

Gui, +LastFound
hWnd := WinExist()



MsgBox, hWnd = %hWnd%`nPress OK to open winmm.dll library

OpenCloseMidiAPI()
OnExit, Sub_Exit


MsgBox, winmm.dll loaded.`nPress OK to open midi device`nDevice ID = %DeviceID%`nhWnd = %hWnd%`ndwFlags = CALLBACK_WINDOW

hMidiIn =
VarSetCapacity(hMidiIn, 4, 0)

result := DllCall("winmm.dll\midiInOpen", UInt,&hMidiIn, UInt,DeviceID, UInt,hWnd, UInt,0, UInt,CALLBACK_WINDOW, "UInt")

If result
{
	MsgBox, error, midiInOpen returned %result%`n
	GoSub, sub_exit
}

hMidiIn := NumGet(hMidiIn) ; because midiInOpen writes the value in 32 bit binary number, AHK stores it as a string


MsgBox, Midi input device opened successfully`nhMidiIn = %hMidiIn%`n`nPress OK to start the midi device

result := DllCall("winmm.dll\midiInStart", UInt,hMidiIn)
If result
{
	MsgBox, error, midiInStart returned %result%`n
	GoSub, sub_exit
}


;	#define MM_MIM_OPEN         0x3C1           /* MIDI input */
;	#define MM_MIM_CLOSE        0x3C2
;	#define MM_MIM_DATA         0x3C3
;	#define MM_MIM_LONGDATA     0x3C4
;	#define MM_MIM_ERROR        0x3C5
;	#define MM_MIM_LONGERROR    0x3C6

OnMessage(0x3C1, "midiInHandler")
OnMessage(0x3C2, "midiInHandler")
OnMessage(0x3C3, "midiInHandler")
OnMessage(0x3C4, "midiInHandler")
OnMessage(0x3C5, "midiInHandler")
OnMessage(0x3C6, "midiInHandler")



return


sub_exit:

If (hMidiIn)
	DllCall("winmm.dll\midiInClose", UInt,hMidiIn)
OpenCloseMidiAPI()

ExitApp

;--------End of auto-execute section-----
;----------------------------------------


OpenCloseMidiAPI() {
   Static hModule 
   If hModule 
      DllCall("FreeLibrary", UInt,hModule), hModule := "" 
   If (0 = hModule := DllCall("LoadLibrary",Str,"winmm.dll")) { 
      MsgBox Cannot load library winmm.dll 
      ExitApp
   } 
} 



midiInHandler(hInput, midiMsg, wMsg) 
{

	statusbyte := midiMsg & 0xFF
	byte1 := (midiMsg >> 8) & 0xFF
	byte2 := (midiMsg >> 16) & 0xFF
	byte3 := (8335536)
	byte4 := (78000)
	byteLL := (8335792)
	byteLR := (78256)
	byteR := (8327056)
	byteL := (8326800)
	byteSp := (8327824)
	byteW := (8333712)
	byteWR := (10640)
	byteS := (8333968)
	byteSR := (10896)
	byteC := (8334480)
	byteInc := (8326032)
	byteDec := (8325776)
	byteNum5 := (8333200)
	byteEsc := (8328080)

	if (midiMsg == byte4)
	{
		;MouseMove, 1, 0, 0, R
		LLMouse.Move(1, 0, 1, 1)
	}
	if (midiMsg == byte3)
	{		
		;MouseMove, -1, 0, 0, R
		LLMouse.Move(-1, 0, 1, 1)
	}

	if (midiMsg == byteLR)
	{
		;send, {insert down}
		;sleep, 50
		LLMouse.Move(5, 0, 1, 1)
		;sleep, 50
		;send, {insert up}
	}
	if (midiMsg == byteLL)
	{		
		;send, {insert down}
		;sleep, 50
		LLMouse.Move(-5, 0, 1, 1)
		;sleep, 50
		;send, {insert up}
	}
	if (midiMsg == byteR)
	{
		send ]
	}
	if (midiMsg == byteL)
	{		
		send [
	}
		if (midiMsg == byteSp)
	{		
		send {space}
	}
	if (midiMsg == byteW)
	{
		send, {w down}		
	}
	if (midiMsg == byteWR)
	{	
		sleep, 50
		send, {w up}		
	}

	if (midiMsg == byteS)
	{
		send, {s down}		
	}
	if (midiMsg == byteSR)
	{
		sleep, 50
		send, {s up}		
	}
		if (midiMsg == byteC)
	{
		send c		
	}
			if (midiMsg == byteInc)
	{
		send {up}		
	}
		if (midiMsg == byteDec)
	{
		send {down}		
	}
	if (midiMsg == byteNum5)
	{
		send {Numpad5}		
	}
	if (midiMsg == byteEsc)
	{
		send {Esc}		
	}



		;ToolTip,
		;(
		;lParam = %midiMsg%	
		;)

}


	

































; =========== Sample script ============================================================
#SingleInstance,Force

; Send 2x mouse wheel down rolls at rate of 100ms 
F11::
	LLMouse.Move(-1, 0, 10, 2)
	return

; Send 100x 10 unit mouse moves for the x axis at a rate of 2ms
F12::
	LLMouse.Move(1, 0, 10, 2)
	return

; =======================================================================================
; LLMouse - A library to send Low Level Mouse input

; Note that many functions have time and rate parameters.
; These all work the same way:
; times	- How many times to send the requested action. Optional, default is 1
; rate	- The rate (in ms) to send the action at. Optional, default rate varies
; Note that if you use a value for rate of less than 10, special code will kick in.
; QPX is used for rates of <10ms as the AHK Sleep command does not support sleeps this short
; More CPU will be used in this mode.
class LLMouse {
	static MOUSEEVENTF_MOVE := 0x1
	static MOUSEEVENTF_WHEEL := 0x800
	
	; ======================= Functions for the user to call ============================
	; Move the mouse
	; All values are Signed Integers (Whole numbers, Positive or Negative)
	; x		- How much to move in the x axis. + is right, - is left
	; y		- How much to move in the y axis. + is down, - is up
	Move(x, y, times := 1, rate := 1){
		this._MouseEvent(times, rate, this.MOUSEEVENTF_MOVE, x, y)
	}
	
	; Move the wheel
	; dir	- Which direction to move the wheel. 1 is up, -1 is down
	Wheel(dir, times := 1, rate := 10){
		static WHEEL_DELTA := 120
		this._MouseEvent(times, rate, this.MOUSEEVENTF_WHEEL, , , dir * WHEEL_DELTA)
	}
	
	; ============ Internal functions not intended to be called by end-users ============
	_MouseEvent(times, rate, dwFlags := 0, dx := 0, dy := 0, dwData := 0){
		Loop % times {
			DllCall("mouse_event", uint, dwFlags, int, dx ,int, dy, uint, dwData, int, 0)
			if (A_Index != times){	; Do not delay after last send, or if rate is 0
				if (rate >= 10){
					Sleep % rate
				} else {
					this._Delay(rate * 0.001)
				}
			}
		}
	}
	
	_Delay( D=0.001 ) { ; High Resolution Delay ( High CPU Usage ) by SKAN | CD: 13/Jun/2009
		Static F ; www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 13/Jun/2009
		Critical
		F ? F : DllCall( "QueryPerformanceFrequency", Int64P,F )
		DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
		While( ( (Tick:=(pTick-cTick)/F)) <D ) {
			DllCall( "QueryPerformanceCounter", Int64P,pTick )
			Sleep -1
		}
		Return Round( Tick,3 )
	}
}