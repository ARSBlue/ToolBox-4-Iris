Include (arsblue.OS, arsblue.Status)

/// This the base class for all event listeners.
/// NOTE: you do not need to explicit save the event listener, it is saved automatically on each set of a property!
Class arsblue.event.EventListener Extends (%Persistent, arsblue.io.Serializable) [ Abstract ]
{

/// The event target to call.
Property EventTarget As %String;

/// The event listener run flag.
/// If this flag is set to true, the event listener starts immediately event processing until the flag is set to false.
Property EventRun As %Boolean [ InitialExpression = {$$$NO} ];

/// The event listener deamon.
/// If the event deamon is set to a valid process id (default), the event listener is only available until the event listener object is disposed.
/// If the event deamon is set to zero, the event listener is static and will be fired immediately.
/// If the event deamon is a negative number, the event listener is working within an event queue.
Property EventDeamon As %Integer [ InitialExpression = {$JOB} ];

/// The event queue.
Property EventQueue As arsblue.event.EventQueue;

/// The event target index.
Index EventTarget On EventTarget [ Type = bitmap ];

/// The event listener run index.
Index EventRun On EventRun [ Type = bitmap ];

/// The event listener deamon index.
Index EventDeamon On EventDeamon [ Type = bitmap ];

/// The event queue index
Index EventQueue On EventQueue [ Type = bitmap ];

/// The foreign key constraint for event queue.
ForeignKey EventQueueFK(EventQueue) References arsblue.event.EventQueue() [ OnDelete = cascade ];

/// This method is called when the event listener is disposed.
Method %OnClose() As %Status
{
	quit:(..EventDeamon'=$JOB) $$$OK
	quit ..%Delete(..%Oid())
}

/// Set event target.
Method EventTargetSet(EventTarget As %String) As %Status
{
	$$$QuitIf((EventTarget="") || '$$$comClassDefined(EventTarget),"cannot set invalid event target classname "_EventTarget)
	$$$QuitIf('$$$TypeOf(EventTarget,$E(..%ClassName(1),1,*-8)_"Adapter"),"cannot set invalid event target adapter "_EventTarget)
	
	set i%EventTarget=EventTarget
	quit ..%Save()
}

/// Set event run.
Method EventRunSet(EventRun As %Boolean) As %Status
{
	set i%EventRun=''EventRun
	quit ..%Save()
}

/// Set event deamon.
Method EventDeamonSet(EventDeamon As %Integer) As %Status
{
	if ('$IsObject(..EventQueue))
	{
		set i%EventDeamon=EventDeamon
		quit ..%Save()
	}
	quit $$$OK
}

/// Set event queue.
Method EventQueueSet(EventQueue As arsblue.event.EventQueue) As %Status
{
	if ($IsObject(EventQueue))
	{
		set i%EventQueue=EventQueue.%Id()
		set i%EventDeamon=-i%EventQueue
	}
	else
	{
		set i%EventQueue=$$$NULLOREF
		set i%EventDeamon=$JOB
	}
	quit ..%Save()
}

/// This expression delivers the event listener resource.
Method GetEventListenerResource() As %String
{
	quit $$$NspDest($E(..%ClassName(1),1,*-8))_"("""_..%Id()_""""_$S(..EventDeamon:","_..EventDeamon,1:"")_")"
}

/// This trigger is responsible for starting and stopping of the event listener
Trigger EventListenerAfter [ Event = INSERT/UPDATE/DELETE, Foreach = row/object, Time = AFTER ]
{
	new eventListenerResourceBefore,eventListenerResourceAfter
	set eventListenerResourceBefore=$$$NspDest($E({%%CLASSNAMEQ},1,*-8))_"("""_{ID}_""""_$S({EventDeamon*O}:","_{EventDeamon*O},1:"")_")"
	set eventListenerResourceAfter=$$$NspDest($E({%%CLASSNAMEQ},1,*-8))_"("""_{ID}_""""_$S({EventDeamon*N}:","_{EventDeamon*N},1:"")_")"
	if ($CASE({%%OPERATION},"INSERT":$$$YES,"UPDATE":$$$YES,:$$$NO))
	{
		do:(({EventRun*N} && {EventDeamon*N} && '{EventQueue*N}) && '$System.Event.Defined(eventListenerResourceAfter)) $System.Event.Create(eventListenerResourceAfter)
		do:(('{EventRun*N} || (eventListenerResourceBefore'=eventListenerResourceAfter)) && '{EventQueue*O} && $System.Event.Defined(eventListenerResourceBefore)) $System.Event.Delete(eventListenerResourceBefore)
	}
	else
	{
		do:('{EventQueue*O} && $System.Event.Defined(eventListenerResourceBefore)) $System.Event.Delete(eventListenerResourceBefore)
	}
}

/// This method fires an event.
/// This method will be called by providers to inform listeners about the event.
/// <ul>
/// <li>Event...the event to fire.</li>
/// </ul>
/// Returns status OK if successfully fired the event, any other status signals failure!
Method FireEvent(Event As arsblue.event.Event) As %Status
{
	$$$QuitIf('$$$TypeOf(Event,$E(..%ClassName(1),1,*-8)),"cannot fire invalid event type")
	set Event.EventListener=$this
	
	if (..EventDeamon)
	{
		$$$QuitOnError(Event.%Save())
		if (..EventDeamon>0)
		{
			set eventListenerResource=..GetEventListenerResource()
			do:($System.Event.Defined(eventListenerResource)) $System.Event.Signal(eventListenerResource,Event.%Oid())
		}
	}
	else
	{
		try
		{
			do Event.FireEvent()  // fire and forget!
		}
		catch (exc)
		{
			// nothing we can do...
		}
	}
	quit $$$OK
}

/// This method listens for the next persistent event.
/// <ul>
/// <li>Event...the monitored persitent event or null if timeout reached.</li>
/// <li>EventProcessing...true (default) if the event should be processed automaticaly, false if the event should be processed by different implementation logic.</li>
/// <li>EventTimeout...the monitoring timeout in seconds.</li>
/// <ul>
/// Returns status OK if successfully received/processed an event, any other status signals failure and the event will be set to null!
Method GetNext(ByRef Event As arsblue.event.Event = {$$$NULLOREF}, EventProcessing As %Boolean = {$$$YES}, EventTimeout As %Integer = -1) As %Status
{
	$$$QuitIf(..EventDeamon'=$JOB,"cannot get events for event deamon "_..EventDeamon)
	
	set Event=$$$NULLOREF
	set eventListenerResource=..GetEventListenerResource()
	set eventmessage=$System.Event.WaitMsg(eventListenerResource,EventTimeout)
	set eventstatus=$LG(eventmessage,1)
	$$$QuitIf(eventstatus=-1,"event listener resource not available "_eventListenerResource)
	quit:(eventstatus'=1) $$$OK // nothing to do...
	
	set status=$$$OK
	try
	{
		set Event=##class(arsblue.event.Event).%Open($LG(eventmessage,2),,.status) $$$Throw(status)
		set:(EventProcessing) status=Event.FireEvent()
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) Event=$$$NULLOREF
	quit status
}

/// Create new event listener
Storage Default
{
<Data name="EventListenerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventTarget</Value>
</Value>
<Value name="3">
<Value>EventRun</Value>
</Value>
<Value name="4">
<Value>EventDeamon</Value>
</Value>
<Value name="5">
<Value>EventQueue</Value>
</Value>
</Data>
<DataLocation>^arsblue.event.EventListenerD</DataLocation>
<DefaultData>EventListenerDefaultData</DefaultData>
<Description>
<![CDATA[Create new event listener]]></Description>
<IdLocation>^arsblue.event.EventListenerD</IdLocation>
<IndexLocation>^arsblue.event.EventListenerI</IndexLocation>
<StreamLocation>^arsblue.event.EventListenerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
