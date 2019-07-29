# ARSBlue IRIS Event Package

## Serverseitige Ereignisbehandlung

Mit der serverseitigen Ereignisbehandlung stellt ars-blue eine M�glichkeit zur Verf�gung, wie man in ObjectScript am Server �ber Ereignisse informiert werden kann, die durch andere Prozesse ausgel�st wurden. Der Unterschied zu Standard IRIS Systemereignis-Implementation liegt darin, dass man entscheiden kann, wie auf das jeweilige Ereignis reagiert werden soll und ob es eine Protokollierung der Ereignisse geben soll.

### Synchrone Ereignisbehandlung

Bei synchroner Ereignisbehandlung reagiert das System auf ein Ereignis im jeweiligen Prozess, in dem das Ereignis passiert.

**_Vorteil:_** Es ist garantiert, dass am Ende der Ereigniskette die Behandlung des Ereignisses sicher durchgef�hrt wurde.

**_Nachteil:_** Die Behandlung des Ereignisses geht zu Kosten (Performance bzw. unsaubere Behandlung von Sperren) des ausf�hrenden Prozesses. Es ist aber garantiert, dass auch bei einem Fehler in der Behandlung die Ereigniskette weiter abgearbeitet wird.

### Asynchrone Ereignisbehandlung

Bei asynchroner Ereignisbehandlung unterscheidet man zwischen zwei Arten: Prozessorientierter Behandlung und Behandlung durch eine Ereignisqueue. Beiden Varianten ist aber die Abarbeitung in einem eigenen Prozess gemein.

**_Vorteil:_** Die Behandlung des Ereignisses wird in einen separaten Prozess ausgelagert. Dies empfiehlt sich vor allem f�r zeitintensive Behandlungen, die den Ereignisproduzierenden Prozess nicht belasten sollen.

**_Nachteil:_** Es ist nicht garantiert, dass nach dem Ereignis die Ereignisbehandlung auch abgeschlossen ist. Dies ist vor allem bei Transaktionsbehandlung zu ber�cksichtigen: eine etwaige Aufrollung der Daten im Ereignisproduzierenden Prozess kann zu Problemen f�hren, wenn der Ereignisbehandelnde Prozess bereits auf diese Daten zugreifen will! Dies ist durch entsprechende Programmiertechniken zu verhindern!

#### Behandlung durch Benutzerprozess

Bei der Behandlung durch einen Benutzerprozess registriert sich dieser als Interessent f�r ein Ereignis. Tritt das Ereignis ein, wird der Prozess �ber dieses Ereignis informiert. Diese Informationen werden in der Reihenfolge ihres Auftretens zwischengespeichert, bis der Prozess sich um die Ereignisse k�mmert.

**_Vorteil:_** Es kann hoch dynamisch entschieden werden, ob man an einem bestimmten Ereignis interessiert ist. Es ist garantiert, dass alle Ereignisse in der Reihenfolge ihres Auftretens abgehandelt werden.

**_Nachteil:_** Es ist nicht garantiert, dass der Ereigniserhaltende Prozess sich um alle aufgetretenen Ereignisse k�mmert. Wird der Prozess beendet, werden alle Ereignisse verworfen, die noch unbehandelt sind.

Bei der Behandlung durch einen Benutzerprozess ist der Programmierer daf�r verantwortlich, die Ereignisse abzufragen. Dabei kann der Programmierer w�hlen, ob die Abfrage blockieren soll, bis das n�chste Ereignis eintritt (Default Einstellung) oder ob die Abfrage nach einer parametrisierbaren Zeit�berschreitung zur�ckkehren soll. Weiters kann der Programmierer auch w�hlen, ob bei der Abfrage das Ereignis automatisch behandelt werden (Default Einstellung) soll oder ob dies durch den eigenen Programmcode passieren soll.

#### Behandlung durch Ereignisqueue

Eine Ereignisqueue ist ein automatischer Prozess, der sich um Ereignisse k�mmert. Es handelt sich dabei um eine Mischung aus asynchroner und synchroner Ereignisbehandlung. Dabei wird der Empfang der Ereignisse asynchron durchgef�hrt, die Behandlung der Ereignisse aber synchron im Prozess der Ereignisqueue.

