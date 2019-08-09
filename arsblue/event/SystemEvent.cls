/// This class contains all information about system events
/// 
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.SystemEvent Extends arsblue.event.Event
{

/// The event type (SYSTEM, LOGIN, JOB or CALLIN).
Property Type As %EnumString(VALUELIST = ",SYSTEM,LOGIN,JOB,CALLIN,CALLOUT");

/// The event type action flag.
/// <ul>
/// <li>1...startup, login or start.</li>
/// <li>2...shutdown, logout or stop.</li>
Property Action As %Integer(MAXVAL = 2, MINVAL = 1);

/// The event action details.
Property ActionDetails As %DynamicObject;

/// This method adds a system event listener.
/// <ul>
/// <li>EventListener...the created system event listener.</li>
/// <li>EventTarget...the event target.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>Types...the system event types to monitor (see <code>arsblue.event.SystemEventListener.SetTypes</code> method for more details).</li>
/// </ul>
/// Returns status OK if successfully created a system event listener, any other status signals failure and the listener will be set to null!
ClassMethod AddEventListener(ByRef EventListener As EventListener = {$$$NULLOREF}, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, Types As %String) As %Status
{
	#dim status as %Status = $$$OK
	try
	{
		new %objlasterror
		set:('$$$TypeOf(EventListener,..%ClassName(1)_"Listener")) EventListener=$ClassMethod(..%ClassName(1)_"Listener","%New") $$$Throw($G(%objlasterror,$$$OK))
		if ($D(Types)) $$$ThrowOnError(EventListener.SetTypes(Types))
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

/// This method gets a system event listener.
/// <ul>
/// <li>EventListener...the created system event listener.</li>
/// <li>EventTarget...the event target.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>Types...the system event types to monitor (see <code>arsblue.event.SystemEventListener.SetTypes</code> method for more details).</li>
/// </ul>
/// Returns the system event listener or null on any failure!
ClassMethod GetEventListener(EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, Types As %String) As EventListener
{
	do ..GetEventListenerSQL(.sql,.params,EventTarget,.EventDeamon,.EventQueue,.Types)
	
	set stmt=##class(%SQL.Statement).%New()
	quit:($$$ISERR(stmt.%Prepare(.sql))) $$$NULLOREF
	set rs=stmt.%Execute(params...)
	
	set eventListener=$$$NULLOREF
	set:(rs.%Next()) eventListener=##class(arsblue.event.EventListener).%OpenId(rs.ID)
	quit eventListener
}

/// This method gets the SQL statement to get a system event listener.
/// This method will be overwritten by derived events specifying the event parameters.
/// NOTE: Don't forget to call super class first!
/// <ul>
/// <li>sql...the SQL statement (by reference).</li>
/// <li>params...the SQL statement parameters (by reference).</li>
/// <li>EventTarget...the event target classname to call.</li>
/// <li>EventDeamon...the event listener deamon.</li>
/// <li>EventQueue...the event listener queue.</li>
/// <li>Types...the system event types to monitor (see <code>arsblue.event.SystemEventListener.SetTypes</code> method for more details).</li>
/// </ul>
/// Returns the system event listener SQL statement.
ClassMethod GetEventListenerSQL(ByRef sql, ByRef params, EventTarget As %String = "", EventDeamon As %Integer, EventQueue As arsblue.event.EventQueue, Types As %String) [ Private ]
{
	do ##super(.sql,.params,EventTarget,.EventDeamon,.EventQueue)
	
	if ($D(EventQueue))
	{
		set types=","_$ZCVT(Types,"U")_","
		for type="SYSTEM","LOGIN","JOB","CALLIN","CALLOUT"
		{
			if ($F(types,","_type_"=1,"))
			{
				set sql($I(sql))="and Type"_$ZCVT(type,"W")_"=?",params($I(params))=1
			}
			elseif ($F(types,","_type_"=2,"))
			{
				set sql($I(sql))="and Type"_$ZCVT(type,"W")_"=?",params($I(params))=2
			}
			elseif ($F(types,","_type_",") || $F(types,","_type_"=3,"))
			{
				set sql($I(sql))="and Type"_$ZCVT(type,"W")_"=?",params($I(params))=3
			}
			else
			{
				set sql($I(sql))="and Type"_$ZCVT(type,"W")_"=?",params($I(params))=0
			}
		}
	}
}

/// This method fires the system event.
/// Returns status OK if successfully processed event, any other status signals failure!
Method FireEvent() As %Status
{
	$$$QuitOnError(##super())

	#dim status as %Status = $$$OK
	try {	
		set status=$ClassMethod(..EventListener.EventTarget,"OnSystemEvent",$this)
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
<Subscript>"arsblue.event.SystemEvent.ActionDetails"</Subscript>
</Data>
<Data name="SystemEventDefaultData">
<Subscript>"SystemEvent"</Subscript>
<Value name="1">
<Value>Type</Value>
</Value>
<Value name="2">
<Value>Action</Value>
</Value>
</Data>
<DefaultData>SystemEventDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
