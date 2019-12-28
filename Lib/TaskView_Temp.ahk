; Windows RS5 builds broke VirtualDesktopAccessor.dll used in TaskView.ahk. This is a workaround to get the same functionality.

; This script may work in slightly unexpected ways when used with sets.

; The windows/apps are not actually pinned. The script moves them to the current desktop each time desktop is changed. As a result, the windows option "Show this windows/app on all desktop" work independently of the "pin app/window" feature of this script (except for modern apps).

; The windows API for moving windows b/w desktops can't be used. So, as a workaround, we winHide the window to be moved, move to the new desktop, and then winshow it causing it to appear in the new desktop. As a result, window cannot be moved without actually going to the new desktop.

; For modern apps, pinning/moving is done by opening TaskView using #Tab pressing the relevent keys. I havent tested pinning modern apps extensively. Expect it to fail sometimes.

; PinApp() of any modern app makes the script think all modern apps are pinned since they all use same process. Same for unpinning.

; Functions starting with _ are not expected to be called from outside the class. Also, make sure to use getDesktopCount() and getCurrentDesktopNumber() instead of desktopCount and currentDesktopNumber

/**                             ;SAMPLE
#include reloadAsAdmin.ahk
reloadAsAdmin()
global A_ScriptPID := ProcessExist()
#include Timer.ahk
#include Toast.ahk
Taskview.init()

1::msgbox("Is Pinned Window? " Taskview.isPinnedWindow(winExist("A")) "`nIs Pinned App " Taskview.isPinnedApp(winExist("A")) "`nCurrent Desktop " Taskview.getCurrentDesktopNumber() "`nNo of Desktops " Taskview.getDesktopCount())

2::TaskView.pinWindowToggle(winExist("A"))
+2::TaskView.pinWindow(winExist("A"))
^2::TaskView.unPinWindow(winExist("A"))

3::TaskView.pinAppToggle(winExist("A"))
+3::TaskView.pinApp(winExist("A"))
^3::TaskView.unPinApp(winExist("A"))

4::TaskView.goToDesktopNumber(2)
5::TaskView.moveWindowToDesktopNumber(2,winExist("A"))
6::TaskView.goToDesktopPrev()
7::TaskView.goToDesktopNext()
8::TaskView.moveToDesktopPrev(winExist("A"))
9::TaskView.moveToDesktopNext(winExist("A"))
/**/

class TaskView { ; There should only be one object for this
    static pinnedWindowList:={}, pinnedAppList:={}
    init(){ ; SHOULD be called
        return this.__new()
    }
    __new(){
        this.toast:=new Toast({life:1000})
        Timer.set(objbindMethod(this,"_desktopChange"),100,{runAtStart:True})
    }

    _refreshDesktopList() { ;https://github.com/pmb6tz/windows-desktop-switcher
        static reg_current:="HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\"
             , reg_list:="HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops"
             , sessionID
        if !sessionID
            DllCall("ProcessIdToSessionId", "UInt", A_ScriptPID, "UInt*", sessionID)

        if currentDesktopID:=RegRead(reg_current sessionId "\VirtualDesktops", "CurrentVirtualDesktop")
            idLength := StrLen(currentDesktopID)
        else idLength:=32 ;It should always be 32, but we check just in case

        if desktopList:=RegRead(reg_list, "VirtualDesktopIDs")
            this.desktopCount := StrLen(desktopList)//idLength
        else this.desktopCount := 1

        loop this.desktopCount
            if  currentDesktopID=SubStr(desktopList, (A_Index*IDLength) + 1-IDLength, IDLength)
                return this.currentDesktopNumber:=A_Index
        return this.currentDesktopNumber:=1
    }

    _hideShow(hwnd){
        win:="ahk_id " hwnd
       ,DetectHiddenWindows(True)
       ,minMax:=WinGetMinMax(win)
       ,winHide(win)
       ,winShow(win)
        if minMax=1 {
            WinRestore(win)
           ,WinMaximize(win)
        }
        else if minMax=-1
            WinMinimize(win)
        return
    }

    _desktopChange(){
        static prevWindow:=0
        if winActive("Task View ahk_class Windows.UI.Core.CoreWindow ahk_exe explorer.exe")
            return prevWindow
        n:=this.getcurrentDesktopNumber(), A_DetectHiddenWindows:=False
        if prevWindow!=n AND prevWindow!=0 {
            this.toast.show("Desktop " n)
            for hwnd in this.pinnedWindowList
                this._hideShow(hwnd)
            for proc in this.pinnedAppList
                for _,hwnd in wingetList("ahk_exe " proc)
                    this._hideShow(hwnd)
        }
        return prevWindow:=n
    }

