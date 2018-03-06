;Buggy!!
pasteText(text:="") {
    if !text
        return False

    clipOld:=ClipboardAll, Clipboard:=text
    clipWait()
    Send("^v")
    Clipboard:=clipOld
    return True

}