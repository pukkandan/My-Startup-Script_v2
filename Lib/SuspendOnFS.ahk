suspendOnFS(force:=False){
    if force OR isFullScreen() {
        Suspend(True)
        loop 20 ;Remove all tooltips
            Tooltip(,,,A_Index)
        Timer.pauseAll()
        Timer.set("resumeOnWin",100)
    }
    return
}
resumeOnWin(force:=False){
    if force OR !isFullScreen() {
        Suspend(False)
        Timer.resumeAll()
        try Timer.stop(A_ThisFunc)
    }
    return
}