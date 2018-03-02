Suspend(True)
;#include %A_ScriptDir%  ;Sets dir for includes. No longer needed in v2
#include Directives.ahk
;#include <ini>
;#include <Toast>
;#include <DelayedTimer>
;#include <ReloadScriptOnEdit>

;Tooltip("ReloadScriptOnEdit", {life:500})
;DelayedTimer.set(func("ReloadScriptOnEdit").bind([A_ScriptDir "\*.ahk",A_ScriptDir "\*.ini"]), 2000, True)
;DelayedTimer.start(True) ;Dont delay

;Tooltip("Tray", {life:500})
;#include Tray.ahk
;trayMenu()

;Tooltip("SuspendOnFS", {life:500})
;#include SuspendOnFS.ahk
;DelayedTimer.set("SuspendOnFS", 100)

;Tooltip("WinProbe", {life:500})
;#include WinProbe.ahk
;; winProbe.activate()

;Tooltip("DimScreen", {life:500})
;#include DimScreen.ahk
;; dimScreen(120)

;Tooltip("TaskView", {life:500})
;#include TaskView.ahk
;TaskView.__new()

;Tooltip("HotCorners", {life:500})
;#include HotCorners.ahk ; Refactor as a class
;DelayedTimer.set("hotcorners", 100)

;Tooltip("WinSizer", {life:500})
;#include WinSizer.ahk
;WinSizer.__new()

;Tooltip("UnwantedPopupBlocker", {life:500})
;#include UnwantedPopupBlocker.ahk
;DelayedTimer.set("UnwantedPopupBlocker", 100)

;; Tooltip("Transparent",{life:500})
;; #include Transparent.ahk
;; DelayedTimer.set(Func("Transparent_Taskbar").bind(240), 500)
;; DelayedTimer.set(Func("Transparent_Windows").bind(250), 500)
;; DelayedTimer.set("Transparent_ImageGlass", 500)

;Tooltip("PIP", {life:500})
;#include PIP.ahk
;PIP.__new([  {title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64" ,type:"VJT"}
;            ,{title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"       ,type:"VJT"}
;            ,{title:"ahk_exe chrome.exe"                                ,type:"CJT"}
;            ,{title:"ahk_exe cmd.exe"     , set:2                       ,type:  "T"}
;            ,{title:"ahk_exe calc.exe"    , set:3   , maxheight:500     ,type:  "N"}
;            ,{title:"ahk_exe calc1.exe"   , set:3   , maxheight:500     ,type:  "N"}     ])
;DelayedTimer.set(ObjbindMethod(PIP,"run"), 100)

;Tooltip("ToggleKeys", {life:500})
;#include ToggleKeys.ahk
;DelayedTimer.set(Func("CapsLockOffTimer").bind(60000), 1000)
;CaseMenu.__new()

;Tooltip("MicroWindows", {life:500})
;#include MicroWindows.ahk

;Tooltip("WinAction", {life:500})
;#include WinAction.ahk
;winAction.__new("winAction.ini")    ; Multiple winaction can be created by using obj1:=new winaction("iniName.ini"), ...

;Tooltip("RunText", {life:500})
;#include RunText.ahk  ;Needs serious Refactoring!!
;global runTextObj:=new runText("Runtext.ini")

;Tooltip("Internet", {life:500})
;#include Internet.ahk
;DelayedTimer.set("netNotify", 5000, True)


;Tooltip("AutoUpdate", {life:500})
;#include AutoUpdate.ahk
;DelayedTimer.set("autoUpdate", 3600000, True)

;;Required for mouseRemap
;GroupAdd(right_drag, "ahk_exe mspaint.exe"  )
;GroupAdd(right_drag, "ahk_exe mspaint1.exe" )
;GroupAdd(right_drag, "ahk_exe cmd.exe"      )
;GroupAdd(right_drag, "ahk_exe vivaldi.exe"  )

;DelayedTimer.start()
Suspend(False)
;Toast.show("Script Loaded")
;DelayedTimer.firstRun()
;;============================== End of auto-execute
;#include KeyRemap.ahk
#include *i HotStrings.ahk ;Has personal data in this file, so it is ignored from github

;RETURN
;Exit:
;ExitApp
;return
