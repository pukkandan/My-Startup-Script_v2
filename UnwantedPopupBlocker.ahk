unwantedPopupBlocker(){
    if WinExist("(UNREGISTERED) ahk_exe sublime_text.exe")
        WinSetTitle(StrReplace(WinGetTitle(), " (UNREGISTERED)"))
    if WinExist("This is an unregistered copy ahk_exe sublime_text.exe ahk_class #32770") ;Sublimetext register
        ControlClick("Button2")

    if WinExist("Disable developer mode extensions ahk_exe chrome.exe") { ;Chrome dev mode
        winActivate()
       ,send("{esc}")
    }

    if WinExist("Error ahk_class #32770 ahk_exe SdDisplay.exe") ;Groupy bug
        winClose()

    if WinExist("ahk_class AvIPMDialog ahk_exe ipmGui.exe") ;Avira Ads
        winClose()
    return
}
