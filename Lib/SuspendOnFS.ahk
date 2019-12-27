suspendOnFS(force:=False, except:=""){
    if force OR isFullScreen() {
        for _,win in except
            if WinActive(win)
                return
        Suspend(True)
        loop 20 ;Remove all tooltips
            Tooltip(,,,A_Index)
        Timer.pauseAll()
        if !force
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