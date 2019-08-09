Include (arsblue.OS, arsblue.Status, arsblue.util.Json)

/// This class stores event queue log information.
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.EventQueueLog Extends %Persistent
{

/// The event queue.
Property EventQueue As arsblue.event.EventQueue [ Required ];

/// The event classname.
Property EventClassName As %String [ Required ];

/// The event log status
Property EventLogStatus As %EnumString(VALUELIST = ",INFO,WARNING,ERROR") [ Required ];

/// The event queue processing timestamp.
Property EventTimeStamp As arsblue.datatype.TimeStamp [ InitialExpression = {$$$TimeStamp}, Required ];

/// The event message.
/// NOTE: the event message contains %Status content on ERRORs! 
Property EventMessage As %String(MAXLEN = 2048);

/// The event as JSON object.
Property Event As %DynamicAbstractObject;

/// The event queue index.
Index EventQueue On EventQueue [ Type = bitmap ];

/// The event classname index.
Index EventClassName On EventClassName [ Type = bitmap ];

/// The event queue log status index.
Index EventLogStatus On EventLogStatus [ Type = bitmap ];

/// The event queue log index.
Index EventQueueLog On (EventQueue, EventClassName, EventLogStatus, EventTimeStamp);

/// This method logs an event (only if the given criteria reflect the settings for logging of the event queue).
/// <ul>
/// <li>EventQueue...the event queue.</li>
/// <li>Event...the event to log.</li>
/// <li>EventMessage...the event message to log.
/// 	If event message is of type %Status then for WARNINGs (ErrorCode=0) the message will be saved,
/// 	and for ERRORs the whole %Status object as JSON string will be saved!</li>
/// </ul>
/// Returns status OK if successfully logged event, any other status signals failure!
ClassMethod Log(EventQueue As arsblue.event.EventQueue = {$$$NULLOREF}, Event As arsblue.event.Event = {$$$NULLOREF}, EventMessage As %String = "") As %Status
{
	$$$QuitIf('$IsObject(EventQueue),"cannot log event for undefined event queue")
	$$$QuitIf('$IsObject(Event),"cannot log undefined event for event queue")
	
	// INFO...log everything
	// WARNING...log WARNINGs and ERRORs
	// ERROR...log ERRORs
	// default...log nothing
	quit:('$CASE(EventQueue.EventLogLevel,"INFO":$$$YES,"WARNING":$$$ISSTATUS(EventMessage)&&$$$ISERR(EventMessage),"ERROR":$$$ISSTATUS(EventMessage)&&$$$ISERR(EventMessage)&&'$$$ISWARNING(EventMessage),:$$$NO)) $$$OK
	
	set log=##class(arsblue.event.EventQueueLog).%New()
	set log.EventQueue=EventQueue
	set log.EventClassName=Event.%ClassName(1)
	set log.EventLogStatus=$S($$$ISSTATUS(EventMessage):$S($$$ISOK(EventMessage):"INFO",$$$ISWARNING(EventMessage):"WARNING",1:"ERROR"),1:"INFO")
	set log.EventMessage=$S($$$ISSTATUS(EventMessage):$S($$$ISOK(EventMessage):"",$$$ISWARNING(EventMessage):$$$GETWARNING(EventMessage),1:$$$JSON.GetJSONFromStatus(EventMessage).%ToJSON()),1:EventMessage)
	set status=$$$JSON.GetJSONFromObject(Event,.json,$$$YES)
	set:$$$ISERR(status) json=$$$JSON.GetJSONFromStatus(status)
	set log.Event=json
	quit log.%Save()
}

Storage Default
{
<Data name="Event">
<Attribute>Event</Attribute>
<Structure>node</Structure>
<Subscript>"Event"</Subscript>
</Data>
<Data name="EventQueueLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventQueue</Value>
</Value>
<Value name="3">
<Value>EventClassName</Value>
</Value>
<Value name="4">
<Value>EventLogStatus</Value>
</Value>
<Value name="5">
<Value>EventTimeStamp</Value>
</Value>
<Value name="6">
<Value>EventMessage</Value>
</Value>
</Data>
<DataLocation>^arsblue.event.EventQueueLogD</DataLocation>
<DefaultData>EventQueueLogDefaultData</DefaultData>
<IdLocation>^arsblue.event.EventQueueLogD</IdLocation>
<IndexLocation>^arsblue.event.EventQueueLogI</IndexLocation>
<StreamLocation>^arsblue.event.EventQueueLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