**_Vorteil:_** Es kann hoch dynamisch entschieden werden, ob man an einem bestimmten Ereignis interessiert ist. Es ist garantiert, dass alle Ereignisse in der Reihenfolge ihres Auftretens abgehandelt werden und das keine Ereignisse verloren gehen (Ereignisl�cken). Generell muss man sich nicht um das Starten der Ereignisqueue k�mmern, d.h. in dem Moment, wo das Ereignis auftritt, wird die Ereignisqueue gestartet (sollte sie nicht bereits laufen). Werden z.B. nicht alle Ereignisse bis zum Runterfahren der Datenbank behandelt, so gehen die Ereignisse nicht verloren, sondern werden nach dem Hochfahren in ihrer Reihenfolge weiter behandelt.

**_Nachteil:_** Da sich eine Ereignisqueue um verschiedene Ereignisse k�mmern kann, ist es m�glich, dass sich die Behandlungen von Ereignissen verz�gern kann. Dies ist aber durch  vern�nftige Definition der Ereignisqueues in den Griff zu bekommen und h�ngt nur von der m�glichen Anzahl an Prozessen der IRIS Lizenz ab. Optimal w�re nat�rlich eine Ereignisqueue pro Ereignistyp, aber man kann nicht Businessrelevante und Rechenleistung intensive Ereignisse in einer Ereignisqueue gruppieren und Businessrelevante Ereignisse jeweils eine eigene Ereignisqueue zur Verf�gung stellen.

Eine Ereignisqueue kann �ber mehrere Parameter konfiguriert werden:

| Parameter | Beschreibung |
| --- | --- |
| **Name** | Der Name der Ereignisqueue. Der Name kann angepasst werden, muss aber im IRIS Namensraum eindeutig sein. |
| **EventAmountPerLookup** | Bestimmt die Anzahl der Ereignisse, die pro Durchlauf der Queue gelesen werden sollen (Defaultwert = 10). |
| **EventHoldOnError** | Bestimmt, wie die Ereignisqueue auf einen Fehler in der Ereignisbehandlung reagieren soll: <br/><ul><li>**NOHOLD**: Stoppt die weitere Verarbeitung der Ereignisse nicht (Fire And Forget).</li><li>**WARNING**: Stoppt die weitere Verarbeitung der Ereignisse, wenn die Ereignisbehandlung eine Warnung oder einen Fehler zur�ckliefert (Strikte Ereignisbehandlung).</li><li>**ERROR**: Stoppt die weitere Verearbeitung der Ereignisse nur wenn die Ereignisbehandlung einen Fehler zur�ckliefert (Moderate Ereignisbehandlung = Default).</li></ul> |
| **EventLogLevel** | Bestimmt, welche Informationen �ber das Ereignis aufgezeichnet werden sollen: <br/><ul><li>**NOLOG**: Es werden keine Informationen �ber Ereignisse aufgezeichnet.</li><li>**INFO**: Es werden alle Informationen �ber Ereignisse aufgezeichnet.</li><li>**WARNING**: Es werden alle Warnungen und Fehlermeldungen zu Ereignissen aufgezeichnet.</li><li>**ERROR**: Es werden nur Fehlermeldungen zu Ereignissen aufgezeichnet (Default).</li></ul> |
| **EventRun** | Bestimmt, ob die Ereignisqueue automatisch laufen soll oder ob sie ausgesetzt wird: <br/><ul><li>**0**: Die Ereignisqueue wird nach der letzten Ereignisbehandlung gestoppt und nicht wieder automatisch gestartet.</li><li>**1**: Die Ereignisqueue startet automatisch beim n�chsten Ereignis und beginnt die Ereignisbehandlung beim �ltesten Ereignis in der Ereignisqueue.</li></ul> |

Diese Parameter k�nnen �ber ObjectScript oder aber auch �ber SQL Statements gesetzt werden und greifen direkt in den Prozess der Ereignisqueue durch, d.h. nach einer �nderung der Parameter muss die Ereignisqueue nicht gestoppt und neu gestartet werden, sondern sie �bernimmt nach dem letzten Durchlauf die neuen Parameter. Wenn der Parameter `EventRun` gesetzt wird, startet bzw. stoppt die Ereignisqueue entsprechend.

Eine Ereignisqueue kann �ber ObjectScript oder ein Einf�ge-SQL Statement angelegt werden (zus�tzliche Parameter m�ssen entsprechend angegeben werden):

