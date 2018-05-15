#include Clip.ahk
#include ReplaceList.ahk

getSelectedText(opt:="")
{
    static opt0:={resetClip:True, resetClipFull:False, useOldClip:False, keepClip:False}
    opt:=replaceList(opt0, opt)

    if opt.resetClip AND !opt.useOldClip
        clip.save(opt.resetClipFull)
    Clipboard:="", Send("^{Insert}"), ClipWait(0.1, 1), clipNew:=Clipboard
    if opt.resetClip
        clip.recover(!keepClip)

    ;Special for explorer
    GroupAdd("explorer", "ahk_class Progman")
   ,GroupAdd("explorer", "ahk_class WorkerW")
   ,GroupAdd("explorer", "ahk_class Explorer")
   ,GroupAdd("explorer", "ahk_class CabinetWClass")

    return (winexist("A ahk_group explorer") AND clipnew2:=splitFilePath(clipNew).NameNoExt)?clipNew2:clipNew
}