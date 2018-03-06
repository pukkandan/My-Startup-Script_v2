isFullScreen(title:="A", pseudo:=0) {
    if (! win:=winExist(title))
        return false
    win:="ahk_id " win
    WinGetPos(x, y, w, h, win)

    if (!WinGetMinMax(win) OR pseudo=1) AND x=0 AND y=0 AND w=A_ScreenWidth AND h=A_ScreenHeight {
        if WinGetClass(win)="Progman" OR WinGetClass(win)="WorkerW" OR subStr(WinGetProcessName(win),-3)="scr"
            return false
        return true
    }
    return false
}