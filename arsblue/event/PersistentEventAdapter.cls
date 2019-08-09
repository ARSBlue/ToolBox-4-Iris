/// This class must be implemented by a class listening for persistent events.
/// 
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.PersistentEventAdapter Extends arsblue.event.EventAdapter [ Abstract ]
{

/// This method will be called when a persistent event was fired.
/// <ul>
/// <li>Event...the persistent event.</li>
/// </ul>
/// Returns status OK if successfully processed event, any other status signals warning or failure (only relevant for event queue)!
ClassMethod OnPersistentEvent(Event As arsblue.event.PersistentEvent) As %Status
{
	quit $$$OK
}

}
