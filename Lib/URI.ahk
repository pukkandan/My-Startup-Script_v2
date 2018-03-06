; Modified by GeekDude from http://goo.gl/0a0iJq
URI_Encode(URI, RE:="[0-9A-Za-z]") {
    VarSetCapacity(v, StrPut(URI, "UTF-8"), 0), StrPut(URI, &v, "UTF-8")
    While Code := NumGet(v, A_Index - 1, "UChar")
        Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
    Return Res
}

URI_Decode(URI) {
    Pos := 1
    While(Pos:= RegExMatch(URI, "i)(%[\da-f]{2})+", code, Pos))
    {
        VarSetCapacity(v, StrLen(code) // 3, 0)
       ,code:= SubStr(code.0,2)
        Loop Parse, code, "%"
            NumPut("0x" A_LoopField, &v, A_Index-1, "UChar")
        Decoded:= StrGet(&v, "UTF-8")
       ,URI:= SubStr(URI, 1, Pos-1) . Decoded . SubStr(URI, Pos+StrLen(code)+1)
       ,Pos+= StrLen(Decoded)+1
    }
    return URI
}

;----------------------------------

URI_URLEncode(URL) { ; keep ":/;?@,&=+$#."
    return URI_Encode(URL, "[0-9a-zA-Z:/;?@,&=+$#.]")
}

URI_URLDecode(URL) {
    return URI_Decode(URL)
}

;Msgbox(URI_Encode("hi hello what"    ))
;Msgbox(URI_Decode("hi%20hello%20what"))