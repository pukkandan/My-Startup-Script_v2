;===================    Sort chars
RETURN
::z»::{U+0370} ;z' = Heta Ͱ :Succedes letters in sorting
::0»::{U+263A} ;0' = Face ☺ :Precedes numbers in sorting
return

;===================    Hot Strings
RETURN
::@»::@gmail.com
::m»::magnet:?xt=urn:btih:
return

;===================    Paste Trackers from Ditto
RETURN
::tr»::
send("#+^t") ;My Ditto is set up to paste a tracker list on pressing #+^t
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