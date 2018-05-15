suspendOnFS(){
    if isFullScreen() {
        Suspend(True)
        Timer.pauseAll()
        if !Timer.resume("resumeOnWin")
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