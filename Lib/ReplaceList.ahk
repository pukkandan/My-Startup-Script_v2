replaceList(def, opt, levels:=0, replace:=False, _inner:=1) { ; _inner is for internal use
    x:= replace? def: def.clone()
    if IsObject(opt)
        for i,val in opt
            if (!levels or _inner<levels) and isObject(val)
                x[i]:=replaceList(def[i], val, levels, False, _inner+1)
            else x[i]:=val
    return x
}