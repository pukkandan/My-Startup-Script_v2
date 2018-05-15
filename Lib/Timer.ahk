class Timer {
    static opt0:={delay:False, runatStart:False, allowPause:True}

    set(f,t,opt:=0){
        opt:=replaceList(this.opt0,opt)
        if !opt.delay {
            if opt.runatStart
                %f%()
            setTimer(f, t)
        }
        if !(this.list is "object")
            this.list:=[]
        this.list.push({f:f,t:t,opt:opt})
        return
    }

    startAllDelayed(){
        for _,item in this.list {
            if !item.opt.delay
                continue
            f:=item.f
           ,setTimer(f, item.t)
            if item.opt.runatStart
                %f%()
        }
        return
    }

    pauseAll(){
        for _,item in this.list {
            if !item.opt.allowPause OR item.stopped
                continue
             f:=item.f
            ,setTimer(f, "Off")
        }
        return
    }

    resumeAll(){
        for _,item in this.list {
            if !item.opt.allowPause OR item.stopped
                continue
             f:=item.f
            ,setTimer(f, "On")
        }
        return
    }

    stop(f){
        for _,item in this.list {
            if item.f!=f
                continue
            setTimer(f, "Off")
            return item.stopped:=True
        }
        return false
    }

    resume(f){
        for _,item in this.list {
            if item.f!=f
                continue
            setTimer(f, "On")
            return item.stopped:=False
        }
        return false
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