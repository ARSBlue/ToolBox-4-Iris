/// This class must be implemented by a class listening for system events.
/// 
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.event.SystemEventAdapter Extends arsblue.event.EventAdapter [ Abstract ]
{

/// This method will be called when a system event was fired.
/// <ul>
/// <li>Event...the system event.</li>
/// </ul>
/// Returns status OK if successfully processed event, any other status signals warning or failure (only relevant for event queue)!
ClassMethod OnSystemEvent(Event As arsblue.event.SystemEvent) As %Status
{
	quit $$$OK
}

}
