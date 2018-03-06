/* ; Examples
d:={ title:{color:"0x0000FF"} , margin:[100,100]}
t:=new toast(d)
p:={ title:{text:"hi",color:"0x0000FF"} , margin:[100,50] ,message:{ text:["hello","2","3"], def_size:18, size:[9,10], color:["0xFF00FF","0x00FF00"], offset:["",1] }, life:0 }
t.show(p)
sleep 1000
t.show({ title:{text:"whatever"},message:{text:["hello"]}, life:0 }) ;Replaces previous instance of same obj
sleep 200
Toast.show("hi") ;Show with all default settings
sleep 200
Toast.show(p) ;Show without creating a dedicated object. Will replace other instances without object, but not other objects
*/

class Toast{
    __new(byRef p:=""){
        static toastCount:=0
        toastCount++
        this.id:=toastCount, this.closeObj:=ObjBindMethod(this,"close")
       ,this.def:={ life:500, pos:{x:"center",y:"center"}, bgColor:"0x222222", trans:250, margin:{x:5,y:5}
                   , closekeys:[["Space","Return","~LButton","Esc"]], sound:false, activate:False
                   , title:{ text:"", color: "0xFFFFFF", size:14, opt:"bold", font:"Segoe UI" }
                   , message:{ text:[], color: [], size:[], opt:[], name:[], offset:[20]
                             , def_color: "0xFFFFFF", def_size:12, def_opt:"", def_name:"Segoe UI", def_offset:5 } }

        if p
            for i,x in p {
                if isObject(x)
                    for j,y in x
                        this.def[i][j]:= p[i][j]
                else this.def[i]:=p[i]
            }

    }
    setParam(byRef p,def:=false){
        if !IsObject(p) ;If not object, assume only title is given
            p:={title:{text:p}}
        for i,x in this.def {
            if isObject(x) {
                this[i]:={}
                for j,y in x
                    this[i][j]:= (p.haskey(i) AND p[i].haskey(j))? p[i][j]:this.def[i][j]
            } else this[i]:= p.haskey(i)?p[i]:this.def[i]
        }
        this.x:=this.pos.x, this.y:=this.pos.y, this.pos:="", this.closekeys:=this.closekeys[1]
        return
    }
    show(byRef param){
        if A_IsPaused
            return
        if !this.def
            this.__new()
        this.setParam(param)

        GUIOld:=this.GUIObj
       ,this.GUIObj:=GUICreate("-Caption +ToolWindow +AlwaysOnTop")
       ,this.GUIObj.title:="Toast" this.id, this.GUIObj.backColor:=this.bgColor
       ,this.GUIObj.marginX:=this.margin.x, this.GUIObj.marginY:=this.margin.y
       ,WinSetTransparent(this.trans, this.GUIObj.hwnd)

       ,this.GUIObj.setFont("norm s" this.title.size " c" this.title.color " " this.title.opt, this.title.Font)
       ,this.GUIObj.AddText("xm ym",this.title.text)

        for i,t in this.message.text {
             s:= this.message.size  [i] = "" ? this.message.def_size    : this.message.size  [i]
           ,c:= this.message.Color [i] = "" ? this.message.def_color   : this.message.color [i]
           ,o:= this.message.opt   [i] = "" ? this.message.def_opt     : this.message.opt   [i]
           ,f:= this.message.Font  [i] = "" ? this.message.def_font    : this.message.Font  [i]
           ,m:= this.message.offset[i] = "" ? this.message.def_offset  : this.message.offset[i]
           ,this.GUIObj.setFont("norm s" s " c" c o, f)
           ,this.GUIObj.AddText("xp y+" m, t)
        }
        OnMessage(0x202, this.closeObj)
       ,this.exist:=True
        if this.sound
            SoundPlay("*-1")
        this.GUIObj.show((this.activate?"":"NoActivate ") "AutoSize x" this.x " y" this.y)

        try GUIOld.destroy()
        if this.life
            setTimer(this.closeObj, -this.life)
        else try setTimer(this.closeObj, "Off")
        for _,k in this.closekeys
            Hotkey(k, this.closeObj, "On B0 T1")
        return
    }
    close(wparam:="",lParam:="",msg:="",hwnd:=""){
        if hwnd AND !(this.exist AND hwnd=this.GUIObj.hwnd)
            return

        for _,k in this.closekeys
            Hotkey(k, "Off")
        try this.GUIObj.Destroy()
        return this.exist:=False
    }
}