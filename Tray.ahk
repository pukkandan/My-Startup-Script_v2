trayMenu(){
    if fileExist(A_ScriptName ".ico")                         ;Main Icon
        TraySetIcon(A_ScriptName ".ico")
    A_IconTip:= ""  ;Tray tip is shown using tooltip 20

   ,A_TrayMenu.Standard:= False    ;No standard menu
   ,A_TrayMenu.Add("&Reload Script", "SCR_Reload")
   ,A_TrayMenu.Add("&Active", "SCR_Pause")
   ,A_TrayMenu.Check("&Active")
   ,A_TrayMenu.Add("&Edit Script", "SCR_Edit")
   ,A_TrayMenu.Add("Open &Folder", "SCR_OpenFolder")
   ,A_TrayMenu.Add("AHK &Help", "AHK_Help")
   ,A_TrayMenu.Default:= "AHK &Help"

   ,A_TrayMenu.Add()
   ,A_TrayMenu.Add("&Net Status", func("netNotify").bind(False,,0))
   ,A_TrayMenu.Add("&Dim Screen", "dimScreen")
   ,trayIt:=MenuCreate()
   ,A_TrayMenu.Add("&TrayIt", trayIt)

   ,A_TrayMenu.Add()
   ,A_TrayMenu.Add("&Window Probe", ObjBindMethod(winProbe, "toggle"))
   ,AHK:=MenuCreate(), A_AllowMainWindow:=True, AHK.Standard:=True
   ,A_TrayMenu.Add("&AHK", AHK)
   ,A_TrayMenu.Add("E&xit", "ExitApp")

    return trayListen()
}

AHK_Help(){
    SplitPath(A_AhkPath,, path)
    return Run(path "\AutoHotkey.chm")
}
SCR_OpenFolder(){
    return Run(A_ScriptDir)
}
SCR_Edit(){
    return Run(A_ScriptName ".sublime-project")
}
SCR_Reload(){
    return Reload()
}
SCR_Pause(){
    Suspend()
   ,A_TrayMenu.ToggleCheck("&Active")
    loop 20
        Tooltip(,,,A_Index)
    return Pause("Toggle", True)
}

;==========================================
trayListen(){
    return OnMessage(0x404, "mouseOverTray")  ;Mouse over tray icon
}
mouseOverTray(wParam,lParam){
    if lParam=0x201 { ; Single click
    } else if lParam=0x203 { ; Double click
    } else if lParam=0x205 { ; Right click
    } else updateTray()
    return
}
updateTray(mx0:="",my0:=""){
    static mx, my, timer:=0
    if mx0="" or my0="" {
        if A_TickCount-timer>1000
            MouseGetPos(mx, my)
           ,timer:=A_TickCount
    } else mx:=mx0, my:=my0

    tip:=A_ScriptName " Script`n"

   ,obj:=Togglekeys_check()
   ,tip.="ToggleKeys: " (obj.n?"N":"") (obj.c?"C":"") (obj.s?"S":"") (obj.i?"I":"") "`n"

   ,obj:=netNotify(False,False)
    if obj.status!="" {
        tip.="Internet: " (["No Connection","Connected, no Internet","Internet access (no VPN)","Internet access through VPN"][obj.status+2]) "`n"
        if obj.status>=0
            tip.="Public IP: " obj.ipInfo.ip (obj.ipInfo.loc?" (" obj.ipInfo.loc ")":"") "`nLocal IP: [ " obj.ipInfo.ipl " ]" "`n"
    }
    return setTimer(func("showTrayTip").bind(tip,mx,my), -200)
}
showTrayTip(tip,mx,my){
    return tip(tip, 200, {x:mx,y:my-50,no:20}, {color:{bg:"0x222222",text:"0xFFFFFF"}, font:{size:10}})
}
