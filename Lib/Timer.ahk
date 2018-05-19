class Timer {
    static opt0:={delay:False, runatStart:False, allowPause:True}, fList:={}

    set(f,t:=250,opt:=0){
        opt:=replaceList(this.opt0,opt)
        if !opt.delay {
            if opt.runatStart
                %f%()
            setTimer(f, t)
        }
        opt.t:=t, opt.running:=True, this.fList[f]:=opt
        return
    }

    startAllDelayed(){
        for f,opt in this.fList {
            if !opt.delay
                continue
            setTimer(f, opt.t)
            if opt.runatStart
                %f%()
        }
        return
    }

    pauseAll(){
        for f,opt in this.fList
            if opt.allowPause AND opt.running
                setTimer(f, "Off")
        return
    }

    resumeAll(){
        for f,opt in this.fList
            if opt.allowPause AND opt.running
                setTimer(f, "On")
        return
    }

    stop(f){
        SetTimer(f, "Off")
       ,this.fList[f].running:=False
        return
    }

    restart(f){
        SetTimer(f, "On")
       ,this.fList[f].running:=True
        return
    }

}

class delayedTimer {
    set(f,t,opt:=0){
        if IsObject(opt)
            opt.delay:=True
        else opt:={delay:True}
        return Timer.set(f,t,opt)
    }
    __call(f,param*){
        return ObjbindMethod(Timer,f,param*).call()
    }
    startAll(){
        return Timer.startAllDelayed()
    }
}