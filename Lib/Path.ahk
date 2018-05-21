path(Path){
    splitPath(path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive)
    return {Path: substr(path,-1)="\"? substr(path,1,-1) :path, FileName:OutFileName, Dir:OutDir, Extension:OutExtension, NameNoExt:OutNameNoExt, Drive:OutDrive}
}