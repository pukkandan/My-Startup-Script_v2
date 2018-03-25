CapsLockOffTimer(t:=60000){
    if A_TimeIdleKeyboard>t) AND GetKeyState("CapsLock","T" {
        SetCapsLockState(False)
        Toast.show("CapsLock Off")
        return True
    }
    return False
}

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

    caseChange(case){
        text:=getSelectedText({resetClip:False})
        static exceptions:= ["I","AHK","AutoHotkey","Dr","Mr","Ms","Mrs","AKJ"]
                ;list of words that should not be modified for S,T
        if case="S" { ;Sentence case.
            text := RegExReplace(RegExReplace(text, "(.*)", "$L{1}"), "(?<=[^a-zA-Z0-9_-]\s|\n).|^.", "$U{0}")
        } else if case="I" ;iNVERSE
         text:=RegExReplace(text, "([A-Z])|([a-z])", "$L1$U2")
        else text:=RegExReplace(text, "(.*)", "$" Type "{1}")

        if case="S" OR case="T"
            for _,word in exceptions ;Parse the exceptions
                text:= RegExReplace(text,"i)\b" word "\b", word)

        sendTo_pasteText(text,,, {useOldClip:True})
        return
    }

    toggle(key){
        if key="Insert"
            Send("{Insert}")
        else if key="Capslock"
            SetCapsLockState(GetKeyState("CapsLock","T"))
        else if key="Numlock"
            SetNumLockState(GetKeyState("NumLock","T"))
        else if key="Scrolllock"
            SetScrollLockState(GetKeyState("ScrollLock","T"))
        return Toast.show(A_ThisHotkey (GetKeyState(A_ThisHotkey,"T")? " On":" Off"))
    }
}

Togglekeys_check(){
    return {c:getkeyState("Capslock","T"), n:getkeyState("Numlock","T"), s:getkeyState("ScrollLock","T"), i:getkeyState("Insert","T")}
}