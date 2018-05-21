FilesAndFolders_Copy(SourcePattern, DestinationFolder, DoOverwrite := false) {
; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and returns the number of files/folders that could not be copied.

    FileCopy(SourcePattern, DestinationFolder, DoOverwrite)
    ErrorCount := ErrorLevel

    Loop Files, SourcePattern, "D" {
        DirCopy(A_LoopFilePath, DestinationFolder "\" A_LoopFileName, DoOverwrite)
        ErrorCount += ErrorLevel
    }
    return ErrorCount
}

FilesAndFolders_Move(SourcePattern, DestinationFolder, DoOverwrite := false) {
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and returns the number of files/folders that could not be moved.

    FileMove(SourcePattern, DestinationFolder, DoOverwrite)
    ErrorCount := ErrorLevel

    Loop Files, SourcePattern, "D" {
        DirMove(A_LoopFilePath, DestinationFolder "\" A_LoopFileName, DoOverwrite?2:0)
        ErrorCount += ErrorLevel
    }
    return ErrorCount
}