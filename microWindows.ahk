; microWindow.new(WinExist("My Script 2 ahk_exe explorer.exe"))

class microWindow{
    __new(){
        this.list:={}, this.dll:={}

        dwmapi          := DllCall("LoadLibrary", "Str", "dwmapi.dll", "Ptr")
        this.dll.DRT    := DllCall("GetProcAddress", "Ptr", dwmapi, "AStr", "DwmRegisterThumbnail"        , "Ptr")
        this.dll.DQTSS  := DllCall("GetProcAddress", "Ptr", dwmapi, "AStr", "DwmQueryThumbnailSourceSize" , "Ptr")
        this.dll.DUTP   := DllCall("GetProcAddress", "Ptr", dwmapi, "AStr", "DwmUpdateThumbnailProperties", "Ptr")
        this.dll.DUT    := DllCall("GetProcAddress", "Ptr", dwmapi, "AStr", "DwmUnregisterThumbnail"      , "Ptr")

        setTimer(ObjBindMethod(this,"update"), 100)
    }

    add(wid, pos:="", w:=240, pos1:="", pos2:=""){
        title:="MicroWindow " cleanWinTitle("ahk_id " wid)
        WinGetPos(,, ww, wh, "ahk_id " wid)

        h:=(w AND wh)? w*wh/ww: 64
        pos := (pos!="")? pos: [ A_ScreenWidth-w-64 , A_ScreenHeight-h-64 ]
        pos1:= pos1? pos1: [0,0]
        pos2:= pos2? pos2: [ww,wh]
        mx:=16, my:=39

        this.list.push((wid): { "gui":GuiObj, "pic":picObj, "mouse_allowed":false, "M_over":false
                              , "pos1":pos1, "pos2":pos2, "mx":mx, "my":my
                              , "width":w, "height":h, "win_width":ww, "win_height":wh      } )

        guiObj:= GuiCreate("+AlwaysOnTop -Caption +Resize -MaximizeBox +ToolWindow", title)
        picObj:= guiObj.Add("Picture", "x0 y0 w" w " h" h)

        guiObj.onEvent("Click",ObjBindMethod(this, "eventHandler", "Click" , wid))
        guiObj.onEvent("Close",ObjBindMethod(this, "eventHandler", "Close" , wid))
        guiObj.onEvent("Size" ,ObjBindMethod(this, "eventHandler", "Resize", wid))

        guiObj.show("Noactivate x" pos[1] " y" pos[2] " w" (w+mx) " h" (h+my))

        this.prepare(wid), this.update(wid)

        ;static n:=0
        ;local ww, wh
       ; this.id:=n, this.wid:=wid, this.pos1:=pos1, this.pos2:=pos2, this.mx:=16, this.my:=39
       ;,this.M_over:=false, this.width:=w, this.win_width:=ww, this.win_height:=wh

        ;local GUIhwnd, act
        ;GUI, microWindow%n%:New, +HwndGUIhwnd +AlwaysOnTop +ToolWindow -Caption
        ;this.hwnd:=GUIhwnd, this.mouse_allowed:=False
        ;Gui, microWindow%n%:Add, Pic, x0 y0 w%w% h%h% vpic%n%

        ;n++

        ;act:=ObjBindMethod(this,"update")
        ;setTimer, % act, 100

        ;OnMessage(0x201, ObjBindMethod(this,"onClick")) ;Left click (down)
        ;OnMessage(0x204, ObjBindMethod(this,"onClick")) ;Right click (down)
    }

    prepare(wid){
        obj:=this.list[wid]
        VarSetStrCapacity(thumbnail, 4, 0)
        DllCall(this.dll.DRT , "UInt", obj.gui.hwnd, "UInt", wid, "UInt", &thumbnail)
        this.hThumb:=NumGet(thumbnail)
        return this.putThumb(obj)
    }
    putThumb(wid){
        obj:=this.list[wid]
        VarSetStrCapacity(dskThumbProps, 45, 0)
        NumPut(3, dskThumbProps, 0, "UInt")
        NumPut(0, dskThumbProps, 4, "Int")
        NumPut(0, dskThumbProps, 8, "Int")
        NumPut(obj.width  , dskThumbProps, 12, "Int")
        NumPut(obj.height , dskThumbProps, 16, "Int")
        NumPut(obj.pos1[1], dskThumbProps, 20, "Int")
        NumPut(obj.pos1[2], dskThumbProps, 24, "Int")
        NumPut(obj.pos2[1], dskThumbProps, 28, "Int")
        NumPut(obj.pos2[2], dskThumbProps, 32, "Int")
        DllCall(this.dll.DUTP, "UInt", this.hThumb, "UInt", &dskThumbProps)

        VarSetStrCapacity(dskThumbProps, 45, 0)
        NumPut(8, dskThumbProps,  0, "UInt")
        NumPut(1, dskThumbProps, 37,  "Int")
        return DllCall(this.dll.DUTP, "UInt", this.hThumb, "UInt", &dskThumbProps)
    }

