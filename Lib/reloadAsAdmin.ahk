reloadAsAdmin(force:="True"){
    if A_IsAdmin
        return 0
    try{
        Run("*RunAs " (A_IsCompiled? "": "`""  A_AhkPath "`" ") "`"" A_ScriptFullPath "`"")
        ExitApp
        } catch e
            return _reloadAsAdmin_Error(e,force)
    }

;http://ahkscript.org/boards/viewtopic.php?t=4334
reloadAsAdmin_Task(force:=True) { ;  By SKAN,  http://goo.gl/yG6A1F,  CD:19/Aug/2014 | MD:22/Aug/2014
    ; Asks for UAC only first time

    ;local CmdLine, TaskName, TaskExists, XML, TaskSchd, TaskRoot, RunAsTask
    TASK_CREATE := 0x2,  TASK_LOGON_INTERACTIVE_TOKEN := 3

    try {
        TaskSchd := ComObjCreate("Schedule.Service")
       ,TaskSchd.Connect()
    }
   catch e
      return _reloadAsAdmin_Error(e,force)

    CmdLine := (A_IsCompiled? "": "`""  A_AhkPath "`" ") "`"" A_ScriptFullpath "`""
   ,TaskName:= A_ScriptName " @" SubStr("000000000"
        DllCall("NTDLL\RtlComputeCrc32", "Int",0, "WStr",CmdLine, "UInt",StrLen(CmdLine)*2, "UInt"), -9)

    Try {
        Try TaskRoot:= TaskSchd.GetFolder("\AHK-ReloadAsAdmin")
        catch
            TaskRoot:= TaskSchd.GetFolder("\"), TaskName:= "[AHK-ReloadAsAdmin]" TaskName
        RunAsTask:= TaskRoot.GetTask( TaskName )
    }
    catch {
        if A_IsAdmin {
            XML:= "
            (
                <?xml version="1.0" ?> <Task xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
                <RegistrationInfo /> <Triggers />
                <Principals> <Principal id="Author">
                        <LogonType>InteractiveToken</LogonType> <RunLevel>HighestAvailable</RunLevel>
                </Principal> </Principals>
                <Settings>
                    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
                    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
                    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
                    <AllowHardTerminate>false</AllowHardTerminate>
                    <StartWhenAvailable>false</StartWhenAvailable>
                    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
                    <IdleSettings> <StopOnIdleEnd>true</StopOnIdleEnd> <RestartOnIdle>false</RestartOnIdle> </IdleSettings>
                    <AllowStartOnDemand>true</AllowStartOnDemand>
                    <Enabled>true</Enabled>
                    <Hidden>false</Hidden>
                    <RunOnlyIfIdle>false</RunOnlyIfIdle>
                    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
                    <UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine>
                    <WakeToRun>false</WakeToRun>
                    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
                </Settings>
                <Actions Context="Author"> <Exec> <Command>
            )"
           ,XML.= (A_IsCompiled? A_ScriptFullpath: A_AhkPath) "</Command>"
           ,XML.="<Arguments>" (!A_IsCompiled? "`"" A_ScriptFullpath "`"" :"") "</Arguments>"
           ,XML.="<WorkingDirectory>" A_ScriptDir "</WorkingDirectory></Exec></Actions></Task>"

           ,TaskRoot.RegisterTask(TaskName, XML, TASK_CREATE, "", "", TASK_LOGON_INTERACTIVE_TOKEN)
        }
        else reloadAsAdmin(force)
    }
    return 0
}


_reloadAsAdmin_Error(e,force){
    if force {
        MsgBox("Couldn't restart script!!`nError Code: " e, "FATAL ERROR!!", 0x1010)
        ExitApp
    }
    return 1
}