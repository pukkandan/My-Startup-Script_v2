;===================    Sort chars
RETURN
::z»::{U+0370} ; Ͱ Heta :Succedes letters in sorting
::0»::{U+263A} ; ☺ Smiley :Precedes numbers in sorting
return

;===================    Hot Strings
RETURN
::@::@gmail.com
::m::magnet:?xt=urn:btih:
return

;===================    Brackets
RETURN
#hotIf WinActive("ahk_group AutoBracket")
:*B0O0:{}::
:*B0O0:[]::
:*B0O0:()::
:*B0O0:""::
:*B0O0:''::
:*B0O0:````::
:*B0O0:%%::
:*B0O0:$$:: {
	Send("{Left}")
}

:*B0O0:<>:: {
	if !winActive("ahk_exe Mathematica.exe")
	    Send("{Left}")
}

; :B0O0:`n`n::
; Send("{Up}{Tab}")
; return
#hotIf

;===================    Paste Trackers
RETURN
::tr»:: pasteTrackers(file:="trackers.txt")

pasteTrackers(file:="trackers.txt"){
    clip.save(True)
   ,clip.put(FileRead(file))
   ,send("^v")
   ,sleep 100
   ,clip.recover(True)
}