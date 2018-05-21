 hotKeyAssign(key,single:="",long:="",double:="",t:=0.25) { ;Can't use labels
    if long OR double {
        if !keyWait(key,"T" t)
            return %long%()
        else if func(double) {
            if keyWait(key,"D T" t)
                return %double%()
        }
    }
    return %single%()
}