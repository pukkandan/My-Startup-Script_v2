class Transparent_Windows {
    set(win,tr:=240,exclude:=""){
    ;Remember to always exclude ["ahk_class SysShadow","ahk_class Dropdown","ahk_class SysDragImage"]
        if !IsObject(exclude)
            exclude:=[]
        if !isObject(this.winList){
           this.winlist:={}, this.transList:=[]
           onExit(objBindMethod(this,"_remove"))
        }
        return this.winList[win]:={trans:tr,excludeList:exclude}
    }

    run(){
        for win,prop in this.winList
            for _,wid in winGetList(win) {
                for _,exc in prop.excludeList
                    if winExist(exc " ahk_id" wid)
                        continue 2
                winSetTransparent(prop.trans, "ahk_id " wid)
               ,this.transList.push(wid)
            }
        return
    }

    _remove(){
        for _,wid in this.transList
            winSetTransparent(255, "ahk_id " wid)
        return
    }
}

;------------------------------------------------------------------------------------------------
Transparent_MaxBG(title:="A",color:="F0F0F0"){
    return WinGetMinMax(title)?WinSetTranscolor(color, title):WinSetTranscolor("Off", title)
}

;------------------------------------------------------------------------------------------------
Transparent_TaskbarGlass(state:=-4, color:=0x40000000) { ;ABGR color
; Note: Resets when Start menu is active. So set as timer. Even then, it won't work while startmenu/taskview is active

/*  state
    ------------
    0   No color, Fully Transparent
    1   Colored , Fully opaque
    2   Colored , Translucent
    3   No Color, Blurred (since it has no color, transparency can't be controlled)
    4   Colored , Blurred
   <0   0 when on desktop and |state| otherwise
*/
    static ACCENT_POLICY, WINCOMPATTRDATA, state_old, color_old
   ,pad := (A_PtrSize=8?4:0), WCA_ACCENT_POLICY := 19, ACCENT_SIZE := VarSetStrCapacity(ACCENT_POLICY, 16, 0)
   ,SWCA:= DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "user32.dll", "Ptr"), "AStr", "SetWindowCompositionAttribute", "Ptr")

    if state<0 {
        GroupAdd("trans_desktop", "ahk_class Progman")
       ,GroupAdd("trans_desktop", "ahk_class WorkerW")
       ,GroupAdd("trans_desktop", "ahk_class Shell_TrayWnd")
       ,state:=winexist("A ahk_group trans_desktop")?0:-state
    }

    if (state_old!=(state:=mod(state,5)) OR color_old!=color) {
        state_old:=state, color_old:=color
       ,NumPut(state, ACCENT_POLICY, 0, "int")
       ,NumPut(color, ACCENT_POLICY, 8, "int")
       ,VarSetStrCapacity(WINCOMPATTRDATA, 8 + 2*pad + A_PtrSize, 0)
       ,NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
       ,NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
       ,NumPut(ACCENT_SIZE, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    }

    return DllCall(SWCA, "ptr", WinExist("ahk_class Shell_TrayWnd"), "ptr", &WINCOMPATTRDATA)
}