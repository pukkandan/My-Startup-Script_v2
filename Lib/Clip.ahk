class clip {
    static clip
    save(full:=False){
        this.clip:= full? ClipboardAll: Clipboard
    }
    recover(empty:=True){
    Clipboard:=this.clip
    if empty
        this.empty()
    }
    empty(){
        this.clip:=""
    }
}