**_ObjectScript:_**
```
// Anlegen der Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).%New()
 
USER>set eventQueue.Name="MyEventQueue"
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())

// Starten der Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")
 
USER>set eventQueue.EventRun=1
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())


// Anlegen und Starten der Ereignisqueue in einem Schritt
USER>set eventQueue=##class(arsblue.event.EventQueue).%New()
 
USER>set eventQueue.Name="MyEventQueue",eventQueue.EventRun=1
 
USER>write $System.Status.GetErrorText(eventQueue.%Save())
```

**-SQL Statement:_**
```
// Anlegen der Ereignisqueue
INSERT INTO arsblue_event.EventQueue (Name) values ('MyEventQueue')

// Starten der Ereignisqueue
UPDATE arsblue_event.EventQueue set EventRun=1 where Name='MyEventQueue')


// Anlegen und Starten der Ereignisqueue in einem Schritt
INSERT INTO arsblue_event.EventQueue (Name, EventRun) values ('MyEventQueue', 1)
```

### System Ereignisse

Es k�nnen sich zu jeder Zeit Interessenten f�r System Ereignisse anmelden bzw. abmelden. Es werden vier von der IRIS Datenbank zur Verf�gung gestellte System Ereignisse (Starten/Stoppen der Datenbank, An- bzw. Abmeldung eines Benutzers, Starten/Stoppen eines Prozesses, Beginn/Ende eines einkommenden Befehls), und ein spezielles System Ereignis zum �berwachen der Betriebssystemaufrufe (Begin/Ende eines ausgehenden Betriebssystemaufrufs) von ars-blue zur Verf�gung gestellt.

Die Ereignisbehandlung kann f�r alle System Ereignisse wie beschrieben angewendet werden, einzige Ausnahme f�r das Ereignis Starten/Stoppen der Datenbank kann keine asynchrone Behandlung durch Benutzerprozesse angeboten werden, da zum Zeitpunkt des Startens bzw. des Stoppens der Datenbank entweder noch keine Benutzerprozesse laufen bzw. diese schon beendet wurden. Ebenso kann keine asynchrone Behandlung durch Ereignisqueues f�r das Stoppen der Datenbank angeboten werden, da die Prozesse der Ereignisqueues auch schon beendet wurden. Dennoch kann dieses Ereignis beim n�chsten Start der Datenbank behandelt werden und somit ein Protokoll f�r ordnungsgem��es Runterfahren der Datenbank erstellt werden. Wird die Datenbank aus irgendeinem Grund nicht ordnungsgem�� runtergefahren, gibt es auch das entsprechende Ereignis nicht und dies kann beim Hochfahren kontrolliert werden.

#### System Ereignis Adapter und System Ereignis

System Ereignisse `arsblue.event.SystemEvent` k�nnen �ber die Implementation des zugeh�rigen Adapters `arsblue.event.SystemEventAdapter` empfangen werden. Das System Ereignis gibt dann Aufschluss dar�ber welches Ereignis stattgefunden hat. Man wird nur �ber jene System Ereignisse informiert, f�r die man sich auch angemeldet hat.
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

#### System Ereignisse synchron behandeln

Um sich f�r System Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel wird das System Ereignis f�r Starten und Stoppen der Datenbank synchron mit dem Beispieladapter angemeldet.
```
// Anmelden f�r synchrone System Ereignisse
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",0,,"SYSTEM")
```

#### System Ereignisse asynchron mit Ereignisqueue behandeln

Um sich f�r System Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel werden die System Ereignisse Anmelden und Prozess starten �ber eine Ereignisqueue angemeldet.
```
// Anmelden f�r asynchrone System Ereignisse f�r Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",,eventQueue,"LOGIN=1,JOB=1")
```

#### System Ereignis asynchron in Benutzerprozess behandeln

Um sich f�r System Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel werden die System Ereignisse Abmelden und Prozess stoppen �ber einen asynchronen Benutzerprozess angemeldet und abgefragt. F�r die Abfrage wird eine entsprechende Instanz von `arsblue.event.SystemEventListener` �ber Referenz zur�ckgeliefert. Die Beispielabfrage blockiert, bis ein entsprechendes Ereignis eintritt und das Ereignis wird im definierten Beispieladapter automatisch behandelt. Der Programmierer kann im weiteren Programm zus�tzliche Schritte ausf�hren bzw. den Event noch weiter auswerten.
```
// Anmelden f�r asynchrone System Ereignisse f�r Benutzerprozess
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(.listener,"User.SystemEventAdapter",,,"LOGIN=2,JOB=2")

// Diese Abfrage kann nun solange wiederholt werden,
// bis der Benutzerprozess seine Arbeit erledigt hat.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Abmelden von angemeldeten System Ereignissen
USER>kill listener
```

