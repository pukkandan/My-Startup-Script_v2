;https://github.com/shajul/Autohotkey/blob/master/COM/Zip%20Unzip%20Natively.ahk

zip(files,zip:="") {
    files:=substr(files,-1)="\" ? substr(files,1,-1) :files
    if !zip
        zip:=files ".zip"
    if !FileExist(zip)
        zip_createFile(zip)

    zip:=zip__getFullPath(zip), files:=zip__getFullPath(files)
   ,pzip:=ComObjCreate("Shell.Application").Namespace(zip)

    loop Files, inStr(fileExist(file), "D") ? files "\*.*" :files, "DF" {
        pzip.CopyHere(A_LoopFileLongPath, 4|16 )
        while pzip.items().count!=A_Index
            sleep(100)
    }
    return pzip.items().count
}

zip_createFile(zip) {
    Header1:="PK" Chr(5) Chr(6)
   ,VarSetCapacity(Header2, 18, 0)
   ,file:=FileOpen(zip,"w")
   ,file.Write(Header1)
   ,file.RawWrite(Header2,18)
    return file.close()
}

zip_unZip(zip, folder:="") {
    if !folder
        folder:=zip "_folder"
    folder:=substr(folder,-1)="\" ? substr(folder,1,-1) :folder
    If !DirExist(folder)
       dirCreate(folder)
    zip:=zip__getFullPath(zip), folder:=zip__getFullPath(folder)
   ,SA:=ComObjCreate("Shell.Application"), pzip:=SA.Namespace(zip), pfol:=SA.Namespace(folder)

   ,zippedItems:=pzip.items().count
   ,pfol.CopyHere(pzip.items(), 4|16 )
    while pfol.items().count!=zippedItems
        sleep(100)
    return zippedItems
}

zip__getFullPath(f){
    loop Files, f, "FD"
        return A_LoopFileFullPath
}