Suspend(True)
;#include %A_ScriptDir%  ;Sets dir for includes. No longer needed in v2
#include Directives.ahk

; These are called first so that they can do their cleanup operations
;AutoUpdate()
ReloadScriptOnEdit([A_ScriptDir "\*.ahk",A_ScriptDir "\*.ini"])

#include <ini>
#include <Toast>
#include <DelayedTimer>
#include <ReloadScriptOnEdit>

tip("ReloadScriptOnEdit")
DelayedTimer.set(func("ReloadScriptOnEdit").bind([A_ScriptDir "\*.ahk", A_ScriptDir "\*.ini"]), 2000)

tip("Tray")
#include Tray.ahk
trayMenu()

tip("SuspendOnFS")
#include SuspendOnFS.ahk
DelayedTimer.set("SuspendOnFS", 100)

tip("DimScreen")
#include DimScreen.ahk
; dimScreen(120)

tip("TaskView")
#include TaskView.ahk
TaskView.init()

tip("HotCorners")
#include HotCorners.ahk
HotCorners.register("TL",Func("send").bind("#{Tab}"))
HotCorners.register("BL",Func("send").bind("#x"    ))
HotCorners.register("BR",Func("send").bind("#a"    ))
DelayedTimer.set(HotCorners.timer,100)

tip("UnwantedPopupBlocker")
#include UnwantedPopupBlocker.ahk
DelayedTimer.set("UnwantedPopupBlocker", 100)

tooltip("Transparent")
#include Transparent.ahk
DelayedTimer.set(Func("Transparent_TaskbarGlass").bind(4), 500)
;DelayedTimer.set(Func("Transparent_Windows").bind(250), 500)
;DelayedTimer.set(Func("Transparent_MaxBG").bind("ahk_exe ImageGlass.exe","3C3C3C"), 500)
;DelayedTimer.set(Func("Transparent_MaxBG").bind("ahk_exe nomacs.exe"    ,"F0F0F0"), 500)

;tip("PIP")
;#include PIP.ahk
;PIP.__new([  {title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64" ,type:"VJT"}
;            ,{title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"       ,type:"VJT"}
;            ,{title:"ahk_exe chrome.exe"                                ,type:"CJT"}
;            ,{title:"ahk_exe cmd.exe"     , set:2                       ,type:  "T"}
;            ,{title:"ahk_exe calc.exe"    , set:3   , maxheight:500     ,type:  "N"}
;            ,{title:"ahk_exe calc1.exe"   , set:3   , maxheight:500     ,type:  "N"}     ])
;DelayedTimer.set(ObjbindMethod(PIP,"run"), 100)

tip("ToggleKeys")
#include ToggleKeys.ahk
DelayedTimer.set(Func("CapsLockOffTimer").bind(60000), 1000)
CaseMenu.init()

;tip("MicroWindows")
;#include MicroWindows.ahk

;tip("WinAction")
;#include WinAction.ahk ; Refactor
;winAction.__new("winAction.ini")    ; Multiple winaction can be created by using obj1:=new winaction("iniName.ini"), ...

tip("WinSizer")
#include WinSizer.ahk

;tip("WinProbe")
;#include WinProbe.ahk
;; winProbe.activate()

;tip("RunText")
;#include RunText.ahk  ;Needs serious Refactoring!!
;global runTextObj:=new runText("Runtext.ini")

tip("Internet")
#include Internet.ahk
DelayedTimer.set("netNotify", 5000, True)


tip("AutoUpdate")
#include AutoUpdate.ahk
DelayedTimer.set("AutoUpdate", 3600000)


DelayedTimer.start()
Suspend(False)
Toast.show("Script Loaded")
DelayedTimer.firstRun()

;Required for KeyRemap
GroupAdd("right_drag", "ahk_exe mspaint.exe"  )
GroupAdd("right_drag", "ahk_exe mspaint1.exe" )
GroupAdd("right_drag", "ahk_exe cmd.exe"      )
GroupAdd("right_drag", "ahk_exe vivaldi.exe"  )

;;============================== End of auto-execute
RETURN
#include KeyRemap.ahk
#include *i HotStrings.ahk ;Has personal data in this file, so it is ignored from github

;==================================================
/*  To convert
    ------------
    toggleKeys  done
    internet    done
    microWindows
    pip
    runText
    winAction
    winProbe    discard
    winSizer    done
 */

; Following are temporary lines designed to make the script run without errors till the rest is converted
class RunText {
}
class WinProbe {
}