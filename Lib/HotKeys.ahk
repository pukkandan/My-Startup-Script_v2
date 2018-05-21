; UNTESTED AND UNUSED

class Hotkeys{
    static keyList:={}

    assign(cndn:=0,key,name:="",f,mode:="Single",opt:=""){
    ; opt only works if given to the first assignment in a given "cndn.key"

        ;If there are modifiers, key must be an array containing modifiers and main key seperately. Eg: #!v:: ==> Hotkeys.assign({"#!","v"},...)
        if !IsObject(key)
            keyName:=key, key:=["",key]
        else keyName:=key[1] key[2]

        ; Generates name if not provided
        if !name ;0 is reserved for settings and "" can't be used
            name:=this.keyList.length()+1

        ;creates hotkey if it doesn't exist
        if !this.keyList.hasKey(cndn) OR !this.keyList[cndn].hasKey(keyName) {
            Hotkey("If", cndn||"") ;x||y <=> x?x:y in AHK
           ,Hotkey(keyName, objbindMethod(this, "pressed", keyName, cndn), opt)
           ,Hotkey("If")
            if !this.keyList.hasKey(cndn)
                this.keyList[cndn]:={}
            this.keyList[cndn][keyName]:={0:{key:key,mode:mode}}
        }

        ; updates mode of the hotkey if necessary
        if this.keyList[cndn][keyName][0].mode="Single"
            this.keyList[cndn][keyName][0].mode:=mode
        else if this.keyList[cndn][keyName][0].mode="Long" AND mode="Double"
            this.keyList[cndn][keyName][0].mode:="Double"

        ;saves details in the object
        this.keyList[cndn][keyName][name]:={f:f,mode:mode}
        return name
    }

    pressed(keyName,cndn){
        fList:=this.keyList[cndn][keyName], state:="Single", key:=fList[0].key[2]
        key:=strLen(key)>1? regExReplace(key,"[{}]") :key ;Removes {} except when key is actually { or }

        ;Determines the mode
        if fList[0].mode!="Single" {
            if !keyWait(key,"T0.2")
                state:="Long"
            else if fList[0].mode!="Double" {
                if keyWait(key,"D T0.2")
                    state:="Double"
            }
        }

        ; calls all functions assigned with that mode
        for name,prop in fList
            if !name
                continue
            else if prop.mode=state
                Func(prop.f).call()
        return
    }

    edit(cndn:=0,keyName,name,changes:=""){ ; f and mode can be changed.
        return replaceList(this.keyList[cndn][keyName][name], changes,, True)
    }

    delete(cndn:=0,keyName:="",name:=""){

        if cndn:="All" {
        ;Pass cndn="All" to remove entire key removing associated hotkeys. name is irrelevent in this case
            for cndn in this.keyList {
                Hotkey("If", cndn||"") ;x||y <=> x?x:y in AHK
               ,Hotkey(keyName, "Off")
               ,Hotkey("If")
               ,retVal+=this.keyList[cndn].delete(keyName)
            }
            return retVal
        }

        if !this.keyList.haskey(cndn) ; cndn doesn't exist
            return 0

        else if keyName="" { ; No key is given. Delete the entire cndn removing associated hotkeys
            Hotkey("If", cndn||"") ;x||y <=> x?x:y in AHK
            for keyName in this.keyList[cndn]
               Hotkey(keyName, "Off")
            Hotkey("If")
            return this.keyList.delete(cndn)
        }

        else if !this.keyList[cndn].hasKey(keyName) ; "cndn.key" doesn't exist
            return 0

        else if !name { ; No name is given. Delete the entire "cndn.key" removing associated hotkey
            Hotkey("If", cndn||"") ;x||y <=> x?x:y in AHK
           ,Hotkey(keyName, "Off")
           ,Hotkey("If")
            return this.keyList[cndn].delete(keyname)
        }

        retVal:=this.keyList[cndn][keyName].delete(name) ;Delete "key.cndn.name"
        for _ in this.keyList[cndn][keyName]
            return retVal ; If there are still elements in "cndn.key", return

        Hotkey("If", cndn||"")  ; else delete "cndn.key" removing associated hotkey ;x||y <=> x?x:y in AHK
       ,Hotkey(keyName, "Off")
       ,Hotkey("If")
       ,this.keyList[cndn].delete(keyName)
        return retVal
    }

}