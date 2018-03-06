_ScriptEdited(files:="",option:="RF",clean:=0) {
	if files=""
		files:=A_ScriptFullPath

	Loop Files, files, option {
		if inStr(A_LoopFileAttrib,"H") OR inStr(A_LoopFileAttrib,"S")
			continue
		else if clean
			FileSetAttrib("-A", A_LoopFileFullPath, option)
		else if inStr(A_LoopFileAttrib, "A") {
			FileSetAttrib("-A", A_LoopFileFullPath)
			return A_LoopFileFullPath
		}
	}
	return 0
}

ReloadScriptOnEdit(files,clean:=0) {	;clean=2 reloads also
	static fName, fPath
	if !fName {
		fName:=SplitFilePath(A_ScriptFullPath).NameNoExt
		,fPath:=(strlen(A_ScriptFullPath)>50?"...":"") substr(A_ScriptFullPath,-50)
		,clean:=1 ;Clean on first run
	}
	if clean {
		for _,f in files
			_ScriptEdited(f,,True)
		if clean=2
			Reload
		return 1
	}

	for _,f in files
		if changed:=_ScriptEdited(f) {
			changed:=(strlen(changed)>50?"...":"") substr(changed,-50)
			if MsgBox("A file related to the script " fName " has changed:`n`nScript file:`n" fPath "`nChanged file:`n" changed "`n`nReload this script?",, 0x24)="Yes"
				ReloadScriptOnEdit(files,2)
			else
				ReloadScriptOnEdit(files,1)
		}
	return
}
