;===================    Sort chars
RETURN
::z::{U+0370} ; Ͱ Heta :Succedes letters in sorting
::0::{U+263A} ; ☺ Smiley :Precedes numbers in sorting
return

;===================    Hot Strings
RETURN
::@::@gmail.com
::m::magnet:?xt=urn:btih:
return

;===================    Brackets
RETURN
#If WinActive("ahk_group AutoBracket")
:*B0O0:{}::
:*B0O0:[]::
:*B0O0:<>::
:*B0O0:()::
:*B0O0:""::
:*B0O0:''::
:*B0O0:````::
:*B0O0:%%::
Send("{Left}")
return
; :B0O0:`n`n::
; Send("{Up}{Tab}")
; return
#If