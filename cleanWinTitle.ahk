cleanWinTitle(win:="A",max_len:=90){

    title:=WinGetTitle(win), exe:=WinGetProcessName(win), path:=WinGetProcessPath(win)
    if (exe="hh.exe") ; hh.exe is the name of chm reader
        exe:="CHM"
    else if (exe="Applicationframehost.exe") { ; Metro App
        path:="C:\Windows\System32\consent.exe" ; For Icon
        exe:=""
    }
    exe:=Format("{:T}",StrReplace(StrReplace(exe, ".exe"),"_"," ")) ; "sublime_text.exe" to "Sublime Text" etc
    if exe
        title:="[" exe "]> " StrReplace(title, " - " exe) ; Remove " - Sublime Text" etc
    title:=(strLen(title)>max_len? SubStr(title, 1, max_len-3) "..." :title) " " this.win_hwnd ; Limit Size. win_hwnd is added for uniqueness

    return title
}