#include Clip.ahk
#include ReplaceList.ahk

sendTo_pasteText(text:="", win:=0, controlName:="", opt:="") {
    if !text
        return False

    static opt0:={resetClip:True, resetClipFull:False, useOldClip:False, keepClip:False}
    opt:=replaceList(opt0, opt), opt.raw:=False

    if opt.resetClip AND !opt.useOldClip
        clip.save(opt.resetClipFull)
   Clipboard:=text ,clipWait(), ret:=sendTo("+{Insert}", win, controlName, opt)
    if opt.resetClip
        clip.recover(!keepClip)
    return ret
}


sendTo(key, title:=" ", controlName:="", opt:=""){    ; Pass title:="" to use last found window, " " to not use any window
    static opt0:={sendWithoutProg:True, raw:False, hiddenWindows:False, focusControl:True, activateWindow:False, sendToAll:False}
    opt:=replaceList(opt0, opt)

    A_DetectHiddenWindows:=opt.hiddenWindows
   ,returnValue:=(winList:= opt.sendToAll? WinGetList(title): title=" "?[WinExist(title)]:[] ).length()

    for _,win in  winList {
        if win!=0 {
            win:="ahk_id " win
            if opt.activateWindow
                WinActivate(win)
            if opt.focusControl
                ControlFocus(controlName, win)
            opt.raw? ControlSendRaw(key, controlName, win): ControlSend(key, controlName, win)
        }
        else returnValue--
    }

    if (opt.SendWithoutProg OR title=0) AND !returnValue++
        opt.raw? sendRaw(key): send(key)

    return returnValue
}