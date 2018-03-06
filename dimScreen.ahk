dimScreen(p:=0){
    static DimScreenGUI, t:=0, e:=False
    if !(p is "Number") ;The tray name gets passed as param when calling this from tray
        p:=0
    t:= p OR t ? (t>-p? (t+p>250?250:t+p) :0) :75,  e:= t? (p?True:!e) :False
    if !DimScreenGUI {
        DimScreenGUI:=GuiCreate("+ToolWindow -Disabled -SysMenu -Caption +E0x20 +AlwaysOnTop","DimScreen")
        DimScreenGUI.title:="DimScreen", DimScreenGUI.BackColor:= 0x000000
        DimScreenGUI.Show("NoActivate X0 Y0 W"  A_ScreenWidth " H"  A_ScreenHeight)
    }
    if e {
        WinSetTransparent(t, "ahk_id " DimScreenGUI.hwnd)
        Toast.show("Dimscreen " t "/255")
        DimScreenGUI.Show("NoActivate")
        A_TrayMenu.Check("&Dim Screen")
    }
    else {
        DimScreenGUI.Hide()
        Toast.show("Dimscreen Off")
        A_TrayMenu.UnCheck("&Dim Screen")
    }
    return DimScreenGUI.hwnd
}