class ini{
    __new(file:="Settings.ini"){
        this.file:=file
    }
    get(sect:="",key:="",def:=0){
        return sect=""? iniRead(this.file): key=""? iniRead(this.file, sect): iniRead(this.file, sect, key, def)
    }
    set(sect,key:="",val:=""){
        return key=""? iniWrite(val, this.file, sect): iniWrite(val, this.file, sect, key)
    }
    delete(sect:="",key:=""){
        return sect=""? fileDelete(this.file): key=""? iniDelete(this.file, sect): iniRead(this.file, sect, key)
    }
}
