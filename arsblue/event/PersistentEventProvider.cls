/// The persistent event provider generates events for INSERT, UPDATE and DELETE actions on persistent objects.
Class arsblue.event.PersistentEventProvider Extends arsblue.event.EventProvider [ Abstract ]
{

/// The persistent event before trigger prepares INSERT, UPDATE and DELETE event actions.
Trigger PersistentEventBefore [ Event = INSERT/UPDATE/DELETE, Foreach = row/object, Order = 999999 ]
{
	new sql,stmt,rs,status,eventListenerIds,actionDetails,stream
	
	set sql($I(sql))="select LIST(ID) as ""EventListenerIds"",(SUM(Action"_$ZCVT({%%OPERATION},"W")_")-COUNT(*)) as ""ActionDetails"""
	set sql($I(sql))=" from arsblue_event.PersistentEventListener"
	set sql($I(sql))=" where EventRun=1"
	set sql($I(sql))=" and Action"_$ZCVT({%%OPERATION},"W")_" in (1,2)"
	set sql($I(sql))=" and (ClassName=? OR (($EXTRACT(ClassName,$LENGTH(ClassName))='*') AND ($EXTRACT(ClassName,1,$LENGTH(ClassName)-1)=$EXTRACT(?,1,$LENGTH(ClassName)-1))))" // ?=%%CLASNAME, ?=%%CLASNAME
	
	set stmt=##class(%SQL.Statement).%New()
	$$$BreakOnError(stmt.%Prepare(.sql))
	$$$BreakOnSQLError(rs,stmt.%Execute({%%CLASSNAMEQ},{%%CLASSNAMEQ}))
	
	#dim status as %Status=$$$OK
	$$$Break('rs.%Next(.status))
	$$$BreakOnError(status)
	
	set eventListenerIds=$LISTFROMSTRING(rs.EventListenerIds)
	set actionDetails=rs.ActionDetails
	
	if ({%%OPERATION}="INSERT")
	{
		set ^||arsblue.event.PersistentEventD($I(^||arsblue.event.PersistentEventD))=$LB(eventListenerIds,actionDetails)
	}
	else  // UPDATE or DELETE
	{
		if (actionDetails)
		{
			set actionDetails=$$$NULLOREF
			// we need to collect data from extent because the sub-objects may be already changed
			// $$$BreakOnError($$$JSON.GetJSONFromObject(##class({%%CLASSNAME}).%Open($LB({%%ID},{%%CLASSNAMEQ})),.actionDetails,$$$YES))
			$$$BreakOnError($$$JSON.GetJSONFromExtent($LB({%%ID},{%%CLASSNAMEQ}),.actionDetails,$$$YES))
			set stream=##class(%Stream.GlobalCharacter).%New("^||arsblue.event.PersistentEventS")
			do actionDetails.%ToJSON(stream)
			$$$BreakOnError(stream.%Save())
			set actionDetails=stream.%Oid()
		}
		else
		{
			set actionDetails=$$$NULLOREF
		}
		
		set ^||arsblue.event.PersistentEventD($I(^||arsblue.event.PersistentEventD))=$LB(eventListenerIds,actionDetails)
	}
}

/// The persistent event before trigger prepares INSERT, UPDATE and DELETE event actions.
Trigger PersistentEventAfter [ Event = INSERT/UPDATE/DELETE, Foreach = row/object, Order = 999999, Time = AFTER ]
{
	new idx,tmp,eventListenerIds,actionDetails,stream,event,eventListener
	
	set idx=$I(^||arsblue.event.PersistentEventD,-1)+1
	set tmp=$G(^||arsblue.event.PersistentEventD(idx))
	kill ^||arsblue.event.PersistentEventD(idx)
	kill:('($D(^||arsblue.event.PersistentEventD)\10)) ^||arsblue.event.PersistentEventD
	
	set eventListenerIds=$LG(tmp,1)
	set actionDetails=$LG(tmp,2)
	
	if ({%%OPERATION}="INSERT")
	{
		if (actionDetails)
		{
			set actionDetails=$$$NULLOREF
			$$$BreakOnError($$$JSON.GetJSONFromObject(##class({%%CLASSNAME}).%Open($LB({%%ID},{%%CLASSNAMEQ})),.actionDetails,$$$YES))
		}
		else
		{
			set actionDetails=$$$NULLOREF
		}
	}
	else  // UPDATE or DELETE
	{
		if ('$$$ISNULL(actionDetails))
		{
			set stream=##class(%Stream.GlobalCharacter).%Open(actionDetails)
			set actionDetails=##class(%DynamicAbstractObject).%FromJSON(stream)
			$$$BreakOnError(stream.Clear())
			kill:('($D(^||arsblue.event.PersistentEventS)\10)) ^||arsblue.event.PersistentEventS
			
			if ({%%OPERATION}="UPDATE")
			{
				new jsonBefore,jsonAfter
				set jsonBefore=actionDetails
				$$$BreakOnError($$$JSON.GetJSONFromObject(##class({%%CLASSNAME}).%Open($LB({%%ID},{%%CLASSNAMEQ})),.jsonAfter,$$$YES))
				set actionDetails=$$$JSON.Diff(jsonBefore,jsonAfter)
			}
		}
	}
	
	for idx=1:1:$LL(eventListenerIds)
	{
		set event=##class(arsblue.event.PersistentEvent).%New()
		set event.Oid=$LB({%%ID},{%%CLASSNAMEQ})
		set event.Action={%%OPERATION}
		set eventListener=##class(arsblue.event.PersistentEventListener).%OpenId($LG(eventListenerIds,idx))
		if ($IsObject(eventListener))
		{
			set:($Property(eventListener,"Action"_$ZCVT({%%OPERATION},"W"))=2) event.ActionDetails=actionDetails
			do eventListener.FireEvent(event)
		}
		kill event,eventListener
	}
}

}
