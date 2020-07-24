; COMPLETELY REWRITE

;===================    R/M Button
RETURN
#hotIf getKeyState("RButton","P")
LButton:: sendWindowBack()                  ; Switch to next window
;send("!{Tab}") ; From rs5, Alt Tab does not show the TaskSwitcher Window when used quickly. Also, the other method behaves unexpectedly with sets
/*
*
sendWindowBack() { ;Alt Tab is not used since it shows the TaskSwitcher Window
    activeID:=WinGetID("A"), ids:=WinGetList()
    loop ids.Length() {
        ;msgbox(activeID "=?=" ids[A_Index])
        if activeID!=ids[A_Index]
            continue
        else i:=A_Index
        loop ids.Length()-i {
            win:="ahk_id " ids[A_Index+i]
            ;msgbox(WinGetTitle(win))
            if !WinGetTitle(win)
                continue
            ;Use next two lines to send active window one step back without activating the window behind
           ;WinSetAlwaysOnTop(True, win)
           ;,WinSetAlwaysOnTop(False, win)
            winActivate(win)
            break
        }
        break
    }
    return
}
/*
*/
return

MButton:: winSizer.start("RButton")   ; WinSizer
MButton Up:: {
    if !winSizer.end()
        send("#{Tab}")
    return
}

WheelUp::                             ; Switch Windows
WheelDown::
{
    /* ; Uncomment this to Wrap
    if A_ThisHotkey="WheelUp" {
         if TaskView.GetCurrentDesktopNumber()=1
             TaskView.GoToDesktopNumber(0)
    } else if TaskView.GetCurrentDesktopNumber()=TaskView.GetDesktopCount()
        TaskView.GoToDesktopNumber(1)
    */
    send(A_ThisHotkey="WheelUp"? "#^{Left}" : "#^{Right}" )
    silentKeyRelease_Mouse("R",200)
    sleep(200)
    return
}

#hotIf getKeyState("MButton","P")        ; Move window b/w desktops
WheelUp:: TaskView.MoveToDesktopPrev(WinExist("A"),True)
WheelDown:: TaskView.MoveToDesktopNext(WinExist("A"),False)
silentKeyRelease_Mouse("M",200)
sleep(200)
return


#hotIf !winActive("ahk_group right_drag")
*RButton up::
Critical()
if !{"MButton":0,"MButton Up":0,"WheelUp":0,"WheelDown":0}.haskey(A_PriorKey)
    send("{Blind}{RButton}")
return
#hotIf


;===================    Move Windows to different Desktop using Keyboard (Same as MButton+Scroll)
return
+#Left::TaskView.MoveToDesktopPrev(WinExist("A"),True)
+#Right::TaskView.MoveToDesktopNext(WinExist("A"),False)
return

;===================    Over Taskbar

RETURN
#hotIf isOver_mouse("ahk_class Shell_TrayWnd")   ; Alt tab over taskbar
~MButton::send("^!{Tab}^+!{Tab}")
WheelUp::send("^+!{Tab}")
WheelDown::send("^!{Tab}")
#hotIf

#hotIf winActive("Task Switching ahk_class MultitaskingViewFrame ahk_exe explorer.exe") AND isOver_mouse("ahk_class Shell_TrayWnd ahk_exe Explorer.exe")        ; When Task Switching
LButton::send("{Enter}")
MButton::send("{Alt Up}{Esc}")
#hotIf

;===================    Ditto & Listary
RETURN
XButton2::hotkeyAssign(A_ThisHotkey, "runDitto", "runListary",, 0.5)

