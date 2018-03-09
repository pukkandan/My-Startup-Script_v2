;===================    Right and Middle Buttons
RETURN
#if !WinActive("ahk_group right_drag")
*RButton up::
if !isPressed("RButton",False)
    send("{Blind}{RButton}")
; alternative to if A_priorHotkey in ["MButton","MButton Up","WheelUp","WheelDown"]
else if !{"MButton":0,"MButton Up":0,"WheelUp":0,"WheelDown":0}.haskey(A_PriorHotkey)
    send("{Blind}{RButton}")
return
#If

#if winActive("ahk_class MultitaskingViewFrame") AND isOver_mouse("ahk_class Shell_TrayWnd") ; When Task Switching
LButton::send("{Enter}")
#if

#if !getkeyState("Ctrl","P")
MButton::winSizer.start()                           ; winSizer
#if

MButton Up::
if winSizer.end()
    return
else if isPressed("RButton")
    send("#{Tab}")
else if isOver_mouse("ahk_class Shell_TrayWnd") ; Task manager
    Send("+^{Esc}")
else
    send("{MButton}")
return

WheelUp::
WheelDown::
if getKeyState("MButton","P") ; Move window b/w desktops
    (A_ThisHotkey=="WheelUp") ? taskView.MoveToDesktopPrev(WinExist("A"),True) : taskView.MoveToDesktopNext(WinExist("A"),False)
else if isPressed("RButton") {
    ; if A_ThisHotkey="WheelUp" AND taskView.GetCurrentDesktopNumber()=1 ;Wrap
    ;     taskView.GoToDesktopNumber(0)
    ; else(if A_ThisHotkey="WheelDown" AND taskView.GetCurrentDesktopNumber()=taskView.GetDesktopCount())
    ;     taskView.GoToDesktopNumber(1)
    ; else
        send("#^{" (A_ThisHotkey="WheelUp" ? "Left":"Right") "}")
} else if isOver_mouse("ahk_class Shell_TrayWnd") ; Alt tab over taskbar
    send(A_ThisHotkey="WheelUp" ? "^+!{Tab}" : "^!{Tab}")
else {
    send("{" A_ThisHotkey "}")
    return
}
sleep(200)
return

isPressed(key,check:=True){
; Checks if the key is pressed and stores that info
    static pressed:={}
    if check
        pressed[key]:=getkeystate(key,"P")
    return pressed.haskey(key)?pressed[key]:False
}
return

;===================    Ditto & Listary
RETURN
XButton2::
Keywait(A_ThisHotkey, "T0.5")
if !ErrorLevel {
    if !ProcessExist("Ditto.exe") {
        Toast.show("Starting Ditto")
       ,Run("D:\Program Files\Ditto\Ditto.exe")
       ,A_DetectHiddenWindows:=True
       ,WinWait("ahk_exe Ditto",,2)
        if ErrorLevel
            return
    }
    Toast.show("Ditto")
   ,Send("^``")
} else {
    !Space:: runListary()
}
return
runListary(){
    Toast.show("Listary")
   ,text:=getSelectedText()
   ,text:=text?text:Clipboard
   ,text:=RegExReplace(RegExReplace(text, "[``t``n]| +"," "), "^ | $|``r")
   ,text:=strlen(text)<100?text:""

    if !ProcessExist("Listary.exe") {
        Toast.show("Starting Listary")
       ,Run("D:\Program Files\Listary\Listary.exe")
       ,A_DetectHiddenWindows:=True
       ,Winwait("ahk_exe Listary.exe",, 2)
        if ErrorLevel
            return False
    }
    Toast.show("Listary")
   ,send("^#``")
   ,A_DetectHiddenWindows:=False
   ,Winwait("ahk_exe Listary.exe",,2)
    if ErrorLevel
        return False
    sleep(10)
   ,WinActivate("ahk_exe Listary.exe")
   ,pasteText(text)
   ,send("^a")
    return True
}

;===================    winAction & RunText
RETURN
XButton1::
Keywait(A_ThisHotkey, "T0.25")
if !ErrorLevel {
    #w:: winAction.show()
} else {
    !``:: runText.showGUI()
}
return

;===================    Tray Menu
RETURN
^#t::
updateTray(0,A_ScreenHeight-200)
,sleep(300)
,A_TrayMenu.Show()
return
;===================    Invert F1
RETURN
#F1::Send("{F1}")
return
;===================    Open Potplayer
RETURN
#v::
Toast.Show("Starting PotPlayer")
,Run("D:\Program Files\Potplayer\PotplayerMini64.exe " Clipboard)
return

;===================    Open MusicBee
RETURN
#F10::
A_DetectHiddenWindows:=True
if !winExist("ahk_exe MusicBee.exe") {
    Toast.show("Starting MusicBee")
   ,Run("D:\Program Files\MusicBee\MusicBee.exe")
   ,WinWait("ahk_exe MusicBee.exe",,2)
    if ErrorLevel
        return
    Sleep(100)
}
Toast.show("Play/Pause")
,Send("{Media_Play_Pause}")
return

;===================    Listary launcher
; RETURN
; ~LWin & RWin::return    ;Prevents LWin from trigerring when #... (eg: #Tab) is used
; LWin UP:: Send("#``")
; return

;===================    Toggglekeys and CaseMenu
RETURN
CapsLock::
keywait("Capslock", "T0.2")
if ErrorLevel {
    ^CapsLock:: caseMenu.show()
    return
}
NumLock::
ScrollLock::
Insert::
CaseMenu.toggle(A_ThisHotkey)
return

;===================    NetNotify
RETURN
#n:: netNotify(False,,1000)

;===================    DimScreen
RETURN
#F2:: dimScreen(+25)
#F3:: dimScreen(-25)

;===================    Calculator/Notepad
RETURN
#NumLock:: Run("calc1.exe")
#CapsLock:: Run("notepad.exe")