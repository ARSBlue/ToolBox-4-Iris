# ARSBlue ToolBox-4-Iris -- Event Package

- [Server-side Event Handling](#server-side-event-handling)
  - [Synchronous Event Handling](#synchronous-event-handling)
  - [Asynchronous Event Handling](#asynchronous-event-handling)
    - [Treatment by User Process](#treatment-by-user-process)
    - [Treatment by Event Queue](#treatment-by-event-queue)
  - [System Events](#system-events)
    - [System Event Adapter und System Event](#system-event-adapter-und-system-event)
    - [Handle System Event synchronously](#handle-system-event-synchronously)
    - [Handle System Event asynchronously with Event Queue](#handle-system-event-asynchronously-with-event-queue)
    - [Handle System Event asynchronously in User Process](#handle-system-event-asynchronously-in-user-process)
    - [Standard InterSystems IRIS System Events](#standard-intersystems-iris-system-events)
    - [System Event for Operating System Calls](#system-event-for-operating-system-calls)
  - [Persisted Data Events](#persisted-data-events)
    - [Persisted Data Event Adapter und Persisted Data Event](#persisted-data-event-adapter-und-persisted-data-event)
    - [Handle Persisted Data Events synchronously](#handle-persisted-data-events-synchronously)
    - [Handle Persisted Data Events asynchronously with Event Queue](#handle-persisted-data-events-asynchronously-with-event-queue)
    - [Handle Persisted Data Events asynchronously in User Process](#handle-persisted-data-events-asynchronously-in-user-prozess)

## Server-side Event Handling

Using server-side event handling, ARS Blue provides a way to use ObjectScript to notify the server of events triggered by other processes. The difference to standard InterSystems IRIS system event implementation is that you can decide how to respond to each event and whether you want to log events.

### Synchronous Event Handling

In synchronous event handling, the system responds to an event in the particular process in which the event happens.

**_Advantage:_** It is guaranteed that at the end of the event chain the treatment of the event was carried out safely.

**_Disadvantage:_** The handling of the event leads to costs (performance or improper handling of locks) of the executing process. But it is guaranteed that even if there is a mistake in the treatment, the chain of events will be processed further.

### Asynchronous Event Handling

Asynchronous event handling distinguishes between two types: process-oriented treatment and treatment by an event queue. However, both variants have the same processing in their own process.

**_Advantage:_** The handling of the event is outsourced to a separate process. This is especially recommended for time-intensive treatments that should not burden the event-producing process.

**_Disadvantage:_** There is no guarantee that event handling will be completed after the event. This is especially important for transaction handling: a possible unrolling of the data in the event-producing process can lead to problems if the event-handling process already wants to access this data! This is to be prevented by appropriate programming techniques!

#### Treatment by User Process

When treated by a user process, the latter registers as an interested party for an event. If the event occurs, the process is informed about this event. This information is cached in order of occurrence until the process takes care of the events.

**_Advantage:_** It can be decided highly dynamically whether one is interested in a particular event. It is guaranteed that all events are dealt with in the order of their appearance.

**_Disadvantage:_** There is no guarantee that the event-keeping process will take care of all events that have occurred. When the process ends, all events that are left untreated are discarded.

When handled by a user process, the programmer is responsible for querying the events. The programmer can choose whether the query should block until the next event occurs (default setting) or if the query should return after a parameterizable timeout. Furthermore, the programmer can also choose whether the query should handle the event automatically (default setting) or whether this should be done by the own program code.

#### Treatment by Event Queue

An event queue is an automatic process that takes care of events. It's a mix of asynchronous and synchronous event handling. The reception of the events is carried out asynchronously, but the handling of the events is synchronized in the process of the event queue.

**_Advantage:_** It can be decided highly dynamically whether one is interested in a particular event. It is guaranteed that all events are dealt with in the order of their occurrence and that no events are lost (no event gaps). Generally, you do not have to worry about starting the event queue, i.e. at the moment the event occurs, the event queue is started (if it should not already be running). If for example not all events are handled until the database is shut down, the events are not lost, but continue to be handled in their order after booting.

**_Disadvantage:_** Because an event queue can handle different events, it is possible that the treatment of events may be delayed. However, this can be controlled by a reasonable definition of the event queues and depends only on the possible number of processes of the IRIS license. Of course, an event queue would be optimal per event type, but you can not group business-relevant and processing-intensive events into an event queue, and business-relevant events can each provide their own event queue.

An event queue can be configured using several parameters:

| Parameter | Descripition |
| --- | --- |
| **Name** | The name of the event queue. The name can be customized, but must be unique in the InterSystems IRIS namespace. |
| **EventAmountPerLookup** | Specifies the number of events to be read per pass of the queue (default value = 10). |
| **EventHoldOnError** | Determines how the event queue should respond to an event handling error: <br/><ul><li>**NOHOLD**: Does not stop further processing of events (Fire And Forget).</li><li>**WARNING**: Stops the further processing of events if the event handler returns a warning or error (Strict Event Handling).</li><li>**ERROR**: Stops further processing of events only if event handling returns an error (Moderate Event Handling = Default).</li></ul> |
| **EventLogLevel** | Determines what information about the event should be recorded: <br/><ul><li> **NOLOG**: No information about events is recorded. </Li><li> **INFO**: It will all information about events is recorded. </li><li> **WARNING**: All event warnings and error messages are recorded. </li><li> **ERROR**: Only event error messages are recorded (Default). </li></ul> |
| **EventRun** | Determines whether the event queue is to run automatically or whether it is suspended: <br/><ul><li> **0**: The event queue is stopped after the last event handling and is not restarted automatically. </Li><li> **1**: The event queue automatically starts on the next event and starts event handling on the oldest event in the event queue. </Li></ul> |

These parameters can be set via ObjectScript or via SQL Statements and directly access the process of the event queue, i.e. after changing the parameters, the event queue does not have to be stopped and restarted; instead, it takes over the new parameters after the last run. If the parameter `EventRun` is set, the event queue starts or stops accordingly.

An event queue can be created using ObjectScript or an insert SQL statement (additional parameters must be specified accordingly):

**_ObjectScript:_**
```
// Creating the Event Queue
USER>set eventQueue=##class(arsblue.event.EventQueue).%New()
 
USER>set eventQueue.Name="MyEventQueue"
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())

// Starting the Event Queue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")
 
USER>set eventQueue.EventRun=1
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())


// Create and start the Event Queue in one step
USER>set eventQueue=##class(arsblue.event.EventQueue).%New()
 
USER>set eventQueue.Name="MyEventQueue",eventQueue.EventRun=1
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())
```

**_SQL Statement:_**
```
// Creating the Event Queue
INSERT INTO arsblue_event.EventQueue (Name) values ('MyEventQueue')

// Starting the Event Queue
UPDATE arsblue_event.EventQueue set EventRun=1 where Name='MyEventQueue')


// Create and start the Event Queue in one step
INSERT INTO arsblue_event.EventQueue (Name, EventRun) values ('MyEventQueue', 1)
```

### System Events

Anyone interested in system events can log on or off at any time. There are four system events provided by the InterSystems IRIS database (database start / stop, user logon / logoff, start / stop of a process, start / end of an incoming command), and a special system event to monitor the operating system calls (begin / end of an outgoing operating system call) provided by ARS Blue.

Event handling can be applied to all system events as described, with the sole exception of the database start / stop event being that no asynchronous handling by user processes can be offered because either no user processes are running at the time the database is started or stopped already finished. Likewise, no asynchronous handling by event queues for stopping the database can be offered because the processes of the event queues have already been terminated. Nevertheless, this event can be handled the next time the database is started and thus a log for proper shutdown of the database can be created. If for some reason the database is not shut down properly, the corresponding event will not exist and this can be checked at startup.

#### System Event Adapter und System Event

System events `arsblue.event.SystemEvent` can be received via the implementation of the corresponding adapter `arsblue.event.SystemEventAdapter`. The system event then provides information about which event took place. One is only informed about those system events for which one has also registered.
```
Class User.SystemEventadapter Extends arsblue.event.SystemEventAdapter
{
ClassMethod OnSystemEvent(Event as arsblue.event.SystemEvent) as %Status
{
  // Event.Type one off "SYSTEM","LOGIN","JOB","CALLIN","CALLOUT"
  // Event.Action one off 1 (means startup, login, start or begin)
  //                   or 2 (means shutdown, logout, stop or end)
  // Event.ActionDetails contains detailed JSON information
  quit $$$OK
}
}
```

#### Handle System Event synchronously

In order to log on to system events, you must log in to the associated event using the desired method. The following example logs on the System for starting and stopping the database synchronously with the sample adapter.
```
// Log on for synchronous System Events
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",0,,"SYSTEM")
```

#### Handle System Event asynchronously with Event Queue

In order to log on to system events, you must log in to the associated event using the desired method. In the following example, the system events Log on and Start process are logged on via an event queue.
```
// Log on for asynchronous System Events for Event Queue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",,eventQueue,"LOGIN=1,JOB=1")
```

#### Handle System Event asynchronously in User Process

In order to log on to system events, you must log in to the associated event using the desired method. In the following example, the system events log off and stop process are logged on and polled via an asynchronous user process. For the query, a corresponding instance of `arsblue.event.SystemEventListener` is returned via reference. The sample query blocks until a corresponding event occurs and the event is automatically handled in the defined sample adapter. The programmer can carry out additional steps in the further program or evaluate the event even further.
```
// Log on for asynchronous System Events in User Process
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(.listener,"User.SystemEventAdapter",,,"LOGIN=2,JOB=2")

// This query can now be repeated 
// until the user process has done its job.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Logging out of registered system events
USER>kill listener
```

If the instance for the query is removed from memory (variable is deleted or the scope of the variable is exited), the registry for this system event is also automatically removed.

#### Standard InterSystems IRIS System Events

For the options `SYSTEM`,` LOGIN`, `JOB` and` CALLIN` to work for the standard InterSystems IRIS system event implementations the arsblue routines `% ZSTART` and`% ZSTOP` have to be implemented. Any implementation from these routines should be paged out into appropriate System Event Adapter classes, which can then be synchronized and handled. This also increases the maintainability of your own program code, since you no longer need to implement or update InterSystems IRIS system routines.

The following information can be found in the Event Details:

| Event | JSON Information |
| --- | --- |
| **SYSTEM** | No additional information for starting / stopping the database. |
| **LOGIN** <br/> **JOB** <br/> **CALLIN** | Logging in / logging out a user, <br/> Starting / stopping a background program or <br/> Starting / stopping an external database call provide the following JSON information: <br/><ul><li> **$JOB**: the process number </li><li> **$IO**: the default input / output device </li><li> **$ROLES**: the permissions in the database </li><li> **$USERNAME**: the InterSystems IRIS username </li><li> **ClientIPAddress**: the IP address of the caller </li><li> **ClientNodeName**: the hostname of the caller </li><li> **UserName**: the operating system username </li> </ul><br/> Unfortunately, no information can be provided about which program or command is called, as InterSystems IRIS does not provide this information. |

#### System Event for Operating System Calls

The `CALLOUT` option can be used to handle system events for operating system calls that are called via the arsblue method Operating system execute commands (`arsblue.util.Exec`).

The following information can be found in the Event Details:

| Event | JSON Information |
| --- | --- |
| **CALLOUT** | Starting / stopping an operating system command provides the following JSON information: <br/><ul><li> **$JOB**: the process number </li><li> **$IO**: the default input / output device </li><li> **$ROLES**: the permissions in the database </li><li> **$USERNAME**: the InterSystems IRIS username </li><li> **ClientIPAddress**: the IP Address of the caller </li><li> **ClientNodeName**: the caller's hostname </li><li> **UserName**: the operating system username </li><li> **program**: the operating system command or the program </li><li> **path**: the directory in the operating system </li><li> **stdin**: the default input data stream </li><li> **stdout**: the standard output stream </li><li> **stderr**: the default error stream </li><li> **async**: Flag if command or program in Background (`1`) or foreground (`0` = default) is executed </li><li> **pid**: the process ID in the operating system </li><li> **callback**: Name of the Class and method to call after execution </li><li> **cmd *: command or program including directory for the operating system </li></ul><br/> The following information is also available when exiting an operating system command in the JSON information: <br/><ul><li> **status**: Status OK or the error message for the command or program </li></ul> |

### Persisted Data Events

Anyone interested in persisting data events can log on or log off at any time. These events are roughly similar to the implementation of a trigger in InterSystems IRIS, but unlike InterSystems IRIS database triggers whose implementation needs to be adjusted each time the request changes, the arsblue data event implementation can enroll in the ongoing operation process Log out again without the data class needs to be changed or compiled. This increases the maintainability of the program code, since the data class does not always have to be tested if the business logic changes.

Event handling can be applied to all persisted data events as described. To activate the functionality, the data class must be derived from the arsblue provider class `arsblue.event.PersistentEventProvider` and compiled. From this point you can register for this data class to be informed about data manipulation.

#### Persisted Data Event Adapter und Persisted Data Event

Persisted data events `arsblue.event.PersistentEvent` can be received through the implementation of the associated adapter `arsblue.event.PersistentEventAdapter`. The data event then provides information about which data manipulation took place. One is only informed about those data events for which one has also registered.
```
Class User.PersistentEventadapter Extends arsblue.event.PersistentEventAdapter
{
ClassMethod OnPersistentEvent(Event as arsblue.event.PersistentEvent) as %Status
{
  // Event.Action one off "INSERT","UPDATE","DELETE"
  // Event.ActionDetails contains detailed JSON information
  quit $$$OK
}
}
```

#### Handle Persisted Data Events synchronously

In order to register for persisted data events, you must log on to the associated event using the method you require. In the following example, the persisted data event is logged in for all data manipulations of the sample class in sync with the sample adapter.
```
// Log in for synchronous persisted data events
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(,"User.PersistentEventAdapter",0,,"User.Data")
```

#### Handle Persisted Data Events asynchronously with Event Queue

In order to register for persisted data events, you must log in to the associated event using the method you require. In the example below  the persisted data events for insert (ID only), update (JSON difference image between before and after update) are logged via an event queue.
```
// Log on for asynchronous system events for event queue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.PersistentEventAdapter",,eventQueue,"User.Data","INSERT=1,UPDATE=2")
```

#### Handle Persisted Data Events asynchronously in User Process

In order to register for persisted data events, you must log in to the associated event using the method you want. In the following example, the persisted data events are logged in and queried for deletion over an asynchronous user process. For the query, a corresponding instance of `arsblue.event.PersistentEventListener` is returned via reference. The sample query blocks until a corresponding event occurs and the event is automatically handled in the defined sample adapter. The programmer can carry out additional steps in the further program or evaluate the event even further.

```
// Log on asynchronous system events for user process
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(.listener,"User.PersistentEventAdapter",,,"User.Data","INSERT=0,UPDATE=0,DELETE")

// This query can now be repeated
// until the user process has done its job.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Logging out of logged persisted data events
USER>kill listener
```
If the instance for the query is removed from memory (variable is deleted or the scope of the variable is left), the registration for this persisted data event is also automatically removed.
