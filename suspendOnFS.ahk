suspendOnFS(){
    if isFullScreen()
    {
        Suspend(True)
       ,setTimer("hotcorners", "Off")
       ,setTimer(, "Off")
       ,setTimer("resumeOnWin", "100")
    }
    return
}
resumeOnWin(){
    if !isFullScreen()
    {
        Suspend(False)
       ,setTimer("hotcorners", "On")
       ,setTimer(, "Off")
       ,setTimer("suspendOnFS", "On")
    }
    return
}