    eventHandler(type, wid, guiObj, p*){ ;Donot use "GuiObj". Use "(list[wid]).gui" instead
        if type="Click"
            winActivate("ahk_id " wid)
        else if type="Close"
            this.delete(wid)
        else if type="Resize"
            this.update(wid)
    }
    ;------------ WIP
    delete(){
        GUI_handle:="microWindow" this.id
        GUI, %GUI_handle%: Destroy
        DllCall(this.dll.DUT, "UInt", this.hThumb)
        this.SetCapacity(0)
        return this.base:=""
    }

    getWinSize(){ ; Why???
        VarSetStrCapacity(Size, 8, 0)
        DllCall(this.dll.DQTSS, "Uint", this.hThumb, "Uint", &Size)
        ww:= NumGet(&Size, 0, "int"), wh:= NumGet(&Size, 4, "int")
       ,rw:=ww/this.win_width, rh:=wh/this.win_height
       ,this.pos1[1]*=rw, this.pos2[1]*=rw, this.pos1[2]*=rh, this.pos2[2]*=rh
       ,this.win_width := ww, this.win_height:= wh
        return
    }

    update(wid:=""){
        if WinActive("ahk_id " this.wid) {           ; Hide if parent is in focus
            if !this.hidden
                winhide "ahk_id " this.hwnd
            this.hidden:=true
            return
        } else if this.hidden {
            winshow "ahk_id " this.hwnd
            this.hidden:=false
        }


        M_wasOver:=this.M_over, this.M_over:=this.mouseOver(), n:=this.id
        wingetpos,x,y,w,, % "ahk_id " this.hwnd
        if !w   ;Closed
            return this.delete()
        this.getWinSize()
        this.pos:=[x,y], this.width:=w-(M_wasOver?this.mx:0)
       ,h:=(this.win_height*this.width)/this.win_width, this.height:=h>0?h:16
        this.putThumb()

        GuiControl, Move, Pic%n%, % "X0 Y0 W" this.width " H" this.height
        mDir:=(!this.M_over AND M_wasOver)? 1 :(this.M_over AND !M_wasOver? -1 :0)
        WinMove, % "ahk_id " this.hwnd,, % x+mDir*this.mx/2, % y+mDir*(this.my-this.mx/2)
           , % this.width+(this.M_over?this.mx:0), % this.height+(this.M_over?this.my:0)
        return
    }
    ;onClick(wParam, lParam, msg, hwnd){
    ;    if hwnd!=this.hwnd
    ;        return

    ;    ; CoordMode, Mouse, Client
    ;    ; ; MouseGetPos, mx, my
    ;    ; mx := lParam & 0xFFFF
    ;    ; my := lParam >> 16
    ;    ; key:=(msg==0x204)? "R" :(msg==0x201)? "L" :""
    ;    ;  x:= (mx*(this.pos2[1]-this.pos1[1]))//this.width  + this.pos1[1]
    ;    ; ,y:= (my*(this.pos2[2]-this.pos1[2]))//this.height + this.pos1[2]
    ;    ; if key
    ;    ;     ControlClick, x%x% y%y%, % "ahk_id" this.wid,,% key,, NA Pos
    ;    ; ; msgbox, % key "|" mx "|" my "`n" x "=" mx "*(" this.pos2[1] "-" this.pos1[1] ")/" this.width "+" this.pos1[1] "`n" y "=" my "*(" this.pos2[2] "-" this.pos1[2] ")/" this.height "+" this.pos1[2]

    ;    winactivate, % "ahk_id " this.wid
    ;    return
    ;}
    mouseOver(){
        GUI_handle:="microWindow" this.id
        if !isOver_mouse(this.hwnd){
            GUI %GUI_handle%: -Caption -Resize
            this.mouse_allowed:=False
            return False
        }
        WinGetPos, X,,W,, % "ahk_id " this.hwnd

        if w>A_ScreenWidth//2 || GetKeyState("Control","P") || GetKeyState("LButton","P") || GetKeyState("RButton","P") || GetKeyState("MButton","P") || WinActive("ahk_id" this.hwnd)
            this.mouse_allowed:=True

        if this.mouse_allowed {
            GUI %GUI_handle%: +Caption +Resize -MaximizeBox
            return True
        } else
            WinMove, % "ahk_id " this.hwnd,, % 2*X>A_ScreenWidth-W ? +64 : A_ScreenWidth-W-16
        return False
    }
}