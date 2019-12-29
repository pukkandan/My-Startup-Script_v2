; Uses https://github.com/Ciantic/VirtualDesktopAccessor
; This script may work in slightly unexpected ways when used with sets.
; Functions starting with _ are not expected to be called from outside the class.

/**                             ;SAMPLE
#include reloadAsAdmin.ahk
reloadAsAdmin()
global A_ScriptPID := fListessExist()
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
    init(){ ; SHOULD be called
        return this.__new()
    }
    __new(){
        this.base:={__call:ObjBindMethod(this,"_call")}
        this.dll := DllCall("LoadLibrary", "Str", A_ScriptDir . "\Lib\VirtualDesktopAccessor.dll", "Ptr")
       ,this.toast:=new Toast({life:1000})

        ; Windows 10 desktop changes listener
       ,DllCall(this.fList["RegisterPostMessageHook"], "Int", A_ScriptHwnd+(0x1000<<32), "Int", 0x1400 + 30)
       ,OnMessage(0x1400 + 30, ObjBindMethod(this,"_onDesktopSwitch"))
        ; Restart the virtual desktop accessor when explorer.exe restarts
       ,OnMessage(DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated"), ObjBindMethod(this,"_onExplorerRestart"))
    }

    fList[fName]{
        get {

            ; GetProcAddress is case-sensitive. So known functions are predefined to avoid errors when function call is made with wrong case
            if !isObject(this._fList) {
                _fList:={}
                l:=[ "GetCurrentDesktopNumber","GetDesktopCount","GoToDesktopNumber"
                    ,"IsWindowOnDesktopNumber","IsWindowOnCurrentVirtualDesktop"
                    ,"GetWindowDesktopNumber","MoveWindowToDesktopNumber"
                    ,"IsPinnedWindow","PinWindow","UnPinWindow","IsPinnedApp","PinApp","UnPinApp"
                    ,"RegisterPostMessageHook","UnregisterPostMessageHook" ]
                for _,f in l
                    this._fList[StrLower(f)]:= DllCall("GetProcAddress", "Ptr", this.dll, "AStr", f, "Ptr")
            }

            g:=StrLower(fName) ; The keys are stored in lowercase to avoid case issues
            if !this._fList[g] { ; Try to create function if it doesnt exist
                this._fList[g]:= DllCall("GetProcAddress", "Ptr", this.dll, "AStr", fName, "Ptr")
                msgbox("New function '" fName "'was created in TaskView.fList`nfList[" g "] = " this._fList[g])
            }
            return this._fList[g]

            /* ------------- Functions exported by DLL ; * = Usable ** = Explicitly Defined
            > Desktop
            **  int GetCurrentDesktopNumber()
            *   int GetDesktopCount()
            **  void GoToDesktopNumber(int number)

            > Window
            **  int IsWindowOnDesktopNumber(HWND window, int number)
            *   int IsWindowOnCurrentVirtualDesktop(HWND window)
            **  int GetWindowDesktopNumber(HWND window)
            **  BOOL MoveWindowToDesktopNumber(HWND window, int number)

            > Pinning
            *   int IsPinnedWindow(HWND hwnd) // Returns 1 if pinned, 0 if not pinned, -1 if not valid
            *   void PinWindow(HWND hwnd)
            *   void UnPinWindow(HWND hwnd)
            *   int IsPinnedApp(HWND hwnd) // Returns 1 if pinned, 0 if not pinned, -1 if not valid
            *   void PinApp(HWND hwnd)
            *   void UnPinApp(HWND hwnd)

            > Register/Unregister
            *   void RegisterPostMessageHook(HWND listener, int messageOffset)
            *   void UnregisterPostMessageHook(HWND hwnd)
            *   void RestartVirtualDesktopAccessor() // Shouldn't use pointer. So pointer is not defined in "fList"

            > GUID
                int GetDesktopNumber(IVirtualDesktop *pDesktop)
                GUID GetDesktopIdByNumber(int number) // Returns zeroed GUID with invalid number found
                int GetDesktopNumberById(GUID desktopId)
                GUID GetWindowDesktopId(HWND window)

            > Window Properties
                int ViewIsShownInSwitchers(HWND hwnd) // Is the window shown in Alt+Tab list?
                int ViewIsVisible(HWND hwnd) // Is the window visible?
                uint ViewGetLastActivationTimestamp(HWND) // Get last activation timestamp

            > AltTab
                void ViewSetFocus(HWND hwnd) // Set focus like Alt+Tab switcher
                void ViewSwitchTo(HWND hwnd) // Switch to window like Alt+Tab switcher

            > Thumbnail
                HWND ViewGetThumbnailHwnd(HWND hwnd) // Get thumbnail handle for a window, possibly peek preview of Alt+Tab
                HWND ViewGetFocused() // Get focused window thumbnail handle

            > View Order
                uint ViewGetByZOrder(HWND *windows, UINT count, BOOL onlySwitcherWindows, BOOL onlyCurrentDesktop) // Get windows in Z-order (NOT alt-tab order)
                uint ViewGetByLastActivationOrder(HWND *windows, UINT count, BOOL onlySwitcherWindows, BOOL onlyCurrentDesktop) // Get windows in alt tab order

             */
        }

        set { ;Never used
            msgbox("TaskView.fList is never supposed to be set. Mistake??")
            return this._fList[StrLower(fName)]:=value
        }
    }

    ; Functions of the form "fName()" or "fName(win_hwnd)" doesnt have to be seperately defined
    _Call(obj,fName,win_hwnd:=""){ ; obj will always be "this"
        ;msgbox fName "(" win_hwnd ")=" ( win_hwnd=""? DllCall(this.fList[fName]) . " noHwnd": DllCall(this.fList[fName], "UInt", win_hwnd) )
        return win_hwnd=""? DllCall(this.fList[fName]): DllCall(this.fList[fName], "UInt", win_hwnd)
    }
    ;===========================================================

    _onExplorerRestart(wParam, lParam, msg, hwnd) {
        global RestartVirtualDesktopAccessorfList
        DllCall(this.fList["RestartVirtualDesktopAccessor"], "UInt", result)
    }
    _onDesktopSwitch(wParam,lParam){
        return this.toast.show("Desktop " lParam+1)
    }

    ;===========================================================
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
    ;===========================================================


    /* ; Defined by _call
    isPinnedWindow(win_hwnd){
        return DllCall(this.fList["IsPinnedWindow"], "UInt", win_hwnd)
    }
    isPinnedApp(win_hwnd){
        return DllCall(this.fList["IsPinnedApp"], "UInt", win_hwnd)
    }
    pinWindow(win_hwnd){
        return DllCall(this.fList["PinWindow"], "UInt", win_hwnd)
    }
    unPinWindow(win_hwnd){
        return DllCall(this.fList["UnPinWindow"], "UInt", win_hwnd)
    }
    pinApp(win_hwnd){
        return DllCall(this.fList["PinApp"], "UInt", win_hwnd)
    }
    unPinApp(win_hwnd){
        return DllCall(this.fList["UnPinApp"], "UInt", win_hwnd)
    }
    getDesktopCount(){
        return DllCall(this.fList["GetDesktopCount"])
    }
    IsWindowOnCurrentVirtualDesktop(win_hwnd){
        return DllCall(this.fList["IsWindowOnCurrentVirtualDesktop"], "UInt", win_hwnd)
    }
    */

    getCurrentDesktopNumber(){
        return DllCall(this.fList["GetCurrentDesktopNumber"]) + 1
    }
    getWindowDesktopNumber(win_hwnd){
        return DllCall(this.fList["GetWindowDesktopNumber"], "UInt", win_hwnd) + 1
    }
    isWindowOnDesktopNumber(win_hwnd, n, wrap:=True){
        if !(n is "number")
            return 0
        return DllCall(this.fList["IsWindowOnDesktopNumber"], "UInt", win_hwnd, "UInt", this._desktopNumber(n,wrap)-1)
    }


    goToDesktopNumber(n, wrap:=True) {
        if !(n is "number")
            return 0
        n:=this._desktopNumber(n, wrap)
       ,DllCall(this.fList["GoToDesktopNumber"], "Int", n-1)
        return n
    }
    moveWindowToDesktopNumber(n, win_hwnd, wrap:=True){
        if !(n is "number")
            return 0
        n:=this._desktopNumber(n,wrap)
       ,DllCall(this.fList["MoveWindowToDesktopNumber"], "UInt", win_hwnd, "UInt", n-1)
        return n
    }
    ;===========================================================

    goToDesktopPrev(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()-1, wrap)
    }
    goToDesktopNext(wrap:=True) {
        return this.goToDesktopNumber(this.getCurrentDesktopNumber()+1, wrap)
    }
    moveToDesktopPrev(win_hwnd, wrap:=True) {
        n:=this.getCurrentDesktopNumber()-1
        if this.moveWindowToDesktopNumber(n, win_hwnd, wrap) {
            this.goToDesktopNumber(n,wrap)
           ,WinActivate("ahk_id " win_hwnd)
            return n
        } else return 0
    }
    moveToDesktopNext(win_hwnd, wrap:=True) {
        n:=this.getCurrentDesktopNumber()+1
        if this.moveWindowToDesktopNumber(n, win_hwnd, wrap) {
            this.goToDesktopNumber(n,wrap)
           ,WinActivate("ahk_id " win_hwnd)
            return n
        } else return 0
    }

    pinWindowToggle(win_hwnd){
        if this.isPinnedWindow(win_hwnd)
            this.unPinWindow(win_hwnd)
        else
            this.pinWindow(win_hwnd)
        return this.isPinnedWindow(win_hwnd)
    }
    pinAppToggle(win_hwnd){
        if this.isPinnedApp(win_hwnd)
            this.unPinApp(win_hwnd)
        else
            this.pinApp(win_hwnd)
        return this.isPinnedApp(win_hwnd)
    }
}