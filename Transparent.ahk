Transparent_windows(tr){
    GroupAdd("TransGroup", "ahk_class CabinetWClass ahk_exe explorer.exe")

    GroupAdd("noTransGroup", "ahk_class SysShadow")
    GroupAdd("noTransGroup", "ahk_class Dropdown")
    GroupAdd("noTransGroup", "ahk_class SysDragImage")

    for _,wid in WinGetList(windows) {
        if !WinExist("ahk_group TransGroup ahk_id " wid)
            continue
        if WinExist("ahk_group noTransGroup ahk_id " wid)
            continue

        if winGetTransparent("ahk_id " wid)=255 {
            winSetTransparent(tr, "ahk_id " wid)
            onExit(Func("winsetTransparent").bind(255,"ahk_id " wid))
        }
    }
    return
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
    , pad := (A_PtrSize=8?4:0), WCA_ACCENT_POLICY := 19, ACCENT_SIZE := VarSetCapacity(ACCENT_POLICY, 16, 0)
    , SWCA:= DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "user32.dll", "Ptr"), "AStr", "SetWindowCompositionAttribute", "Ptr")

    if state<0 {
        GroupAdd("trans_desktop", "ahk_class Progman")
        GroupAdd("trans_desktop", "ahk_class WorkerW")
        GroupAdd("trans_desktop", "ahk_class Shell_TrayWnd")
        state:=winexist("A ahk_group trans_desktop")?0:-state
    }

    if (state_old!=(state:=mod(state,5)) OR color_old!=color) {
        state_old:=state, color_old:=color
        NumPut(state, ACCENT_POLICY, 0, "int")
        NumPut(color, ACCENT_POLICY, 8, "int")
        VarSetCapacity(WINCOMPATTRDATA, 8 + 2*pad + A_PtrSize, 0)
        NumPut(WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0, "int")
        NumPut(&ACCENT_POLICY, WINCOMPATTRDATA, 4 + pad, "ptr")
        NumPut(ACCENT_SIZE, WINCOMPATTRDATA, 4 + pad + A_PtrSize, "uint")
    }

    return DllCall(SWCA, "ptr", WinExist("ahk_class Shell_TrayWnd"), "ptr", &WINCOMPATTRDATA)
}