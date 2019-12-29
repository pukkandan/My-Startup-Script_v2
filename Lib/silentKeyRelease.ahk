silentKeyRelease_Mouse(key:="L",delay:=100){
    return setTimer(func("_silentKeyRelease_Mouse").bind(key), -delay)
}
_silentKeyRelease_Mouse(key){
    return ControlClick(, "ahk_pid 0",, key,, "U")
}