runDitto(){
    static key  :="^``"
          ,Path :="D:\Program Files\Ditto"
          ,exe  :="Ditto.exe"
    if !ProcessExist(exe) {
        Toast.show("Starting Ditto")
       ,Run(Path "\" exe)
       ,A_DetectHiddenWindows:=True
        if !WinWait("ahk_exe " exe,,2)
            return
    }
    Toast.show("Ditto")
   ,Send(key)
    return
}

!Space::
runListary(){
  static key  :="^#``"
        ,Win  :="ahk_class Listary_WidgetWin_0"
        ,Cntrl:="ListarySearchBox1"
        ,Path :="D:\Program Files\Listary"
        ,exe  :="Listary.exe"
        ,opt  :={activateWindow:True, hiddenWindows:False, sendToAll:True, useOldClip:True}

    Toast.show("Listary")
   ,text:=getSelectedText({resetClip:False}) ;Clipboard will be restored later
   ,text:=text||Clipboard ; x||y <=> x?x:y in AHK
   ,text:=strlen(text)<200? RegExReplace(RegExReplace(text, "[`t`n]| +"," "), "^ | $|``r") :""
    if !ProcessExist(exe) {
        Toast.show("Starting Listary")
       ,Run(Path "\" exe)
       ,A_DetectHiddenWindows:=True
        if !Winwait("ahk_exe " exe,, 2)
            return False
    }
    Toast.show("Listary")
   ,send(key)
   ,A_DetectHiddenWindows:=False
    if !Winwait("ahk_exe " exe,,2)
        return False
    /**
   sendTo_pasteText(text, Win " ahk_exe " exe, Cntrl, opt) ;Clipboard is restored due to opt.useOldClip:=True
   ,sendTo("^a", Win "ahk_exe " exe, Cntrl, opt)
    /*
    */
    if !WinWaitActive("ahk_exe " exe,,2)
        return False
    sleep(500)
   ,sendTo_pasteText(text,,, opt) ;Clipboard is restored due to opt.useOldClip:=True
   ,send("^a")
    return True
}

;===================    winAction & RunText
RETURN
XButton1::hotkeyAssign(A_ThisHotkey, ObjBindMethod(winAction,"show"), ObjBindMethod(runText,"showGUI"))
#w:: winAction.show()
!`:: runText.showGUI()

;===================    Tray Menu
RETURN
^#t::
updateTray(0,A_ScreenHeight-200)
,sleep(300)
,A_TrayMenu.Show()
return

;===================    Convert fn+F1 which sends #F1 to F1
RETURN
#F1::F1
return

;===================    Open Potplayer
RETURN
#v::
Toast.Show("Starting PotPlayer")
,Run("D:\Program Files\Potplayer\PotplayerMini64.exe " Clipboard)
return

;===================    Open MusicBee
RETURN
#F10::  ; F10 is also Media_Play_Pause
A_DetectHiddenWindows:=True
if !winExist("ahk_exe MusicBee.exe") {
    Toast.show("Starting MusicBee")
   ,Run("D:\Program Files\MusicBee\MusicBee.exe")
    if !WinWait("ahk_exe MusicBee.exe",,2)
        return
    Sleep(100)
}
Toast.show("Play/Pause")
,Send("#{F10}")  ; The same key is set as global play/pause in MusicBee
return

#hotIf ProcessExist("MusicBee.exe")
#F9::Media_Prev
#F11::Media_Next

; MusicBee sometimes doesnt respond to Media buttons. So I set it's global hotkey to #{F9/10/11}
;Media_Prev::      send("#{F9}")
;Media_Play_Pause::send("#{F10}")
;Media_Next::      send("#{F11}")
#hotIf

;===================    Listary launcher
RETURN
~LWin & RWin::return    ;Prevents LWin from trigerring when #... (eg: #Tab) is used
LWin UP:: Send("#``")
return

;===================    CaseMenu and »
RETURN
CapsLock::hotKeyAssign(A_ThisHotkey, "sendSuffix", ObjBindMethod(caseMenu, "show"))
^CapsLock:: CaseMenu.show()
sendSuffix() {
    SendLevel(1)
    sendEvent("»") ;Used to trigger some hotstrings
}

;===================    Toggglekeys
+CapsLock::CaseMenu.toggle("CapsLock")
NumLock::
ScrollLock::
Insert::
CaseMenu.toggle(A_ThisHotkey)
return

;===================    Calc/cmd/Notepad
RETURN
#+CapsLock:: ShellRun("notepad.exe")
#^CapsLock:: ShellRun("calc1.exe")
#CapsLock::  ShellRun("cmd.exe",,,"RunAs")
#!CapsLock:: ShellRun("wsl.exe",,,"RunAs")
^!CapsLock::
runSHH(){
    param:=InputBox("parameters?", "SHH", "H128", "-CX 14173002@10.2.60.11")
    if !errorlevel
      ShellRun("ssh.exe",param,,,"RunAs")
    return
}
return
/*
;===================    Sets
RETURN
!CapsLock:: Send("#^{Tab}")
!+CapsLock:: Send("#^+{Tab}")
*/
/*
;===================    Groupy
RETURN
!CapsLock:: Send("#{F12}")
!+CapsLock:: Send("#^{F12}")
*/

;===================    NetNotify
RETURN
#n:: netNotify(False,,1000)

;===================    DimScreen
RETURN
#F2:: dimScreen(+25)  ; F2,F3 are also Brightness_Down/Up keys
#F3:: dimScreen(-25)

;===================    Fences Pages
RETURN
#hotIf winActive("ahk_class WorkerW ahk_exe explorer.exe") AND getKeyState("LButton","P")
WheelUp::
WheelDown::
send("{LButton Up}!{" (A_ThisHotkey="WheelUp"?"WheelDown":"WheelUp") "}")
return
#hotIf

;===================    Send `n/`t in cases where enter/tab is used for other purposes
RETURN
#hotIf !winActive("ahk_exe Mathematica.exe")
+Enter::Send "`n"
;#hotIf !winActive("ahk_exe sublime_text.exe")
;+Tab::Send "    "
#hotIf

;===================
RETURN
#c::
makeMicroWindow(){
    hwnd:=WinExist("A")
    win:="ahk_id " hwnd
    winclass:=WinGetClass(this.win)
    if (winclass="WorkerW" OR winclass="Shell_TrayWnd" OR !winexist(win))
        Toast.show("No Window")
    else {
        microWindow.new(hwnd)
        Toast.show("microWindow")
    }
    return
}

;===================    TrayIt
RETURN
#m::
if winAction.bind_Window() ;Returns false if no window
    winAction.trayIt()
return

RETURN
#t::
winAction.trayIt.show()
return

;===================    Kill switch
#q::SCR_Pause() ;Defined in Tray.ahk
#SuspendExempt True
#f::SCR_AllowOnFS()
#^q::ExitApp()
#SuspendExempt False