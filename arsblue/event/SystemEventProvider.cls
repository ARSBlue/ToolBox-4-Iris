/// The system event provider generates event for ISC IRIS startup/shutdown, user login/logout, job start/end and external programm start/end events.
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.SystemEventProvider Extends arsblue.event.EventProvider [ Abstract ]
{

/// This method will be called by <code>^%ZSTART</code> and <code>^%ZSTOP</code> system routines to create system events.
/// <ul>
/// <li>Type...the system event type:<ul>
///   <li>SYSTEM...for ISC IRIS startup/shutdown.</li>
///   <li>LOGIN...for user login/logout.</li>
///   <li>JOB...for background process start/stop.</li>
///   <li>CALLIN...for external program start/stop.</li>
///   <li>CALLOUT...for operating system command or program execution start/stop.</li>
///   </ul></li>
/// <li>Action...if action=1 the given type is a startup, login or start event, if action=2 the given type is a shutdown, logout or stop event.</li>
/// </ul>
/// Returns status OK if successfully created and fired event, any other status signals failure!
ClassMethod FireSystemEvent(Type As %String = "", Action As %Integer = 0, ActionDetails As %DynamicObject = {$$$NULLOREF}) As %Status
{
	set type=$ZCVT(Type,"U")
	$$$QuitIf('$CASE(type,"SYSTEM":$$$YES,"LOGIN":$$$YES,"JOB":$$$YES,"CALLIN":$$$YES,"CALLOUT":$$$YES,:$$$NO),"cannot fire event for unknown type "_Type)
	set action=+Action
	$$$QuitIf('$CASE(action,1:$$$YES,2:$$$YES,:$$$NO),"cannot fire event for unknown action "_Action)
	
	set sql($I(sql))="select ID as ""EventListenerId"""
	set sql($I(sql))=" from arsblue_event.SystemEventListener"
	set sql($I(sql))=" where EventRun=1"
	set sql($I(sql))=" and Type"_$ZCVT(type,"W")_" in (?,3)" // ?=action
	
	set stmt=##class(%SQL.Statement).%New()
	$$$QuitOnError(stmt.%Prepare(.sql))
	$$$QuitOnSQLError(rs,stmt.%Execute(action))
	
	#dim status as %Status=$$$OK
	while (rs.%Next(.status))
	{
		$$$BreakOnError(status)
		set event=##class(arsblue.event.SystemEvent).%New()
		set event.Type=type
		set event.Action=action
		set:($IsObject(ActionDetails)) event.ActionDetails=ActionDetails
		set eventListener=##class(arsblue.event.SystemEventListener).%OpenId(rs.EventListenerId)
		do:($IsObject(eventListener)) eventListener.FireEvent(event)
		kill event,eventListener
	}
	quit status
}

}
