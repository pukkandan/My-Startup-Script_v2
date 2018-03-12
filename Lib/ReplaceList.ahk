replaceList(def, opt, levels:=0, replace:=False, inner:=1) {
    x:= replace? def: def.clone()
    if IsObject(opt)
        for i,val in opt
            if (!levels or inner<levels) and isObject(val)
                x[i]:=replaceList(def[i], val, levels, False, inner+1)
            else x[i]:=val
    return x
}