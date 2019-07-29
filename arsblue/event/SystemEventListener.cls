/// This is a system event listener, it will inform you about all database, user, background process and external program call events.
/// NOTE: you do not need to explicit save the event listener, it is saved automatically on each set of a property!
Class arsblue.event.SystemEventListener Extends arsblue.event.EventListener
{

/// The database event flag (SYSTEM).
/// <ul>
/// <li>0...do not monitor database events (default).</li>
/// <li>1...monitor database startup events.</li>
/// <li>2...monitor database shutdown events.</li>
/// <li>3...monitor database startup and shutdown events.</li>
/// </ul>
Property TypeSystem As %Integer(MAXVAL = 3, MINVAL = 0) [ InitialExpression = 0 ];

/// The user event flag (LOGIN).
/// <ul>
/// <li>0...do not monitor user events (default).</li>
/// <li>1...monitor user login events.</li>
/// <li>2...monitor user logout events.</li>
/// <li>3...monitor user login and logout events.</li>
/// </ul>
Property TypeLogin As %Integer(MAXVAL = 3, MINVAL = 0) [ InitialExpression = 0 ];

/// The background process event flag (JOB).
/// <ul>
/// <li>0...do not monitor background process events (default).</li>
/// <li>1...monitor background process start events.</li>
/// <li>2...monitor background process end events.</li>
/// <li>3...monitor background process start and end events.</li>
/// </ul>
Property TypeJob As %Integer(MAXVAL = 3, MINVAL = 0) [ InitialExpression = 0 ];

/// The external program call event flag (CALLIN).
/// <ul>
/// <li>0...do not monitor external program call events (default).</li>
/// <li>1...monitor external program call start events.</li>
/// <li>2...monitor external program call end events.</li>
/// <li>3...monitor external program call start and end events.</li>
/// </ul>
Property TypeCallin As %Integer(MAXVAL = 3, MINVAL = 0) [ InitialExpression = 0 ];

/// The operating system command or program execution event flag (CALLIN).
/// <ul>
/// <li>0...do not monitor operating system command or program execution events (default).</li>
/// <li>1...monitor operating system command or program execution start events.</li>
/// <li>2...monitor operating system command or program execution end events.</li>
/// <li>3...monitor operating system command or program execution start and end events.</li>
/// </ul>
Property TypeCallout As %Integer(MAXVAL = 3, MINVAL = 0) [ InitialExpression = 0 ];

/// The database event index.
Index TypeSystem On TypeSystem [ Type = bitmap ];

/// The user event index.
Index TypeLogin On TypeLogin [ Type = bitmap ];

/// The background process index.
Index TypeJob On TypeJob [ Type = bitmap ];

/// The external program call index.
Index TypeCallin On TypeCallin [ Type = bitmap ];

/// The operating system command or program execution index.
Index TypeCallout On TypeCallout [ Type = bitmap ];

/// Set the event types.
/// If none of the valid type options will be set, the event listener will be marked as not running!
/// <ul>
/// <li>Types...the event typess: any combination of SYSTEM, LOGIN, JOB, CALLIN or CALLOUT in a comma separated string is allowed, invalid actions will be ignored.
///     You can also specify the monitoring option behind the action (e.g. "SYSTEM=0,LOGIN=1,JOB=2,CALLIN=3" do not monitor database and operating system command or program execution events 
///     but monitors the login for user events, the start of background processes and start/stop of external program calls, defining "...,SYSTEM=3,..." or "...,SYSTEM,..." is the same).</li>
/// </ul>
/// Returns OK if successfully set the event types, any other status signals failure!
Method SetTypes(Types As %String = "") As %Status
{
	set types=","_$ZCVT(Types,"U")_","
	for type="SYSTEM","LOGIN","JOB","CALLIN","CALLOUT"
	{
		if ($F(types,","_type_"=1,"))
		{
			xecute ("set i%Type"_$ZCVT(type,"W")_"=1")
		}
		elseif ($F(types,","_type_"=2,"))
		{
			xecute ("set i%Type"_$ZCVT(type,"W")_"=2")
		}
		elseif ($F(types,","_type_",") || $F(types,","_type_"=3,"))
		{
			xecute ("set i%Type"_$ZCVT(type,"W")_"=3")
		}
		else
		{
			xecute ("set i%Type"_$ZCVT(type,"W")_"=0")
		}
	}
	
	if ('(i%TypeSystem || i%TypeLogin || i%TypeJob || i%TypeCallin || i%TypeCallout))
	{
		set i%EventRun=0
	}
	
	quit ..%Save()
}

/// Get the event types.
Method GetTypes() As %String
{
	set types=""
	set types=types_$S(..TypeSystem:",SYSTEM="_..TypeSystem,1:"")
	set types=types_$S(..TypeLogin:",LOGIN="_..TypeLogin,1:"")
	set types=types_$S(..TypeJob:",JOB="_..TypeJob,1:"")
	set types=types_$S(..TypeCallin:",CALLIN="_..TypeCallin,1:"")
	set types=types_$S(..TypeCallout:",CALLOUT="_..TypeCallout,1:"")
	quit $E(types,2,*)
}

/// Set the database event flag (SYSTEM).
Method TypeSystemSet(TypeSystem As %Integer) As %Status
{
	set i%TypeSystem=TypeSystem
	quit ..%Save()
}

/// Set the user event flag (LOGIN).
Method TypeLoginSet(TypeLogin As %Integer) As %Status
{
	set i%TypeLogin=TypeLogin
	quit ..%Save()
}

/// Set the background process event flag (JOB).
Method TypeJobSet(TypeJob As %Integer) As %Status
{
	set i%TypeJob=TypeJob
	quit ..%Save()
}

/// Set the external program call event flag (CALLIN).
Method TypeCallinSet(TypeCallin As %Integer) As %Status
{
	set i%TypeCallin=TypeCallin
	quit ..%Save()
}

/// Set the operating system command or program execution event flag (CALLIN).
Method TypeCalloutSet(TypeCallout As %Integer) As %Status
{
	set i%TypeCallout=TypeCallout
	quit ..%Save()
}

Storage Default
{
<Data name="SystemEventListenerDefaultData">
<Subscript>"SystemEventListener"</Subscript>
<Value name="1">
<Value>TypeSystem</Value>
</Value>
<Value name="2">
<Value>TypeLogin</Value>
</Value>
<Value name="3">
<Value>TypeJob</Value>
</Value>
<Value name="4">
<Value>TypeCallin</Value>
</Value>
<Value name="5">
<Value>TypeCallout</Value>
</Value>
</Data>
<DefaultData>SystemEventListenerDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
