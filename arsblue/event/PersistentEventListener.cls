/// This is a persistent event listener, it will inform you about all INSERT, UPDATE and DELETE actions on a persistent class.
/// NOTE: you do not need to explicit save the event listener, it is saved automatically on each set of a property!
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.PersistentEventListener Extends arsblue.event.EventListener
{

/// The classname to monitor.
/// You can use an asterisk on the end of the classname to monitor all classes which start with the specified classname.
Property ClassName As %String;

/// The action insert flag.
/// <ul>
/// <li>0...do not monitor INSERT actions.</li>
/// <li>1...monitor INSERT actions, only object identifier will be returned (default).</li>
/// <li>2...monitor INSERT actions, the inserted object will be returned as JSON serializable.</li>
/// </ul>
Property ActionInsert As %Integer(MAXVAL = 2, MINVAL = 0) [ InitialExpression = 1 ];

/// The action update flag.
/// <ul>
/// <li>0...do not monitor UPDATE actions.</li>
/// <li>1...monitor UPDATE actions, only object identifier will be returned (default).</li>
/// <li>2...monitor UPDATE actions, the difference between the object before and after update will be returned as JSON object.</li>
/// </ul>
Property ActionUpdate As %Integer(MAXVAL = 2, MINVAL = 0) [ InitialExpression = 1 ];

/// The action delete flag.
/// <ul>
/// <li>0...do not monitor DELETE actions.</li>
/// <li>1...monitor DELETE actions, only object identifier will be returned (default).</li>
/// <li>2...monitor DELETE actions, the deleted object will be returned as JSON serializable.</li>
/// </ul>
Property ActionDelete As %Integer(MAXVAL = 2, MINVAL = 0) [ InitialExpression = 1 ];

/// The classname index.
Index ClassName On ClassName [ Type = bitmap ];

/// The action insert index.
Index ActionInsert On ActionInsert [ Type = bitmap ];

/// The action update index.
Index ActionUpdate On ActionUpdate [ Type = bitmap ];

/// The action delete index.
Index ActionDelete On ActionDelete [ Type = bitmap ];

/// Set the persistent classname
Method ClassNameSet(ClassName As %String) As %Status
{
	if ($E(ClassName,*)'="*")
	{
		$$$QuitIf((ClassName=""),"cannot create listener for undefined persistent classname")
		$$$QuitIf('$$$TypeOf(ClassName,"arsblue.event.PersistentEventProvider"),"cannot create listener for invalid persistent class (check for persistent event provider)")
		$$$QuitIf($$$comClassKeyGet(ClassName,$$$cCLASSclasstype)'=$$$cCLASSCLASSTYPEPERSISTENT,"cannot create listener for non-persistent class")
	}
	
	set i%ClassName=ClassName
	quit ..%Save()
}

/// Set the event actions.
/// If none of the valid action options will be set, all actions will be set to monitor the object identifier!
/// <ul>
/// <li>Actions...the event actions: any combination of INSERT, UPDATE or DELETE in a comma separated string is allowed, invalid actions will be ignored.
///     You can also specify the monitoring option behind the action (e.g. "INSERT=0,UPDATE=1,DELETE=2" do not monitor insert actions, monitors the object identifier of UPDATE actions
///     and monitors action details on DELETE actions, defining "...,UPDATE=1,..." or "...,UPDATE,..." is the same).</li>
/// </ul>
/// Returns OK if successfully set the event actions, any other status signals failure!
Method SetActions(Actions As %String = "") As %Status
{
	set actions=","_$ZCVT(Actions,"U")_","
	for action="INSERT","UPDATE","DELETE"
	{
		if ($F(actions,","_action_",") || $F(actions,","_action_"=1,"))
		{
			xecute ("set i%Action"_$ZCVT(action,"W")_"=1")
		}
		elseif ($F(actions,","_action_"=2,"))
		{
			xecute ("set i%Action"_$ZCVT(action,"W")_"=2")
		}
		else
		{
			xecute ("set i%Action"_$ZCVT(action,"W")_"=0")
		}
	}
	
	if ('(i%ActionInsert || i%ActionUpdate || i%ActionDelete))
	{
		set i%ActionInsert=1
		set i%ActionUpdate=1
		set i%ActionDelete=1
	}
	
	quit ..%Save()
}

/// Get the event actions.
Method GetActions() As %String
{
	set actions=""
	set actions=actions_$CASE(..ActionInsert,1:",INSERT",2:",INSERT=2",:"")
	set actions=actions_$CASE(..ActionUpdate,1:",UPDATE",2:",UPDATE=2",:"")
	set actions=actions_$CASE(..ActionDelete,1:",DELETE",2:",DELETE=2",:"")
	quit $E(actions,2,*)
}

/// Set the action insert flag.
Method ActionInsertSet(ActionInsert As %Integer) As %Status
{
	set i%ActionInsert=ActionInsert
	quit ..%Save()
}

/// Set the action update flag.
Method ActionUpdateSet(ActionUpdate As %Integer) As %Status
{
	set i%ActionUpdate=ActionUpdate
	quit ..%Save()
}

/// Set the action delete flag.
Method ActionDeleteSet(ActionDelete As %Integer) As %Status
{
	set i%ActionDelete=ActionDelete
	quit ..%Save()
}

Storage Default
{
<Data name="PersistentEventListenerDefaultData">
<Subscript>"PersistentEventListener"</Subscript>
<Value name="1">
<Value>ClassName</Value>
</Value>
<Value name="2">
<Value>ActionInsert</Value>
</Value>
<Value name="3">
<Value>ActionUpdate</Value>
</Value>
<Value name="4">
<Value>ActionDelete</Value>
</Value>
</Data>
<DefaultData>PersistentEventListenerDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