Wird die Instanz f�r die Abfrage aus dem Speicher entfernt (Variable wird gel�scht oder der Zust�ndigkeitsbereich der Variable wird verlassen), wird auch automatisch die Registrierung f�r dieses System Ereignis entfernt.

#### Standard IRIS System Ereignisse

Damit die Optionen `SYSTEM`, `LOGIN`, `JOB` und `CALLIN` f�r die Standard IRIS System Ereignis Implementationen funktionieren m�ssen die ars-blue Routinen `%ZSTART` und `%ZSTOP` implementiert werden. Etwaige Implementation aus diesen Routinen sollte in entsprechenden System Ereignis Adapter Klassen ausgelagert werden, die danach synchron registriert und behandelt werden k�nnen. Dadurch erh�ht sich auch die Wartbarkeit des eigenen Programmcodes, da man keine IRIS System Routinen mehr implementieren oder aktualisieren muss.

Folgende Informationen k�nnen in den Ereignis Details abgerufen werden:

| Ereignis | JSON Informationen |
| --- | --- |
| **SYSTEM** | Keine zus�tzlichen Informationen f�r Starten/Stoppen der Datenbank. |
| **LOGIN** <br/> **JOB** <br/> **CALLIN** | Anmelden/Abmelden eines Benutzers, <br/> Starten/Stoppen eines Hintergrundprogramms bzw. <br/> Beginnen/Beenden eines externen Datenbankaufrufs liefern folgende JSON Informationen: <br/><ul><li>**$JOB**: die Prozessnummer</li><li>**$IO**: das Standard Eingabe/Ausgabe Ger�t</li><li>**$ROLES**: die Berechtigungen in der Datenbank</li><li>**$USERNAME**: der IRIS Benutzername</li><li>**ClientIPAddress**: die IP-Adresse des Aufrufers</li><li>**ClientNodeName**: der Host-Name des Aufrufers</li><li>**UserName**: der Betriebssystem Benutzername</li></ul><br/> Leider k�nnen keine Informationen dar�ber zur Verf�gung gestellt werden, welches Programm bzw. welcher Befehl aufgerufen wird, da IRIS diese Information nicht zur Verf�gung stellt. |

#### System Ereignis f�r Betriebssystemaufrufe

Mit der Option `CALLOUT` k�nnen System Ereignisse f�r Betriebssystemaufrufe behandelt werden, die �ber die ars-blue Methode Betriebssystem Befehle ausf�hren (`arsblue.util.Exec`) aufgerufen werden.

Folgende Informationen k�nnen in den Ereignis Details abgerufen werden:

| Ereignis | JSON Informationen |
| --- | --- |
| **CALLOUT** | Beginnen/Beenden eines Betriebssystembefehls liefert folgende JSON Informationen: <br/><ul><li>**$JOB**: die Prozessnummer</li><li>**$IO**: das Standard Eingabe/Ausgabe Ger�t</li><li>**$ROLES**: die Berechtigungen in der Datenbank</li><li>**$USERNAME**: der IRIS Benutzername</li><li>**ClientIPAddress**: die IP-Adresse des Aufrufers</li><li>**ClientNodeName**: der Host-Name des Aufrufers</li><li>**UserName**: der Betriebssystem Benutzername</li><li>**program**: der Betriebssystem Befehl bzw. das Programm</li><li>**path**: das Verzeichnis im Betriebssystem</li><li>**stdin**: der Standard Eingabe-Datenstrom</li><li>**stdout**: der Standard Ausgabe-Datenstrom</li><li>**stderr**: der Standard Fehler-Datenstrom</li><li>**async**: Flag ob Befehl bzw. Programm im Hintergrund (`1`) oder Vordergrund (`0` = Default) ausgef�hrt wird</li><li>**pid**: die Prozess ID im Betriebssystem</li><li>**callback**: Name der Klasse und Method die nach dem Ausf�hren aufgerufen werden soll</li><li>**cmd**: der Befehl bzw. das Programm inklusive Verzeichnisses f�r das Betriebssystem</li></ul><br/> Folgende Information steht zus�tzlich beim Beenden eines Betriebssystembefehls in den JSON Informationen zur Verf�gung: <br/><ul><li>**status**: Status OK oder die Fehlermeldung f�r den Befehl bzw. das Programm</li></ul> |

