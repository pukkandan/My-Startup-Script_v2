 ;#persistent
 ;PP1:={title:"ahk_exe PotPlayerMini64.exe ahk_class PotPlayer64" ,type:"VJT"}
 ;PP2:={title:"ahk_exe PotPlayer.exe ahk_class PotPlayer64"       ,type:"VJT"}
 ;C  :={title:"ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1"   ,type:"CJT"}
 ;PIP.__new([PP1,PP2,C])
; PIP.add("ahk_exe sublime_text.exe ahk_class PX_WINDOW_CLASS")
; PIP.add([{title:"ahk_exe explorer.exe ahk_class CabinetWClass",type:"J",set:2}])

;setTimer(ObjbindMethod(this,"run"),100)
;================================================================================

class PIP {
    __new(p:=""){
        this.list:={}, this.sets:=0, this.topListOld:=[], this.topList:=[], mouseAllowed:=[]
       ,this.def:={set:1, type:"J", maxwidth:A_ScreenWidth//2.1, maxheight:A_ScreenHeight//2}
       ,onExit(ObjbindMethod(this,"run",1))
        if p
            this.add(p)
        ;setTimer(ObjbindMethod(this,"run"),100)
    }
    add(param){
        if !IsObject(param)
            param:=[{title:param}]

        for _,p in param {
            t:=p.title
            if t is "number"
                t:="ahk_id " t

            /*      Type
                    T = Show/Hide Titlebar
                    J = Jump on MouseOver
                    V = Don't Show Titlebar on Mouseover (for Video players that have internal titlebar)
                    C = Ignore undesired Chrome windows (Page Unresponsive popup)
                    N = None of the above
                    set=0 => all windows of that category will be PIP, else, only one in a set will PIP at a time

            */
            if !p.type
                p.type:=this.def.type
            if p.set!="" {
                set:=p.set
                ;if set is not number
                ;    p.set:=this.sets+1   ;new set
                if set="new" {  ;new set
                    i:=this.sets
                    loop {
                        for _,item in this.list
                            while item.set="new_" i {
                                i++
                                continue 2
                            }
                        break
                    }
                    p.set:="new_" i
                }
            }
            try this.unPIP(this.list[t].set)
            for prop,def in this.def
                this.list[t,prop]:= p[prop]?p[prop]:def
            if this.sets<p.set
                this.sets:=p.set
        }

        return this.sets
    }
    remove(title){
        if !IsObject(title)
            title:=[title]
        for _,t in title {
            if t is "number"
                t:="ahk_id " t
            this.list.delete(t)
        }
    }

    getPIPWindow(t,item){
        IDList:=WinGetList(t), IDList.InsertAt(1,WinActive(t))
        for i,n in IDList {
            n:="ahk_id " n
            If !WinExist(n)
                continue

            ;Elimination of undesired windows
            currentPID:=WinGetPID(n)
            if  WinExist("ahk_class #32768 ahk_pid " currentPID)    ;Menu
                OR WinExist("ahk_class #32770 ahk_pid " currentPID)    ;Special windows like Settings (Potplayer)
                continue ; Not forced to on top
            if WinGetMinMax(n)=-1  ;Minimized
                continue
            WinGetPos(,, w, h, n)
            if h>item.maxHeight || w>item.maxWidth || h<32 ;Too small
                continue
            if inStr(item.type,"C"){   ;Chrome-like
                title:=WinGetTitle(n)
                if title="Page Unresponsive" OR title="Pages Unresponsive"
                    continue
                if WinGetStyle(n)&0x80000000 { ;Chrome Notification
                    ;~ WinSet, AlwaysOnTop, On, ahk_id %n%   ;Make Chrome notification come on top
                    continue
                }
            }
            return n ;This window isn't eliminated
        }
        return 0 ;No window
    }
    getPIPWindows(){
        winPref:=[], this_winPref:=0
        for t,i in this.list {
            n:=this.getPIPWindow(t,i)
            try old:=this.topListOld[i.set].id
            If !WinExist(n)
                continue

            if WinActive(n)
                this_winPref:=3
            else if old=n
                this_winPref:=2
            else this_winPref:=1

            if !(winPref[i.set] is "number") OR (this_winPref > winPref[i.set])
                winPref[i.set]:=this_winPref
            else continue

            this.topList[i.set]:={id:n,type:i.type}
            ; msgbox, % "this.topList[" i.set "]:={id:" n ",type:" i.type "}`nid=" this.topList[i.set].id ",type=" this.topList[i.set].type
        }
        return
    }
    unPIP(set){
        old:=this.topListOld[set]
        this.mouseAllowed[set]:=True
        WinSetAlwaysOnTop(false, old.id)
        taskView.UnpinWindow(old.id)
        if !isFullScreen(old.id,1) AND inStr(old.type,"T")
            WinSetStyle("+0xC00000", old.id)
    }
    unPIPOld(){
        for set,old in this.topListOld {
            if set=0
                continue
            if this.mouseAllowed[set]=""
                this.mouseAllowed[set]:=True
            try id:=this.topList[set].id
            if id!=old.id
                this.unPIP(set)
        }
        return
    }

    PIP(set){
        n:=this.topList[set].id
        taskView.pinWindow(n)
        WinSetAlwaysOnTop(true, n)    ;Set onTop
        ; msgbox, PIP:%set% id:%n%

        ;Avoid mouseover
        if isOver_mouse(substr(n,8)){ ;substr removes "ahk_id "
            if GetKeyState("Control","P") || GetKeyState("LButton","P") || GetKeyState("RButton","P") || GetKeyState("MButton","P") || WinActive(n)
                this.mouseAllowed[set]:=True

            if !this.mouseAllowed[set] {
                if inStr(this.topList[set].type,"J") {
                    WinGetPos(onTopX,,onTopW,, n)
                    WinMove(2*onTopX>A_ScreenWidth-onTopW ? +64 : A_ScreenWidth-onTopW-16,,,,n)
                }
            } else if inStr(this.topList[set].type,"T") AND !inStr(this.topList[set].type,"V")
                WinSetStyle("+0xC00000", n)
        } else this.mouseAllowed[set]:=False

        if !this.mouseAllowed[set] AND inStr(this.topList[set].type,"T") {
            if inStr(this.topList[set].type,"V")
                WinSetStyle("-0x400000", n)
            else if !this.mouseAllowed[set]
                WinSetStyle("-0xC00000", n)
        }
        return
    }
    setPIP(){
        if this.mouseAllowed[set]=""
            this.mouseAllowed[set]:=False
        for set in this.topList
            this.PIP(set)
        return
    }

    run(exit:=0){
        this.topListOld:=this.topList.Clone(), this.topList:=[]
        if !exit
            this.getPIPWindows()
        this.unPIPOld()
        if !exit
            this.setPIP()
        return
    }
}