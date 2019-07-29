Include (arsblue.OS, arsblue.Status)

/// This class is the base class for all events
Class arsblue.event.Event Extends (%Persistent, arsblue.io.Serializable) [ Abstract ]
{

/// The event listener for this event.
Property EventListener As arsblue.event.EventListener;

/// The event processed flag.
Property EventProcessed As %Boolean [ InitialExpression = {$$$NO}, Private, Transient ];

/// The event timestamp.
Property EventTimeStamp As arsblue.datatype.TimeStamp [ InitialExpression = {$$$TimeStamp} ];

/// The foreign key constraint for event listener.
ForeignKey EventListenerFK(EventListener) References arsblue.event.EventListener() [ OnDelete = cascade ];

/// This method will be called on event dispose.
Method %OnClose() As %Status
{
	quit:(..EventProcessed && '$$$ISNULL(..%Oid())) ..%Delete(..%Oid())
	quit $$$OK
}

/// This method fires the event.
/// NOTE: All extended events must call <code>##super</code> at very first line of code, to be sure the event processing will work correctly!
/// Returns status OK if successfully processed event, any other status signals failure!
Method FireEvent() As %Status
{
	set ..EventProcessed=$$$YES // we mark the event as processed even if the event target execution fails
	
	$$$QuitIf('$IsObject(..EventListener),"cannot process event for unknown event listener")
	
	quit $$$OK
}

/// This method will be called from event queue if the event must be processed another time.
Method RestoreEvent()
{
	set ..EventProcessed=$$$NO // mark the event as not processed
}

/// This method adds an event listener.
/// This method will be overwritten by derived events specifying the event parameters.
/// <ul>
/// <li>EventListener...the created event listener.</li>
/// <li>EventTarget...the event target classname to call.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// </ul>
/// Returns status OK if successfully created an event listener, any other status signals failure and the listener will be set to null!
ClassMethod AddEventListener(ByRef EventListener As EventListener = {$$$NULLOREF}, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue) As %Status
{
	#dim status as %Status = $$$OK
	try
	{
		new %objlasterror
		set:('$$$TypeOf(EventListener,..%ClassName(1)_"Listener")) EventListener=$ClassMethod(..%ClassName(1)_"Listener","%New") $$$Throw($G(%objlasterror,$$$OK))
		set:($$$ISNULL(EventListener.EventTarget)||('$$$ISNULL(EventTarget))) EventListener.EventTarget=EventTarget $$$Throw($G(%objlasterror,$$$OK))
		set:$D(EventDeamon) EventListener.EventDeamon=EventDeamon
		set:$D(EventQueue) EventListener.EventQueue=EventQueue
		set EventListener.EventRun=$$$YES  // after all start the event listener
		$$$Throw($G(%objlasterror,$$$OK))  // check if there are any errors to catch
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) EventListener=$$$NULLOREF
	quit status
}

/// This method gets an event listener.
/// This method will be overwritten by derived events specifying the event parameters.
/// <ul>
/// <li>EventTarget...the event target classname to call.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// </ul>
/// Returns the event listener or null on any failure!
ClassMethod GetEventListener(EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue) As EventListener
{
	do ..GetEventListenerSQL(.sql,.params,EventTarget,.EventDeamon,.EventQueue)
	
	set stmt=##class(%SQL.Statement).%New()
	quit:($$$ISERR(stmt.%Prepare(.sql))) $$$NULLOREF
	set rs=stmt.%Execute(params...)
	
	set eventListener=$$$NULLOREF
	set:(rs.%Next()) eventListener=##class(arsblue.event.EventListener).%OpenId(rs.ID)
	quit eventListener
}

/// This method gets the SQL statement to get an event listener.
/// This method will be overwritten by derived events specifying the event parameters.
/// NOTE: Don't forget to call super class first!
/// <ul>
/// <li>sql...the SQL statement (by reference).</li>
/// <li>params...the SQL statement parameters (by reference).</li>
/// <li>EventTarget...the event target classname to call.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// </ul>
/// Returns the event listener SQL statement.
ClassMethod GetEventListenerSQL(ByRef sql, ByRef params, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue) [ Private ]
{
	set classname=..%ClassName(1)_"Listener"
	set sqltablename=$$$comClassKeyGet(classname,$$$cCLASSsqlschemaname)_"."_$$$comClassKeyGet(classname,$$$cCLASSsqltablename)
	
	set sql($I(sql))="select ID from "_sqltablename_" where EventTarget=?",params($I(params))=EventTarget
	set:$D(EventDeamon) sql($I(sql))="and EventDeamon=?",params($I(params))=EventDeamon
	set:$D(EventQueue) sql($I(sql))="and EventQueue=?",params($I(params))=EventQueue.%Id()
}

/// This method removes an event listener from its event queue.
/// <ul>
/// <li>EventListener...the event listener to remove.</li>
/// </ul>
/// Returns status OK if successfully removed the event listener from its event queue, any other status signals failure!
ClassMethod RemoveEventListener(EventListener As arsblue.event.EventListener = {$$$NULLOREF}) As %Status
{
	$$$QuitIf('$$$TypeOf(EventListener,"arsblue.event.EventListener"),"could not remove invalid event listener")
	quit EventListener.%Delete(EventListener.%Oid())
}

Storage Default
{
<Data name="EventDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventListener</Value>
</Value>
<Value name="3">
<Value>EventTimeStamp</Value>
</Value>
</Data>
<DataLocation>^arsblue.event.EventD</DataLocation>
<DefaultData>EventDefaultData</DefaultData>
<IdLocation>^arsblue.event.EventD</IdLocation>
<IndexLocation>^arsblue.event.EventI</IndexLocation>
<StreamLocation>^arsblue.event.EventS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
