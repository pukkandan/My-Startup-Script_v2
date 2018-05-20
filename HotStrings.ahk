;===================    Sort chars
RETURN
::z»::{U+0370} ;z' = Heta :Succedes letters in sorting
::0»::{U+263A} ;0' = Smiley :Precedes numbers in sorting
return

;===================    Hot Strings
RETURN
::@»::@gmail.com
::m»::magnet:?xt=urn:btih:
return

;===================    Brackets
RETURN
#If WinActive("ahk_group AutoBracket")
:b0:{}::
:b0:[]::
:b0:<>::
:b0:()::
:b0:""::
:b0:''::
:b0:````::
:b0:%%::
Send("{Left}")
return
; :b0:`n`n::
; Send("{Up}{Tab}")
; return
#If