    _isModernApp(hwnd){
        return winExist("ahk_class ApplicationFrameWindow ahk_id" hwnd) ; true if it is a modern app
    }
    _modernAppsWorkaround(keys){
        static tv:="Task View ahk_class Windows.UI.Core.CoreWindow ahk_exe explorer.exe"
        WinActivate("ahk_id " hwnd)
        send("#{Tab}")
        winwaitActive(tv)
        sleep(500) ; Tweak this if context menu disappears too fast

        SetKeyDelay(200) ; Tweak this if some clicks dont register
        sendEvent("{AppsKey}" keys "{space}")
        if winActive(tv)
            send("#{Tab}")
        WinWaitNotActive(tv)
        return
    }

    isPinnedWindow(hwnd){
        return this.pinnedWindowList.hasKey(hwnd)
    }
    isPinnedApp(hwnd){
        return this.pinnedAppList.hasKey(winGetProcessName("ahk_id " hwnd))
    }
    pinWindow(hwnd){
        if this._isModernApp(hwnd) && !this.isPinnedWindow(hwnd)
                this._modernAppsWorkaround("{down 3}")
        return this.pinnedWindowList[hwnd]:=True ; The hwnd are stored as the key for easier access
    }
    unPinWindow(hwnd){
        if this._isModernApp(hwnd) && this.isPinnedWindow(hwnd)
                this._modernAppsWorkaround("{down 2}")
        return this.pinnedWindowList.Delete(hwnd)
    }
    pinApp(hwnd){
        p:=winGetProcessName("ahk_id " hwnd)
        if this._isModernApp(hwnd) && !this.isPinnedApp(p){
                this._modernAppsWorkaround("{down 4}")
                p.=" " ; I dont remember why :/
        }
        return this.pinnedAppList[p]:=True
    }
    unPinApp(hwnd){
        p:=winGetProcessName("ahk_id " hwnd)
        if this._isModernApp(hwnd) && this.isPinnedApp(p)
                this._modernAppsWorkaround("{down 3}")
        return this.pinnedAppList.Delete(p)
    }

    getDesktopCount(){
        this._refreshDesktopList()
        return this.desktopCount
    }
    getCurrentDesktopNumber(){
        this._refreshDesktopList()
        return this.currentDesktopNumber
    }

    _desktopNumber(n, wrap:=True){
        max:=this.getDesktopCount()
        if wrap {
            while n<=0
                n+=max
            return mod(n-1, max) +1
        }

        if n<=0
            return 1
        if n>max {
            loop n-max
                send("#^d")       ; Create extra desktops
            sleep(100)
        }
        return n
    }
    goToDesktopNumber(n, wrap:=True) {
        if !(n is "number")
            return 0
        n:=this._desktopNumber(n, wrap), m:=this.getCurrentDesktopNumber()
        loop n-m
            send("#^{Right}")
        loop m-n
            send("#^{Left}")
        return n
    }
    moveWindowToDesktopNumber(n, hwnd, wrap:=True){ ;And go there
        n:=this.goToDesktopNumber(n,wrap)
        if n!=this.currentDesktopNumber
            this._hideShow(hwnd)
        return n
    }

    goToDesktopPrev(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()-1, wrap)
    }
    goToDesktopNext(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()+1, wrap)
    }
    moveToDesktopPrev(hwnd, wrap:=True) {
        n:=this.moveWindowToDesktopNumber(this.getCurrentDesktopNumber()-1, hwnd, wrap)
       ,winActivate(win)
        return n
    }
    moveToDesktopNext(hwnd, wrap:=True) {
        n:=this.moveWindowToDesktopNumber(this.getCurrentDesktopNumber()+1, hwnd, wrap)
       ,winActivate(win)
        return n
    }

    pinWindowToggle(hwnd){
        if this.isPinnedWindow(hwnd)
            this.unPinWindow(hwnd)
        else this.pinWindow(hwnd)
        return this.isPinnedWindow(hwnd)
    }
    pinAppToggle(hwnd){
        if this.isPinnedApp(hwnd)
            this.unPinApp(hwnd)
        else this.pinApp(hwnd)
        return this.isPinnedApp(hwnd)
    }
}