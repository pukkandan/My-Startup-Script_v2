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

    ;Remove path if copied from file explorer
    GroupAdd("explorer", "ahk_class Progman")
   ,GroupAdd("explorer", "ahk_class WorkerW")
   ,GroupAdd("explorer", "ahk_class Explorer")
   ,GroupAdd("explorer", "ahk_class CabinetWClass")
  if winActive("ahk_group explorer ahk_exe explorer.exe")
      return path(clipNew).NameNoExt||clipNew  ;x||y <=> x?x:y in AHK
  else return clipNew
}