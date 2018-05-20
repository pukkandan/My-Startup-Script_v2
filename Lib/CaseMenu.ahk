class caseMenu {
    static menuObj:=MenuCreate()
    __new(){
        for i,j in {U:"&UPPER CASE", L:"&lower case", T:"&Title Case", S:"&Sentence case.", I:"&iNVERT cASE"}
            this.menuObj.add(j, ObjBindMethod(this,"caseChange",i))
        this.menuObj.add()
        for _,j in ["&Capslock","&Numlock","Sc&rollLock","I&nsert"]
            this.menuObj.add(j, ObjBindMethod(this,"toggle",strReplace(j,"&")))
    }
    init(){
        return this.__new()
    }

    show(){
        Toast.show("caseMenu")
        for _,j in ["&Capslock","&Numlock","Sc&rollLock","I&nsert"]
            GetKeyState(strReplace(j,"&"),"T")? this.menuObj.check(j) :this.menuObj.unCheck(j)
        this.menuObj.show()
        return
    }

    caseChange(type){ ; type: U=UPPER, L=Lower, T=Title, S=Sentence, I=Invert
        return sendTo_pasteText(caseChange(getSelectedText({resetClip:False}), type),,, {useOldClip:True})
    }

    toggle(key){
        if key="Insert"
            Send("{Insert}")
        else if key="Capslock"
            SetCapsLockState(!GetKeyState("CapsLock","T"))
        else if key="Numlock"
            SetNumLockState(!GetKeyState("NumLock","T"))
        else if key="Scrolllock"
            SetScrollLockState(!GetKeyState("ScrollLock","T"))
        return Toast.Show(key (GetKeyState(key,"T")? " On":" Off"))
    }
}