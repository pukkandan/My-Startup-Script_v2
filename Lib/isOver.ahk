isOver_mouse(WinTitle:="A"){ ;If ahk_id is passed, dont use ahk_id prefix or any other options
    MouseGetPos(,, Win)
    if WinTitle is "number"
        return (win==WinTitle)
    else return WinExist(WinTitle " ahk_id " Win)
}

isOver_coord(win,pos){
    A_CoordModeMouse:="Screen"
   ,WinGetPos(x, y, w, h, win)
    if (pos[1]>=x) AND (pos[1]<=x+w) AND (pos[2]>=y) AND (pos[2]<=y+h)
        return True
    return false
}