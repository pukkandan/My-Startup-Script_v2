;                  .NET Framework Interop
;      http://www.autohotkey.com/forum/topic26191.html

;Example
#Persistent
msgbox(CLR.loadLibrary("interception.dll").CreateInstance("InterceptionWrapper").Test())

class CLR {
    _getnull(){
        if this._null
            return this._null
        null0 := ComObject(13,0)
        return this._null:=null0[]
    }

    loadLibrary(AssemblyName, AppDomain:=0) {
        if !AppDomain
            AppDomain:= this._getDefaultDomain()
        e:= ComObjError(0)
       ,this._getnull()

        if !assembly:= AppDomain.Load_2(AssemblyName) {
            args:= ComObjArray(0xC, 1)
           ,args[0]:= AssemblyName
           ,typeofAssembly:= AppDomain.GetType().Assembly.GetType()
            if !assembly:= typeofAssembly.InvokeMember_3("LoadWithPartialName", 0x158, this._null, this._null, args)
                assembly:= typeofAssembly.InvokeMember_3("LoadFrom"           , 0x158, this._null, this._null, args)
        }


        ComObjError(e)
        return assembly
    }

    createObject(Assembly, TypeName, Args*) {
        if !(argCount:= Args.MaxIndex())
            return Assembly.CreateInstance_2(TypeName, true)

        this._getnull()
       ,vargs:= ComObjArray(0xC, argCount)
        Loop argCount
            vargs[A_Index-1]:= Args[A_Index]

        static Array_Empty:= ComObjArray(0xC,0)

        return Assembly.CreateInstance_3(TypeName, true, 0, this._null, vargs, this._null, Array_Empty)
    }

    compileCSharp(Code, References:="", AppDomain:=0, FileName:="", CompilerOptions:="") {
        return this._compileAssembly(Code, References, "System", "Microsoft.CSharp.CSharpCodeProvider", AppDomain, FileName, CompilerOptions)
    }

    compileVB(Code, References:="", AppDomain:=0, FileName:="", CompilerOptions:="") {
        return this._compileAssembly(Code, References, "System", "Microsoft.VisualBasic.VBCodeProvider", AppDomain, FileName, CompilerOptions)
    }

    startDomain(ByRef AppDomain, BaseDirectory:="") {
        this._getnull()
       ,args:= ComObjArray(0xC, 5), args[0]:= "", args[2]:= BaseDirectory, args[4]:= ComObject(0xB,false)
       ,AppDomain:= this._getDefaultDomain().GetType().InvokeMember_3("CreateDomain", 0x158, this._null, this._null, args)
        return A_LastError >= 0
    }

    stopDomain(ByRef AppDomain) {   ; ICorRuntimeHost::UnloadDomain
        DllCall("SetLastError", "uint", hr:= DllCall(NumGet(NumGet(0+RtHst:=this.start())+20*A_PtrSize), "ptr", RtHst, "ptr", ComObjValue(AppDomain))), AppDomain:= ""
        return hr >= 0
    }

    ; NOTE: IT IS NOT NECESSARY TO CALL THIS FUNCTION unless you need to load a specific version.
    start(Version:="") { ; returns ICorRuntimeHost*
        static RtHst:= 0
        if RtHst
            return RtHst
        if !Version
            Loop Files, envGet("SystemRoot") "\Microsoft.NET\Framework" (A_PtrSize=8?"64":"") "\*", "D"
                if FileExist(A_LoopFileFullPath "\mscorlib.dll") AND A_LoopFileName>Version
                    Version:= A_LoopFileName
        if !Version {
            MsgBox(".NET not found","CLR", 16)
            return False
        }

        if DllCall("mscoree\CorBindToRuntimeEx", "wstr", Version, "ptr", 0, "uint", 0
                , "ptr", this._GUID(CLSID_CorRuntimeHost, "{CB2F6723-AB3A-11D2-9C40-00C04FA30A3E}")
                , "ptr", this._GUID(IID_ICorRuntimeHost , "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}")
                , "ptr*", RtHst)>=0
            DllCall(NumGet(NumGet(RtHst+0)+10*A_PtrSize), "ptr", RtHst) ; Start
        return RtHst
    }

    _getDefaultDomain() {
        static defaultDomain:= 0
        if !defaultDomain ; ICorRuntimeHost::getDefaultDomain
            if DllCall(NumGet(NumGet(RtHst:=this.start())+13*A_PtrSize), "ptr", RtHst, "ptr*", p:=0)>=0 {
                defaultDomain:=ComObject(p)
               ,ObjRelease(p)
           }
        return defaultDomain
    }

    _compileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain:=0, FileName:="", CompilerOptions:="") {
        if !AppDomain
            AppDomain:= this._getDefaultDomain()

        if !(asmProvider:= this.loadLibrary(ProviderAssembly, AppDomain)
               AND codeProvider:= asmProvider.CreateInstance(ProviderType)
               AND codeCompiler:= codeProvider.CreateCompiler()
               AND asmSystem:= (ProviderAssembly="System") ? asmProvider : this.loadLibrary("System", AppDomain)   )
            return 0

        ; Set parameters for compiler.
        prms:= this.createObject(asmSystem, "System.CodeDom.Compiler.CompilerParameters", StrSplit(References,"|"," `t"))
       ,prms.OutputAssembly         := FileName
       ,prms.GenerateInMemory       := !FileName
       ,prms.GenerateExecutable     := SubStr(FileName,-3)=".exe"
       ,prms.CompilerOptions        := CompilerOptions
       ,prms.IncludeDebugInformation:= true

        ; Compile!
       ,compilerRes:= codeCompiler.this._compileAssemblyFromSource(prms, Code)

        if error_count:= (errors:= compilerRes.Errors).Count {
            error_text:= ""
            Loop error_count
                error_text .= ((e:= errors.Item[A_Index-1]).IsWarning ? "Warning " : "Error ") . e.ErrorNumber " on line " e.Line ": " e.ErrorText "`n`n"
            MsgBox(error_text, "Compilation Failed", 16)
            return 0
        }
        ; Success. Return Assembly object or path.
        return compilerRes[FileName="" ? "CompiledAssembly" : "PathToAssembly"]
    }

    _GUID(ByRef GUID, sGUID) {
        VarSetCapacity(GUID, 16, 0)
        return DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", &GUID) >= 0 ? &GUID : ""
    }
}