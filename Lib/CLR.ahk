; ==========================================================
;                  .NET Framework Interop
;      http://www.autohotkey.com/forum/topic26191.html
; ==========================================================
;
;   Author:     Lexikos
;   Version:    1.2
;   Requires:   AutoHotkey_L v1.0.96+
;
; Modified by evilC for compatibility with AHK_H as well as AHK_L
; "null" is a reserved word in AHK_H, so did search & Replace from "null" to "_null"
class CLR {
    loadLibrary(AssemblyName, AppDomain=0) {
        if !AppDomain
            AppDomain := _getDefaultDomain()
        e := ComObjError(0)
        Loop 1 {
            if assembly := AppDomain.Load_2(AssemblyName)
                break
            static _null := ComObject(13,0)
            args := ComObjArray(0xC, 1),  args[0] := AssemblyName
           ,typeofAssembly := AppDomain.GetType().Assembly.GetType()
            if assembly := typeofAssembly.InvokeMember_3("LoadWithPartialName", 0x158, _null, _null, args)
                break
            if assembly := typeofAssembly.InvokeMember_3("LoadFrom", 0x158, _null, _null, args)
                break
        }
        ComObjError(e)
       ,return assembly
    }

    createObject(Assembly, TypeName, Args*) {
        if !(argCount := Args.MaxIndex())
            return Assembly.CreateInstance_2(TypeName, true)

        vargs := ComObjArray(0xC, argCount)
        Loop % argCount
            vargs[A_Index-1] := Args[A_Index]

        static Array_Empty := ComObjArray(0xC,0), _null := ComObject(13,0)

        return Assembly.CreateInstance_3(TypeName, true, 0, _null, vargs, _null, Array_Empty)
    }

    compileCSharp(Code, References="", AppDomain=0, FileName="", CompilerOptions="") {
        return _compileAssembly(Code, References, "System", "Microsoft.CSharp.CSharpCodeProvider", AppDomain, FileName, CompilerOptions)
    }

    compileVB(Code, References="", AppDomain=0, FileName="", CompilerOptions="") {
        return _compileAssembly(Code, References, "System", "Microsoft.VisualBasic.VBCodeProvider", AppDomain, FileName, CompilerOptions)
    }

    startDomain(ByRef AppDomain, BaseDirectory="") {
        static _null := ComObject(13,0)
        args := ComObjArray(0xC, 5), args[0] := "", args[2] := BaseDirectory, args[4] := ComObject(0xB,false)
       ,AppDomain := _getDefaultDomain().GetType().InvokeMember_3("CreateDomain", 0x158, _null, _null, args)
        return A_LastError >= 0
    }

    stopDomain(ByRef AppDomain) {   ; ICorRuntimeHost::UnloadDomain
        DllCall("SetLastError", "uint", hr := DllCall(NumGet(NumGet(0+RtHst:=    Start())+20*A_PtrSize), "ptr", RtHst, "ptr", ComObjValue(AppDomain))), AppDomain := ""
        return hr >= 0
    }

    ; NOTE: IT IS NOT NECESSARY TO CALL THIS FUNCTION unless you need to load a specific version.
    start(Version="") { ; returns ICorRuntimeHost*
        static RtHst := 0
        ; The simple method gives no control over versioning, and seems to load .NET v2 even when v4 is present:
        ; return RtHst ? RtHst : (RtHst:=COM_CreateObject("CLRMetaData.CorRuntimeHost","{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"), DllCall(NumGet(NumGet(RtHst+0)+40),"uint",RtHst))
        if RtHst
            return RtHst
        EnvGet SystemRoot, SystemRoot
        if !Version
            Loop % SystemRoot "\Microsoft.NET\Framework" (A_PtrSize=8?"64":"") "\*", 2
                if FileExist(A_LoopFileFullPath "\mscorlib.dll") && A_LoopFileName > %Version%
                    Version := A_LoopFileName
        if DllCall("mscoree\CorBindToRuntimeEx", "wstr", Version, "ptr", 0, "uint", 0
                , "ptr", _GUID(CLSID_CorRuntimeHost, "{CB2F6723-AB3A-11D2-9C40-00C04FA30A3E}")
                , "ptr",  _GUID(IID_ICorRuntimeHost,  "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}")
                , "ptr*", RtHst) >= 0
            DllCall(NumGet(NumGet(RtHst+0)+10*A_PtrSize), "ptr", RtHst) ; Start
        return RtHst
    }

    _getDefaultDomain() {
        static defaultDomain := 0
        if !defaultDomain { ; ICorRuntimeHost::_getDefaultDomain
            if DllCall(NumGet(NumGet(0+RtHst:=    Start())+13*A_PtrSize), "ptr", RtHst, "ptr*", p:=0) >= 0
                defaultDomain := ComObject(p), ObjRelease(p)
        }
        return defaultDomain
    }

    _compileAssembly(Code, References, ProviderAssembly, ProviderType, AppDomain=0, FileName="", CompilerOptions="") {
        if !AppDomain
            AppDomain := _getDefaultDomain()

        if !(asmProvider := LoadLibrary(ProviderAssembly, AppDomain)
               AND codeProvider := asmProvider.CreateInstance(ProviderType)
               AND codeCompiler := codeProvider.CreateCompiler()
               AND asmSystem := (ProviderAssembly="System") ? asmProvider : LoadLibrary("System", AppDomain)   )
            return 0

        ; Convert | delimited list of references into an array.
        StringSplit, Refs, References, |, %A_Space%%A_Tab%
        aRefs := ComObjArray(8, Refs0)
        Loop % Refs0
            aRefs[A_Index-1] := Refs%A_Index%

        ; Set parameters for compiler.
        prms := CreateObject(asmSystem, "System.CodeDom.Compiler.CompilerParameters", aRefs)
       ,prms.OutputAssembly          := FileName
       ,prms.GenerateInMemory        := FileName=""
       ,prms.GenerateExecutable      := SubStr(FileName,-3)=".exe"
       ,prms.CompilerOptions         := CompilerOptions
       ,prms.IncludeDebugInformation := true

        ; Compile!
       ,compilerRes := codeCompiler._compileAssemblyFromSource(prms, Code)

        if error_count := (errors := compilerRes.Errors).Count
        {
            error_text := ""
            Loop % error_count
                error_text .= ((e := errors.Item[A_Index-1]).IsWarning ? "Warning " : "Error ") . e.ErrorNumber " on line " e.Line ": " e.ErrorText "`n`n"
            MsgBox, 16, Compilation Failed, %error_text%
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