### Persistierte Daten Ereignisse
Es k�nnen sich zu jeder Zeit Interessenten f�r persistierte Daten Ereignisse anmelden bzw. abmelden. Diese Ereignisse �hneln grob der Implementation eines Triggers in IRIS, jedoch anders als bei IRIS Datenbank Triggern, deren Implementation jedes Mal angepasst werden muss, wenn sich die Anforderung ver�ndert, k�nnen sich �ber die ars-blue Daten Ereignis-Implementation im laufenden Betrieb Prozess registrieren und auch wieder abmelden ohne das die Datenklasse ge�ndert oder kompiliert werden muss. Dies erh�ht die Wartbarkeit des Programmcodes, da nicht immer die Datenklasse mitgetestet werden muss, wenn sich die Businesslogik ver�ndert.

Die Ereignisbehandlung kann f�r alle Persistierten Daten Ereignisse wie beschrieben angewendet werden. Um die Funktionalit�t zu aktivieren muss die Datenklasse von der ars-blue Anbieterklasse `arsblue.event.PersistentEventProvider` abgeleitet und kompiliert werden. Ab diesem Zeitpunkt kann man sich f�r diese Datenklasse registrieren lassen um �ber Datenmanipulationen informiert zu werden.

#### Persistierter Daten Ereignis Adapter und Persistiertes Daten Ereignis

Persistierte Daten Ereignisse `arsblue.event.PersistentEvent` k�nnen �ber die Implementation des zugeh�rigen Adapters `arsblue.event.PersistentEventAdapter` empfangen werden. Das Daten Ereignis gibt dann Aufschluss dar�ber welche Datenmanipulation stattgefunden hat. Man wird nur �ber jene Daten Ereignisse informiert, f�r die man sich auch angemeldet hat.
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

#### Persistierte Daten Ereignisse synchron behandeln

Um sich f�r Persistierte Daten Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel wird das Persistierte Daten Ereignis f�r alle Datenmanipulationen der Beispielklasse synchron mit dem Beispieladapter angemeldet.
```
// Anmelden f�r synchrone Persistierte Daten Ereignisse
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(,"User.PersistentEventAdapter",0,,"User.Data")
```

#### Persistierte Daten Ereignisse asynchron mit Ereignisqueue behandeln

Um sich f�r Persistierte Daten Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel werden die Persistierte Daten Ereignisse f�r Einf�gen (nur ID), Aktualisieren (JSON Differenz Abbild zwischen vor und nach der Aktualisierung) �ber eine Ereignisqueue angemeldet.
```
// Anmelden f�r asynchrone System Ereignisse f�r Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.PersistentEventAdapter",,eventQueue,"User.Data","INSERT=1,UPDATE=2")
```

#### Persistierte Daten Ereignis asynchron in Benutzerprozess behandeln

Um sich f�r Persistierte Daten Ereignisse anzumelden muss man sich beim zugeh�rigen Ereignis mit der gew�nschten Method anmelden. Im nachfolgenden Beispiel werden die Persistierte Daten Ereignisse f�r L�schen �ber einen asynchronen Benutzerprozess angemeldet und abgefragt. F�r die Abfrage wird eine entsprechende Instanz von `arsblue.event.PersistentEventListener` �ber Referenz zur�ckgeliefert. Die Beispielabfrage blockiert, bis ein entsprechendes Ereignis eintritt und das Ereignis wird im definierten Beispieladapter automatisch behandelt. Der Programmierer kann im weiteren Programm zus�tzliche Schritte ausf�hren bzw. den Event noch weiter auswerten.
```
// Anmelden f�r asynchrone System Ereignisse f�r Benutzerprozess
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(.listener,"User.PersistentEventAdapter",,,"User.Data","INSERT=0,UPDATE=0,DELETE")

// Diese Abfrage kann nun solange wiederholt werden,
// bis der Benutzerprozess seine Arbeit erledigt hat.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Abmelden von angemeldeten Persistierte Daten Ereignissen
USER>kill listener
```
Wird die Instanz f�r die Abfrage aus dem Speicher entfernt (Variable wird gel�scht oder der Zust�ndigkeitsbereich der Variable wird verlassen), wird auch automatisch die Registrierung f�r dieses Persistierte Daten Ereignis entfernt.
