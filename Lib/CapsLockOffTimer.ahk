capsLockOffTimer(t:=60000){
    if A_TimeIdleKeyboard>t AND GetKeyState("CapsLock","T") {
        SetCapsLockState(False)
        Toast.show("CapsLock Off")
        return True
    }
    return False
}