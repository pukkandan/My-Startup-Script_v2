getSelectedText()
{
 /* Returns selected text without disrupting the clipboard. However, if the clipboard contains a large amount of data, some of it may be lost
 */
    clipOld:=ClipboardAll, Clipboard:=""
    Send("^c")
    ClipWait(0.1, 1)
    clipNew:=Clipboard, Clipboard:=clipOld

    ;Special for explorer
    GroupAdd("explorer","ahk_class Progman")
    GroupAdd("explorer","ahk_class WorkerW")
    GroupAdd("explorer","ahk_class Explorer")
    GroupAdd("explorer","ahk_class CabinetWClass")

    return (winexist("A ahk_group explorer") AND clipnew2:=splitFilePath(clipNew).NameNoExt)?clipNew2:clipNew
}