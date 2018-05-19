 hotkeyAssign(key,single:="",long:="",double:="",t:=0.25) { ;Can't use labels
    if isFunc(long) OR isFunc(double) {
        KeyWait(key,"T" t)
        if ErrorLevel
            return %long%()
        else if isFunc(double) {
            KeyWait(key,"D T" t)
            if !ErrorLevel
                return %double%()
        }
    }
    return isFunc(single)? %single%() :0
}