/// This class contains all information about persistent events
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.PersistentEvent Extends arsblue.event.Event
{

/// The object identity (%Oid=$LB(id,classname))
Property Oid As %ObjectIdentity;

/// The event action (one of INSERT, UPDATE or DELETE) 
Property Action As %EnumString(VALUELIST = ",INSERT,UPDATE,DELETE");

/// A JSON object with the event action details.
/// On INSERT the new object will be JSON serialized.
/// On UPDATE a JSON object with all modifications: { propertyDataType: [oldValue, newValue], propertyObject: { propertyDataType: [oldValue, newValue], ... }, ... }.
/// On DELETE the old object will be JSON serialized.
Property ActionDetails As %DynamicObject;

/// This method adds a persistent event listener.
/// <ul>
/// <li>EventListener...the created persistent event listener.</li>
/// <li>EventTarget...the event target.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>ClassName...the classname to monitor.</li>
/// <li>Actions...the actions to monitor (see <code>arsblue.event.PersistentEventListener.SetActions</code> method for more details).</li>
/// </ul>
/// Returns status OK if successfully created a persistent event listener, any other status signals failure and the listener will be set to null!
ClassMethod AddEventListener(ByRef EventListener As EventListener = {$$$NULLOREF}, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, ClassName As %String = "", Actions As %String) As %Status
{
	#dim status as %Status = $$$OK
	try
	{
		new %objlasterror
		set:('$$$TypeOf(EventListener,..%ClassName(1)_"Listener")) EventListener=$ClassMethod(..%ClassName(1)_"Listener","%New") $$$Throw($G(%objlasterror,$$$OK))
		set:($$$ISNULL(EventListener.ClassName)||'$$$ISNULL(ClassName)) EventListener.ClassName=ClassName $$$Throw($G(%objlasterror,$$$OK))
		if ($D(Actions)) $$$ThrowOnError(EventListener.SetActions(Actions))
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	
	if ($$$ISERR(status))
	{
		set EventListener=$$$NULLOREF
		quit status
	}
	else
	{
		quit ##super(.EventListener,EventTarget,.EventDeamon,.EventQueue)
	}
}

/// This method gets a persistent event listener.
/// <ul>
/// <li>EventListener...the created persistent event listener.</li>
/// <li>EventTarget...the event target.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>ClassName...the classname to monitor.</li>
/// <li>Actions...the actions to monitor (see <code>arsblue.event.PersistentEventListener.SetActions</code> method for more details).</li>
/// </ul>
/// Returns the persistent event listener or null on any failure!
ClassMethod GetEventListener(EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, ClassName As %String = "", Actions As %String) As EventListener
{
	do ..GetEventListenerSQL(.sql,.params,EventTarget,.EventDeamon,.EventQueue,ClassName,.Actions)
	
	set stmt=##class(%SQL.Statement).%New()
	quit:($$$ISERR(stmt.%Prepare(.sql))) $$$NULLOREF
	set rs=stmt.%Execute(params...)
	
	set eventListener=$$$NULLOREF
	set:(rs.%Next()) eventListener=##class(arsblue.event.EventListener).%OpenId(rs.ID)
	quit eventListener
}

/// This method gets the SQL statement to get a persistent event listener.
/// This method will be overwritten by derived events specifying the event parameters.
/// NOTE: Don't forget to call super class first!
/// <ul>
/// <li>sql...the SQL statement (by reference).</li>
/// <li>params...the SQL statement parameters (by reference).</li>
/// <li>EventTarget...the event target classname to call.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>ClassName...the classname to monitor.</li>
/// <li>Actions...the actions to monitor (see <code>arsblue.event.PersistentEventListener.SetActions</code> method for more details).</li>
/// </ul>
/// Returns the persistent event listener SQL statement.
ClassMethod GetEventListenerSQL(ByRef sql, ByRef params, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, ClassName As %String = "", Actions As %String) [ Private ]
{
	do ##super(.sql,.params,EventTarget,.EventDeamon,.EventQueue)
	
	set:('$$$ISNULL(ClassName)) sql($I(sql))="and ClassName=?",params($I(params))=ClassName
	if ($D(Actions))
	{
		set actions=","_$ZCVT(Actions,"U")_","
		for action="INSERT","UPDATE","DELETE"
		{
			if ($F(actions,","_action_",") || $F(actions,","_action_"=1,"))
			{
				set sql($I(sql))="and Action"_$ZCVT(action,"W")_"=?",params($I(params))=1
			}
			elseif ($F(actions,","_action_"=2,"))
			{
				set sql($I(sql))="and Action"_$ZCVT(action,"W")_"=?",params($I(params))=2
			}
			else
			{
				set sql($I(sql))="and Action"_$ZCVT(action,"W")_"=?",params($I(params))=0
			}
		}
	}
}

/// This method fires the persistent event.
/// Returns status OK if successfully processed event, any other status signals failure!
Method FireEvent() As %Status
{
	$$$QuitOnError(##super())

	#dim status as %Status = $$$OK
	try {	
		set status=$ClassMethod(..EventListener.EventTarget,"OnPersistentEvent",$this)
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	quit status
}

Storage Default
{
<Data name="ActionDetails">
<Attribute>ActionDetails</Attribute>
<Structure>node</Structure>
<Subscript>"arsblue.event.PersistentEvent.ActionDetails"</Subscript>
</Data>
<Data name="PersistentEventDefaultData">
<Subscript>"PersistentEvent"</Subscript>
<Value name="1">
<Value>Oid</Value>
</Value>
<Value name="2">
<Value>Action</Value>
</Value>
</Data>
<DefaultData>PersistentEventDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
