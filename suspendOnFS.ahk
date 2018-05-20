suspendOnFS(){
    if isFullScreen() {
        Suspend(True)
        loop 20 ;Remove all tooltips
            Tooltip(,,,A_Index)
        Timer.pauseAll()
        Timer.set("resumeOnWin",100)
    }
    return
}
resumeOnWin(){
    if !isFullScreen() {
        Suspend(False)
        Timer.resumeAll()
        Timer.stop(A_ThisFunc)
    }
    return
}