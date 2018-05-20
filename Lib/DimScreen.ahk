dimScreen(p:=""){
    static DimScreenGUI, t:=0, e:=False
    if !DimScreenGUI {
        DimScreenGUI:=GuiCreate("+ToolWindow -Disabled -SysMenu -Caption +E0x20 +AlwaysOnTop","DimScreen")
       ,DimScreenGUI.title:="DimScreen", DimScreenGUI.BackColor:= 0x000000
       ,DimScreenGUI.Show("Hide X0 Y0 W"  A_ScreenWidth " H"  A_ScreenHeight)
    }

    if p is "Number" { ;If p is not a number, just return without doing anything
        t:= p OR t ? (t>-p? (t+p>250?250:t+p) :0) :75
       ,e:= t? (p?True:!e) :False
        if e {
            WinSetTransparent(t, "ahk_id " DimScreenGUI.hwnd)
           ,Toast.show("Dimscreen " t "/255")
           ,DimScreenGUI.Show("NoActivate")
        }
        else {
            DimScreenGUI.Hide()
           ,Toast.show("Dimscreen Off")
        }
    }
    return {trans:t, enabled:e, hwnd:DimScreenGUI.hwnd}
}