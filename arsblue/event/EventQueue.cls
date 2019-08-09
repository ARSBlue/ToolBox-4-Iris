Include (arsblue.OS, arsblue.Status)

/// This class defines an event queue.
/// An event queue is reponsible for a list of event listeners to handle them automatically like non-static listeners. 
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.EventQueue Extends (%Persistent, arsblue.event.SystemEventAdapter)
{

/// The name of the event queue.
Property Name As %String [ Required ];

/// The event queue run flag.
/// If this flag is set to true, the event queue starts immediately event listening until the flag is set to false.
Property EventRun As %Boolean [ InitialExpression = {$$$NO} ];

/// The event log level.
/// An event log level of INFO contains also WARNINGs and ERRORs, an event log level of WARNING contains also ERRORs,
/// an event log level of ERROR (default) contains only ERRORs, an event log level of NOLOG does not log anything.
Property EventLogLevel As %EnumString(VALUELIST = ",NOLOG,INFO,WARNING,ERROR") [ InitialExpression = "ERROR" ];

/// The event hold on flag.
/// An event hold on flag of WARNING stopps the event queue on WARNINGs and ERRORs (the last event will be retried on next start).
/// An event hold on flag of ERROR (default) stopps the event queue only on ERRORs (the last event will be retried on next start).
/// An event hold on flag of NOHOLD does not stopp at any case (fire and forget).
Property EventHoldOn As %EnumString(VALUELIST = ",NOHOLD,WARNING,ERROR") [ InitialExpression = "ERROR" ];

/// The amount of events processed per lookup (defaults to 10).
/// NOTE: you need to restart the event queue for changes to take place!
Property EventAmountPerLookup As %Integer [ InitialExpression = 10, Required ];

/// The event queue name index.
Index Name On Name [ Unique ];

/// The event queue run index.
Index EventRun On EventRun [ Type = bitmap ];

/// This expression delivers the event queue resource.
Method GetEventQueueResource() As %String
{
	quit $$$NspDest(..%ClassName(1))_"("""_..%Id()_""")"
}

/// This trigger is responsible for starting and stopping of the event listener
Trigger EventQueueAfter [ Event = INSERT/UPDATE/DELETE, Foreach = row/object, Time = AFTER ]
{
	// on new event queue: check to create a system event for all event queues for startup and shutdown
	if (({%%OPERATION}="INSERT") && ('$IsObject(##class(arsblue.event.SystemEvent).GetEventListener({%%CLASSNAMEQ},$$$NO,,"SYSTEM"))))
	{
		do ##class(arsblue.event.SystemEvent).AddEventListener(,{%%CLASSNAMEQ},$$$NO,,"SYSTEM")
	}
	
	if ($CASE({%%OPERATION},"INSERT":$$$YES,"UPDATE":$$$YES,:$$$NO))
	{
		if ({EventRun*O}'={EventRun*N})
		{
			do:({EventRun*N}) ..Start({Name*N})
			do:('{EventRun*N}) ..Stop({Name*N})
		}
	}
	else
	{
		do $System.Event.Delete($$$NspDest({%%CLASSNAMEQ})_"("""_{ID}_""")")
	}
}

/// This method runs an event queue by name.
Method Run() As %Status [ Private ]
{
	$$$QuitIf('$System.Event.Create(..GetEventQueueResource()),"cannot start already running event queue "_Name)

	kill sql
	set sql($I(sql))="select top "_..EventAmountPerLookup_" e.ID as ""EventId"""
	set sql($I(sql))=" from arsblue_event.EventQueue eq"
	set sql($I(sql))=" right join arsblue_event.EventListener el on eq.ID=el.EventQueue"
	set sql($I(sql))=" right join arsblue_event.Event e on el.ID=e.EventListener"
	set sql($I(sql))=" where eq.ID=?"
	set sql($I(sql))=" order by e.ID"
	
	set stmt=##class(%SQL.Statement).%New()
	$$$QuitOnError(stmt.%Prepare(.sql))
	
	set eventQueueId=..%Id()
	while ($System.Event.Defined(..GetEventQueueResource()))
	{
		hang 0.1 // give the others CPU time
		do ..%LoadData(eventQueueId) // reload data
		
		$$$ContinueOnSQLError(rs,stmt.%Execute(eventQueueId))
		
		while (rs.%Next(.status))
		{
			$$$ContinueOnError(status)
			
			set event=$$$NULLOREF
			set eventId=rs.EventId
			
			#dim status as %Status=$$$OK
			try
			{
				set event=##class(arsblue.event.Event).%OpenId(eventId,,.status) $$$Throw(status)
				set status=event.FireEvent()
			}
			catch (exc)
			{
				set status=exc.AsStatus()
			}
			
			do ##class(arsblue.event.EventQueueLog).Log($this,event,status)
			
			if ($$$ISERR(status) && (($$$ISWARNING(status) && (..EventHoldOn="WARNING")) || ('$$$ISWARNING(status) && (..EventHoldOn="ERROR"))))
			{
				do:($IsObject(event)) event.RestoreEvent()
				do ..Stop(..Name)
				quit
			}
			kill event
		}
	}
	quit $$$OK
}

/// This method starts an event queue by name.
/// <ul>
/// <li>Name...the event queue name.</li>
/// <li>ServerMode...true (default) if the event queue shall run as separate process in background, false otherwise.</li>
/// </ul>
/// Returns status OK if successfully started/running event queue, any other status signals failure!
ClassMethod Start(Name As %String = "", ServerMode As %Boolean = {$$$YES}) As %Status
{
	set eventQueue=##class(arsblue.event.EventQueue).NameOpen(Name,0)
	$$$QuitIf('$IsObject(eventQueue),"cannot start unknown event queue "_Name)
	if (ServerMode)
	{
		job ..Start(Name,$$$NO)
		quit $$$OK
	}
	else
	{
		quit eventQueue.Run()
	}
}

/// This method stops an event queue by name.
/// <ul>
/// <li>Name...the event queue name.</li>
/// </ul>
/// Returns status OK if successfully stopped event queue, any other status signals failure!
ClassMethod Stop(Name As %String = "") As %Status
{
	set eventQueue=##class(arsblue.event.EventQueue).NameOpen(Name,0)
	$$$QuitIf('$IsObject(eventQueue),"cannot stopp unknown event queue "_Name)
	$$$QuitIf('$System.Event.Delete(eventQueue.GetEventQueueResource()),"cannot shutdown already stopped event queue "_Name)
	quit $$$OK
}

/// This method will be called when a system event was fired.
/// <ul>
/// <li>Event...the system event.</li>
/// </ul>
/// Returns status OK if successfully processed event, any other status signals warning or failure (only relevant for event queue)!
ClassMethod OnSystemEvent(Event As arsblue.event.SystemEvent) As %Status
{
	set stmt=##class(%SQL.Statement).%New()
	$$$QuitOnError(stmt.%Prepare("select Name, EventRun from arsblue_event.EventQueue"))
	$$$QuitOnSQLError(rs,stmt.%Execute())
	
	while (rs.%Next(.status))
	{
		$$$ContinueOnError(status)
		set Name=rs.Name,EventRun=rs.EventRun
		
		if (Event.Action = 1) // startup
		{
			set EventRun=$G(^arsblue.event.EventQueueI("$SystemEvent",Name),EventRun)
			kill ^arsblue.event.EventQueueI("$SystemEvent",Name)
			do:(EventRun) ..Start(Name)
		}
		else // 2 = shutdown
		{
			set ^arsblue.event.EventQueueI("$SystemEvent",Name)=EventRun
			do:(EventRun) ..Stop(Name)
		}		
	}
	
	quit $$$OK
}

Storage Default
{
<Data name="EventQueueDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>EventRun</Value>
</Value>
<Value name="4">
<Value>EventLogLevel</Value>
</Value>
<Value name="5">
<Value>EventHoldOn</Value>
</Value>
<Value name="6">
<Value>EventAmountPerLookup</Value>
</Value>
</Data>
<DataLocation>^arsblue.event.EventQueueD</DataLocation>
<DefaultData>EventQueueDefaultData</DefaultData>
<IdLocation>^arsblue.event.EventQueueD</IdLocation>
<IndexLocation>^arsblue.event.EventQueueI</IndexLocation>
<StreamLocation>^arsblue.event.EventQueueS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
