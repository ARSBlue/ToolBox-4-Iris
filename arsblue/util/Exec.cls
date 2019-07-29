Include (arsblue.OS, arsblue.Status, arsblue.util.Json)

/// This class contains utilities for executing operating system commands or programs
Class arsblue.util.Exec Extends %RegisteredObject [ Abstract ]
{

/// Execute an operating system command or prorgam.
/// NOTE: in case of sync command execution the calling method is responsible for cleanup of any temporary files (STDIN, STDOUT, STDERR)!
/// <ul>
/// <li>program...the operating system command or program to execute.</li>
/// <li>path...the path were the program shall be executed.<li>
/// <li>stdin...the input stream for the program (optional).</li>
/// <li>stdout...the output stream for the program (optional, if not in async mode and current $IO is specified, the stdout is redirected to the current device).</li>
/// <li>stderr...the error stream for the program (optional, if stderr and stdout are the same stream, the result of both is written in the same stream,
///     if not in async mode and current $IO is specified, the stderr is redirected to the current device).</li>
/// <li>async...true if the program shall run in background, false (default) otherwise.</li>
/// <li>pid...the operating system process id for this execution.</li>
/// <li>callback...a callback function to run when the execution of program finished (regardless if its running async or sync).
/// 	The callback must be a valid classname.classmethod string and the implementation must accept the given parameters for callback.
/// 	The following global variables will be available in callback:<ul>
/// 		<li>%program...the operating system command or programm executed.</li>
/// 		<li>%path...the path where the program shall be executed.</li>
///     <li>%in...the STDIN stream if available, null otherwise.</li>
///     <li>%out...the STDOUT stream.</li>
///     <li>%err...the STDERR stream.</li>
/// 		<li>%pid...the operating process id for this execution.</li>
/// 	</ul></li>
/// <li>params...the parameters for callback function.</li>
/// Returns status OK if successfully executed program, any other status signals failure.</li>
ClassMethod Call(program As %String = "", path As %String = "", stdin As %Stream.Object = {$$$NULLOREF}, ByRef stdout As %Stream.Object = {$$$NULLOREF}, ByRef stderr As %Stream.Object = {$$$NULLOREF}, async As %Boolean = {$$$NO}, ByRef pid As %Integer = 0, callback As %String = {$$$NULLOREF}, params...) As %Status [ ProcedureBlock = 0 ]
{
	// NOTE: since atelier plugin cannot handle syntax check for $ZF(-100,flags,program,.args) we need a workaround => ProcedureBlock=0 and xecute "$ZF(-100..."
	new (program,path,stdin,stdout,stderr,async,pid,callback,params)
	
	set cmd=program
	set stdinFilename=""
	set stdoutFilename=""
	set stderrFilename=""
	
	#dim status as %Status=$$$OK
	try
	{
		set flags="/SHELL /NOQUOTE" // there are no commands available in Windows not needing shell (search in path for commands without shell does not work!)
		set:(async) flags=flags_" /ASYNC"
		
		if ('$$$ISNULL(path)) // change to execution path
		{
			set path = ##class(%File).NormalizeFilename(path)
			if ($$$isVMS)
			{
				set cmd = "PIPE SET DEFAULT "_path_" && "_cmd
			}
			elseif ($$$isWINDOWS)
			{
				set cmd = "cd "_path_" && "_cmd
			}
			elseif ($$$isUNIX)
			{
				set cmd = "cd "_path_" && "_cmd
			}
			else
			{
				$$$Throw($$$ERROR($$$GeneralError,"os not supported to change path"))
			}
		}
		
		if ($IsObject(stdin))
		{
			$$$ThrowIf('$$$TypeOf(stdin,"%Stream.Object"),"cannot use stdin with invalid stream object")
			if ($$$TypeOf(stdin,"%Stream.FileBinary"))
			{
				set stdinFilename=stdin.Filename
			}
			else
			{
				set stdinFilename=##class(%File).TempFilename()
				set fileStream=##class(%Stream.FileBinary).%New()
				$$$ThrowOnError(fileStream.LinkToFile(stdinFilename))
				$$$ThrowOnError(stdin.Rewind())
				$$$ThrowOnError(fileStream.CopyFromAndSave(stdin))
			}
			set flags=flags_" /STDIN="""_stdinFilename_""""
		}
		
		set stdoutFilename=$S(('async && (stdout=$IO)):"",$$$TypeOf(stdout,"%Stream.FileBinary"):stdout.Filename,1:##class(%File).TempFilename())
		set:(stdoutFilename'="") flags=flags_" /STDOUT="""_stdoutFilename_""""

		set stderrFilename=$S(('async && (stderr=$IO)):"",$$$TypeOf(stderr,"%Stream.FileBinary"):stderr.Filename,($IsObject(stdout) && (stdout=stderr)):stdoutFilename,1:##class(%File).TempFilename())
		set:(stderrFilename'="") flags=flags_" /STDERR="""_stderrFilename_""""
		
		set paramsArray=[]
		if ($D(params)#2)
		{
			set paramIdx=""
			for
			{
				set paramIdx=$O(params(paramIdx),1,paramValue) quit:(paramIdx="")
				do paramsArray.%Set(paramIdx - 1,paramValue)
			}
		}
		
		do:($$$comMemberDefined("arsblue.event.SystemEventProvider",$$$cCLASSmethod,"FireSystemEvent")) $ClassMethod("arsblue.event.SystemEventProvider","FireSystemEvent","CALLOUT",1,({
			"$JOB":($JOB),
			"$IO":($IO),
			"$ROLES":($ROLES),
			"$USERNAME":($USERNAME),
			"ClientIPAddress":($System.Process.ClientIPAddress()),
			"ClientNodeName":($System.Process.ClientNodeName()),
			"UserName":($System.Process.UserName()),
			"program":(program),
			"path":(path),
			"stdin":(stdinFilename),
			"stdout":(stdoutFilename),
			"stderr":(stderrFilename),
			"async":(async),
			"pid":(pid),
			"callback":(callback),
			"params":(paramsArray),
			"cmd":(cmd)
		}))
			
		set pid=0
		xecute "set status=$ZF(-100,flags,cmd),pid=$ZC"
		set status=$S(status=0:$$$OK,1:$$$ERROR($$$GeneralError,program_" returns "_status)) $$$Throw(status)
		
		if ('async)
		{
			if (stdoutFilename'="")
			{
				set:('$$$TypeOf(stdout,"%Stream.FileBinary")) stdout=##class(arsblue.io.TempFileBinary).%New(stdoutFilename)
			}
			else
			{
				set stdout=$$$NULLOREF
			}
			
			if (stderrFilename'="")
			{
				if (stderrFilename=stdoutFilename)
				{
					set stderr=stdout
				}
				else
				{
					set:('$$$TypeOf(stderr,"%Stream.FileBinary")) stderr=##class(arsblue.io.TempFileBinary).%New(stderrFilename)
				}
			}
			else
			{
				set stderr=$$$NULLOREF
			}
			
			if ('$$$ISNULL(callback))
			{
				set classname=$P(callback,".",1,$L(callback,".")-1)
				set classmethod=$P(callback,".",$L(callback,"."))
				new %program,%path,%in,%out,%err,%pid
				set %program=program,%path=path,%in=stdin,%out=stdout,%err=stderr,%pid=pid
				do $ClassMethod(classname,classmethod,params...)
			}
		}
		else
		{
			set ^arsblue.util.ExecD(pid)=$LB(program,path,stdinFilename,stdoutFilename,stderrFilename,callback,cmd)
			merge ^arsblue.util.ExecD(pid,"params")=params
			
			// start callback job if needed
			set callbackRunning=$$$NO
			lock ^arsblue.util.ExecD:0
			else  set callbackRunning=$$$YES
			if ('callbackRunning)
			{
				job ##class(arsblue.util.Exec).Callback()
				lock -^arsblue.util.ExecD
			}
		}
	}
	catch (exc)
	{
		set status=exc.AsStatus()
		if (exc.Name="<NOTOPEN>")
		{
			set status=$System.Status.AppendStatus($$$ERROR($$$GeneralError,$System.Process.OSError()),status)
		}
	}
	
	if ('async || $$$ISERR(status))
	{
		do:($$$comMemberDefined("arsblue.event.SystemEventProvider",$$$cCLASSmethod,"FireSystemEvent")) $ClassMethod("arsblue.event.SystemEventProvider","FireSystemEvent","CALLOUT",2,({
			"$JOB":($JOB),
			"$IO":($IO),
			"$ROLES":($ROLES),
			"$USERNAME":($USERNAME),
			"ClientIPAddress":($System.Process.ClientIPAddress()),
			"ClientNodeName":($System.Process.ClientNodeName()),
			"UserName":($System.Process.UserName()),
			"program":(program),
			"path":(path),
			"stdin":(stdinFilename),
			"stdout":(stdoutFilename),
			"stderr":(stderrFilename),
			"async":(async),
			"pid":(pid),
			"callback":(callback),
			"params":(paramsArray),
			"cmd":(cmd),
			"status":($$$JSON.GetJSONFromStatus(status))
		}))
	}
			
	quit status
}

/// This method will be called internal on async execution of an operating system command or program.
/// NOTE: Do not call this method - for internal use only!
ClassMethod Callback()
{
	lock ^arsblue.util.ExecD
	
	while ($$$YES)
	{
		if ('$D(^arsblue.util.ExecD))
		{
			lock -^arsblue.util.ExecD
			quit
		}
		
		hang 0.5 // give other processes time
		
		set pid=""
		while ($$$YES)
		{
			set pid=$O(^arsblue.util.ExecD(pid),1,programInfo) quit:(pid)=""
			continue:(..IsProcessRunning(pid,.status))
			
			set program=$LG(programInfo,1)
			set path=$LG(programInfo,2)
			set stdinFilename=$LG(programInfo,3)
			set stdoutFilename=$LG(programInfo,4)
			set stderrFilename=$LG(programInfo,5)
			set async=$$$YES
			set callback=$LG(programInfo,6)
			set cmd=$LG(programInfo,7)
			kill params
			merge params=^arsblue.util.ExecD(pid,"params")

			if ($$$ISOK(status) && ('$$$ISNULL(callback)))
			{
				try
				{
					if ($$$ISNULL(stdinFilename))
					{
						set stdin=$$$NULLOREF
					}
					else
					{
						set stdin=##class(%Stream.FileBinary).%New()
						$$$ThrowOnError(stdin.LinkToFile(stdinFilename))
					}
					
					set stdout=##class(%Stream.FileBinary).%New()
					$$$ThrowOnError(stdout.LinkToFile(stdoutFilename))
					
					set stderr=##class(%Stream.FileBinary).%New()
					$$$ThrowOnError(stderr.LinkToFile(stderrFilename))
					
					set classname=$P(callback,".",1,$L(callback,".")-1)
					set classmethod=$P(callback,".",$L(callback,"."))
					new %program,%path,%in,%out,%err,%pid
					set %program=program,%path=path,%in=stdin,%out=stdout,%err=stderr,%pid=pid
					do $ClassMethod(classname,classmethod,params...)
				}
				catch (exc)
				{
					set status=exc.AsStatus()
				}
			}
			
			set paramsArray=[]
			if ($D(params)#2)
			{
				set paramIdx=""
				for
				{
					set paramIdx=$O(params(paramIdx),1,paramValue) quit:(paramIdx="")
					do paramsArray.%Set(paramIdx - 1,paramValue)
				}
			}
			
			do:($$$comMemberDefined("arsblue.event.SystemEventProvider",$$$cCLASSmethod,"FireSystemEvent")) $ClassMethod("arsblue.event.SystemEventProvider","FireSystemEvent","CALLOUT",2,({
				"$JOB":($JOB),
				"$IO":($IO),
				"$ROLES":($ROLES),
				"$USERNAME":($USERNAME),
				"ClientIPAddress":($System.Process.ClientIPAddress()),
				"ClientNodeName":($System.Process.ClientNodeName()),
				"UserName":($System.Process.UserName()),
				"program":(program),
				"path":(path),
				"stdin":(stdinFilename),
				"stdout":(stdoutFilename),
				"stderr":(stderrFilename),
				"async":(async),
				"pid":(pid),
				"callback":(callback),
				"params":(paramsArray),
				"cmd":(cmd),
				"status":($$$JSON.GetJSONFromStatus(status))
			}))
			
			kill stdin,stdout,stderr
			do:('$$$ISNULL(stdinFilename)) ##class(%File).Delete(stdinFilename)
			do ##class(%File).Delete(stdoutFilename)
			do ##class(%File).Delete(stderrFilename)
			
			kill ^arsblue.util.ExecD(pid)
		}
	}
	
	quit
}

/// This method checks if a process with a given id is running or not.
/// NOTE: VMS is not supported and the method returns always false!
/// <ul>
/// <li>pid...the process id.</li>
/// <li>status...additional status information if pid couldn't be observed.</li>
/// </ul>
/// Returns true if the process is running, false otherwise.
ClassMethod IsProcessRunning(pid As %Integer = 0, ByRef status As %Status) As %Boolean
{
	set status=$S('pid:$$$ERROR($$$GeneralError,"invalid pid "_pid),$$$isVMS:$$$ERROR($$$GeneralError,"VMS not supported"),1:$$$OK)
	quit:($$$ISERR(status)) $$$NO
	
	set cmd=""
	if ($$$isVMS)
	{
		set cmd="SHOW PROCESS /ID="_pid
	}
	elseif ($$$isWINDOWS)
	{
		set cmd="tasklist /FI ""PID eq "_pid_""" /NH"
	}
	elseif ($$$isUNIX || isMACOSX)
	{
		set cmd="ps aux | grep "_pid
	}
	else
	{
		set status=$$$ERROR($$$GeneralError,"os not supported to list processes")
		quit $$$NO
	}
	
	set status=##class(arsblue.util.Exec).Call(cmd,,,.out,.err)
	if ('$$$ISERR(status))
	{
		set status=out.Rewind() quit:($$$ISERR(status)) $$$NO
		
		set found=$$$NO
		while ('out.AtEnd)
		{
			set line=out.ReadLine(,.status) quit:($$$ISERR(status))
			if ($F($TR(line,$C(9,160),"  ")," "_pid_" "))
			{
				set found=$$$YES
				quit
			}
		}
	}
	
	quit $S($$$ISOK(status):$S(found:$$$YES,1:$$$NO),1:$$$NO)
}

}
