reloadScriptOnEdit(files,clean:=0) {    ;clean=2 reloads also
    static fName, fPath
    if !fName {
        fName:=path(A_ScriptFullPath).NameNoExt
       ,fPath:=(strlen(A_ScriptFullPath)>50?"...":"") substr(A_ScriptFullPath,-50)
       ,clean:=1 ;Clean on first run
    }
    if clean {
        for _,f in files
            scriptEdited(f,,True)
        if clean=2
            Reload
        return 1
    }

    for _,f in files
        if changed:=scriptEdited(f) {
            changed:=(strlen(changed)>50?"...":"") substr(changed,-50)
            if MsgBox("A file related to the script " fName " has changed:`n`nScript file:`n" fPath "`nChanged file:`n" changed "`n`nReload this script?",, 0x24)="Yes"
                reloadScriptOnEdit(files,2)
            else
                reloadScriptOnEdit(files,1)
        }
    return

    scriptEdited(files:="",option:="RF",clean:=0) {
        if files=""
            files:=A_ScriptFullPath

        loop Files, files, option {
            if inStr(A_LoopFileAttrib,"H") OR inStr(A_LoopFileAttrib,"S")
                continue
            else if clean
                fileSetAttrib("-A", A_LoopFileFullPath, option)
            else if inStr(A_LoopFileAttrib, "A") {
                fileSetAttrib("-A", A_LoopFileFullPath)
                return A_LoopFileFullPath
            }
        }
        return 0
    }
}
