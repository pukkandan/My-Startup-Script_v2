splitFilePath(Path){
    SplitPath Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    return {Path:Path, FileName:OutFileName, Dir:OutDir, Extension:OutExtension, NameNoExt:OutNameNoExt, Drive:OutDrive}
}