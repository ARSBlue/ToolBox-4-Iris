# ARSBlue ToolBox-4-Iris -- Event Package

**_Dokumentation_**: Die Dokumentation steht sowohl in Englisch [README.md](./README.md) als auch in Deutsch [README_DE.md](./README_DE.md) zur Verfügung.

- [Serverseitige Ereignisbehandlung](#serverseitige-ereignisbehandlung)
  - [Synchrone Ereignisbehandlung](#synchrone-ereignisbehandlung)
  - [Asynchrone Ereignisbehandlung](#asynchrone-ereignisbehandlung)
    - [Behandlung durch Benutzerprozess](#behandlung-durch-benutzerprozess)
    - [Behandlung durch Ereignisqueue](#behandlung-durch-ereignisqueue)
  - [System Ereignisse](#system-ereignisse)
    - [System Ereignis Adapter und System Ereignis](#system-ereignis-adapter-und-system-ereignis)
    - [System Ereignisse synchron behandeln](#system-ereignisse-synchron-behandeln)
    - [System Ereignisse asynchron mit Ereignisqueue behandeln](#system-ereignisse-asynchron-mit-ereignisqueue-behandeln)
    - [System Ereignis asynchron in Benutzerprozess behandeln](#system-ereignis-asynchron-in-benutzerprozess-behandeln)
    - [Standard IRIS System Ereignisse](#standard-iris-system-ereignisse)
    - [System Ereignis für Betriebssystemaufrufe](#system-ereignis-f%C3%BCr-betriebssystemaufrufe)
  - [Persistierte Daten Ereignisse](#persistierte-daten-ereignisse)
    - [Persistierter Daten Ereignis Adapter und Persistiertes Daten Ereignis](#persistierter-daten-ereignis-adapter-und-persistiertes-daten-ereignis)
    - [Persistierte Daten Ereignisse synchron behandeln](#persistierte-daten-ereignisse-synchron-behandeln)
    - [Persistierte Daten Ereignisse asynchron mit Ereignisqueue behandeln](#persistierte-daten-ereignisse-asynchron-mit-ereignisqueue-behandeln)
    - [Persistierte Daten Ereignisse asynchron in Benutzerprozess behandeln](#persistierte-daten-ereignisse-asynchron-in-benutzerprozess-behandeln)

## Serverseitige Ereignisbehandlung

Mit der serverseitigen Ereignisbehandlung stellt ARS Blue eine Möglichkeit zur Verfügung, wie man in ObjectScript am Server über Ereignisse informiert werden kann, die durch andere Prozesse ausgelöst wurden. Der Unterschied zur Standard InterSystems IRIS Systemereignis-Implementation liegt darin, dass man entscheiden kann, wie auf das jeweilige Ereignis reagiert werden soll und ob es eine Protokollierung der Ereignisse geben soll.

### Synchrone Ereignisbehandlung

Bei synchroner Ereignisbehandlung reagiert das System auf ein Ereignis im jeweiligen Prozess, in dem das Ereignis passiert.

**_Vorteil:_** Es ist garantiert, dass am Ende der Ereigniskette die Behandlung des Ereignisses sicher durchgeführt wurde.

**_Nachteil:_** Die Behandlung des Ereignisses geht zu Kosten (Performance bzw. unsaubere Behandlung von Sperren) des ausführenden Prozesses. Es ist aber garantiert, dass auch bei einem Fehler in der Behandlung die Ereigniskette weiter abgearbeitet wird.

### Asynchrone Ereignisbehandlung

Bei asynchroner Ereignisbehandlung unterscheidet man zwischen zwei Arten: Prozessorientierter Behandlung und Behandlung durch eine Ereignisqueue. Beiden Varianten ist aber die Abarbeitung in einem eigenen Prozess gemein.

**_Vorteil:_** Die Behandlung des Ereignisses wird in einen separaten Prozess ausgelagert. Dies empfiehlt sich vor allem für zeitintensive Behandlungen, die den Ereignisproduzierenden Prozess nicht belasten sollen.

**_Nachteil:_** Es ist nicht garantiert, dass nach dem Ereignis die Ereignisbehandlung auch abgeschlossen ist. Dies ist vor allem bei Transaktionsbehandlung zu berücksichtigen: eine etwaige Aufrollung der Daten im Ereignisproduzierenden Prozess kann zu Problemen führen, wenn der Ereignisbehandelnde Prozess bereits auf diese Daten zugreifen will! Dies ist durch entsprechende Programmiertechniken zu verhindern!

#### Behandlung durch Benutzerprozess

Bei der Behandlung durch einen Benutzerprozess registriert sich dieser als Interessent für ein Ereignis. Tritt das Ereignis ein, wird der Prozess über dieses Ereignis informiert. Diese Informationen werden in der Reihenfolge ihres Auftretens zwischengespeichert, bis der Prozess sich um die Ereignisse kümmert.

**_Vorteil:_** Es kann hoch dynamisch entschieden werden, ob man an einem bestimmten Ereignis interessiert ist. Es ist garantiert, dass alle Ereignisse in der Reihenfolge ihres Auftretens abgehandelt werden.

**_Nachteil:_** Es ist nicht garantiert, dass der Ereigniserhaltende Prozess sich um alle aufgetretenen Ereignisse kümmert. Wird der Prozess beendet, werden alle Ereignisse verworfen, die noch unbehandelt sind.

Bei der Behandlung durch einen Benutzerprozess ist der Programmierer dafür verantwortlich, die Ereignisse abzufragen. Dabei kann der Programmierer wählen, ob die Abfrage blockieren soll, bis das nächste Ereignis eintritt (Default Einstellung) oder ob die Abfrage nach einer parametrisierbaren Zeitüberschreitung zurückkehren soll. Weiters kann der Programmierer auch wählen, ob bei der Abfrage das Ereignis automatisch behandelt werden (Default Einstellung) soll oder ob dies durch den eigenen Programmcode passieren soll.

#### Behandlung durch Ereignisqueue

Eine Ereignisqueue ist ein automatischer Prozess, der sich um Ereignisse kümmert. Es handelt sich dabei um eine Mischung aus asynchroner und synchroner Ereignisbehandlung. Dabei wird der Empfang der Ereignisse asynchron durchgeführt, die Behandlung der Ereignisse aber synchron im Prozess der Ereignisqueue.

**_Vorteil:_** Es kann hoch dynamisch entschieden werden, ob man an einem bestimmten Ereignis interessiert ist. Es ist garantiert, dass alle Ereignisse in der Reihenfolge ihres Auftretens abgehandelt werden und das keine Ereignisse verloren gehen (keine Ereignislücken). Generell muss man sich nicht um das Starten der Ereignisqueue kümmern, d.h. in dem Moment, wo das Ereignis auftritt, wird die Ereignisqueue gestartet (sollte sie nicht bereits laufen). Werden z.B. nicht alle Ereignisse bis zum Runterfahren der Datenbank behandelt, so gehen die Ereignisse nicht verloren, sondern werden nach dem Hochfahren in ihrer Reihenfolge weiter behandelt.

**_Nachteil:_** Da sich eine Ereignisqueue um verschiedene Ereignisse kümmern kann, ist es möglich, dass sich die Behandlungen von Ereignissen verzögern kann. Dies ist aber durch  vernünftige Definition der Ereignisqueues in den Griff zu bekommen und hängt nur von der möglichen Anzahl an Prozessen der InterSystems IRIS Lizenz ab. Optimal wäre natürlich eine Ereignisqueue pro Ereignistyp, aber man kann nicht businessrelevante und rechenleistung-intensive Ereignisse in einer Ereignisqueue gruppieren und businessrelevante Ereignisse jeweils eine eigene Ereignisqueue zur Verfügung stellen.

Eine Ereignisqueue kann über mehrere Parameter konfiguriert werden:

| Parameter | Beschreibung |
| --- | --- |
| **Name** | Der Name der Ereignisqueue. Der Name kann angepasst werden, muss aber im InterSystems IRIS Namensraum eindeutig sein. |
| **EventAmountPerLookup** | Bestimmt die Anzahl der Ereignisse, die pro Durchlauf der Queue gelesen werden sollen (Defaultwert = 10). |
| **EventHoldOnError** | Bestimmt, wie die Ereignisqueue auf einen Fehler in der Ereignisbehandlung reagieren soll: <br/><ul><li>**NOHOLD**: Stoppt die weitere Verarbeitung der Ereignisse nicht (Fire And Forget).</li><li>**WARNING**: Stoppt die weitere Verarbeitung der Ereignisse, wenn die Ereignisbehandlung eine Warnung oder einen Fehler zurückliefert (Strikte Ereignisbehandlung).</li><li>**ERROR**: Stoppt die weitere Verearbeitung der Ereignisse nur wenn die Ereignisbehandlung einen Fehler zurückliefert (Moderate Ereignisbehandlung = Default).</li></ul> |
| **EventLogLevel** | Bestimmt, welche Informationen über das Ereignis aufgezeichnet werden sollen: <br/><ul><li>**NOLOG**: Es werden keine Informationen über Ereignisse aufgezeichnet.</li><li>**INFO**: Es werden alle Informationen über Ereignisse aufgezeichnet.</li><li>**WARNING**: Es werden alle Warnungen und Fehlermeldungen zu Ereignissen aufgezeichnet.</li><li>**ERROR**: Es werden nur Fehlermeldungen zu Ereignissen aufgezeichnet (Default).</li></ul> |
| **EventRun** | Bestimmt, ob die Ereignisqueue automatisch laufen soll oder ob sie ausgesetzt wird: <br/><ul><li>**0**: Die Ereignisqueue wird nach der letzten Ereignisbehandlung gestoppt und nicht wieder automatisch gestartet.</li><li>**1**: Die Ereignisqueue startet automatisch beim nächsten Ereignis und beginnt die Ereignisbehandlung beim ältesten Ereignis in der Ereignisqueue.</li></ul> |

Diese Parameter können über ObjectScript oder aber auch über SQL Statements gesetzt werden und greifen direkt in den Prozess der Ereignisqueue durch, d.h. nach einer Änderung der Parameter muss die Ereignisqueue nicht gestoppt und neu gestartet werden, sondern sie übernimmt nach dem letzten Durchlauf die neuen Parameter. Wenn der Parameter `EventRun` gesetzt wird, startet bzw. stoppt die Ereignisqueue entsprechend.

Eine Ereignisqueue kann über ObjectScript oder ein Einfüge-SQL Statement angelegt werden (zusätzliche Parameter müssen entsprechend angegeben werden):

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

**_SQL Statement:_**
```
// Anlegen der Ereignisqueue
INSERT INTO arsblue_event.EventQueue (Name) values ('MyEventQueue')

// Starten der Ereignisqueue
UPDATE arsblue_event.EventQueue set EventRun=1 where Name='MyEventQueue')


// Anlegen und Starten der Ereignisqueue in einem Schritt
INSERT INTO arsblue_event.EventQueue (Name, EventRun) values ('MyEventQueue', 1)
```

### System Ereignisse

Es können sich zu jeder Zeit Interessenten für System Ereignisse anmelden bzw. abmelden. Es werden vier von der InterSystems IRIS Datenbank zur Verfügung gestellte System Ereignisse (Starten/Stoppen der Datenbank, An- bzw. Abmeldung eines Benutzers, Starten/Stoppen eines Prozesses, Beginn/Ende eines einkommenden Befehls), und ein spezielles System Ereignis zum Überwachen der Betriebssystemaufrufe (Begin/Ende eines ausgehenden Betriebssystemaufrufs) von ARS Blue zur Verfügung gestellt.

Die Ereignisbehandlung kann für alle System Ereignisse wie beschrieben angewendet werden, einzige Ausnahme für das Ereignis Starten/Stoppen der Datenbank kann keine asynchrone Behandlung durch Benutzerprozesse angeboten werden, da zum Zeitpunkt des Startens bzw. des Stoppens der Datenbank entweder noch keine Benutzerprozesse laufen bzw. diese schon beendet wurden. Ebenso kann keine asynchrone Behandlung durch Ereignisqueues für das Stoppen der Datenbank angeboten werden, da die Prozesse der Ereignisqueues auch schon beendet wurden. Dennoch kann dieses Ereignis beim nächsten Start der Datenbank behandelt werden und somit ein Protokoll für ordnungsgemäßes Runterfahren der Datenbank erstellt werden. Wird die Datenbank aus irgendeinem Grund nicht ordnungsgemäß runtergefahren, gibt es auch das entsprechende Ereignis nicht und dies kann beim Hochfahren kontrolliert werden.

#### System Ereignis Adapter und System Ereignis

System Ereignisse `arsblue.event.SystemEvent` können über die Implementation des zugehörigen Adapters `arsblue.event.SystemEventAdapter` empfangen werden. Das System Ereignis gibt dann Aufschluss darüber welches Ereignis stattgefunden hat. Man wird nur über jene System Ereignisse informiert, für die man sich auch angemeldet hat.
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

Um sich für System Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Method anmelden. Im nachfolgenden Beispiel wird das System Ereignis für Starten und Stoppen der Datenbank synchron mit dem Beispieladapter angemeldet.
```
// Anmelden für synchrone System Ereignisse
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",0,,"SYSTEM")
```

#### System Ereignisse asynchron mit Ereignisqueue behandeln

Um sich für System Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Method anmelden. Im nachfolgenden Beispiel werden die System Ereignisse Anmelden und Prozess starten über eine Ereignisqueue angemeldet.
```
// Anmelden für asynchrone System Ereignisse für Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.SystemEventAdapter",,eventQueue,"LOGIN=1,JOB=1")
```

#### System Ereignis asynchron in Benutzerprozess behandeln

Um sich für System Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Method anmelden. Im nachfolgenden Beispiel werden die System Ereignisse Abmelden und Prozess stoppen über einen asynchronen Benutzerprozess angemeldet und abgefragt. Für die Abfrage wird eine entsprechende Instanz von `arsblue.event.SystemEventListener` über Referenz zurückgeliefert. Die Beispielabfrage blockiert, bis ein entsprechendes Ereignis eintritt und das Ereignis wird im definierten Beispieladapter automatisch behandelt. Der Programmierer kann im weiteren Programm zusätzliche Schritte ausführen bzw. den Event noch weiter auswerten.
```
// Anmelden für asynchrone System Ereignisse für Benutzerprozess
USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(.listener,"User.SystemEventAdapter",,,"LOGIN=2,JOB=2")

// Diese Abfrage kann nun solange wiederholt werden
// bis der Benutzerprozess seine Arbeit erledigt hat.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Abmelden von angemeldeten System Ereignissen
USER>kill listener
```

Wird die Instanz für die Abfrage aus dem Speicher entfernt (Variable wird gelöscht oder der Zuständigkeitsbereich der Variable wird verlassen), wird auch automatisch die Registrierung für dieses System Ereignis entfernt.

#### Standard InterSystems IRIS System Ereignisse

Damit die Optionen `SYSTEM`, `LOGIN`, `JOB` und `CALLIN` für die Standard InterSystems IRIS System Ereignis Implementationen funktionieren müssen die arsblue Routinen `%ZSTART` und `%ZSTOP` implementiert werden. Etwaige Implementation aus diesen Routinen sollte in entsprechenden System Ereignis Adapter Klassen ausgelagert werden, die danach synchron registriert und behandelt werden können. Dadurch erhöht sich auch die Wartbarkeit des eigenen Programmcodes, da man keine InterSystems IRIS System Routinen mehr implementieren oder aktualisieren muss.

Folgende Informationen können in den Ereignis Details abgerufen werden:

| Ereignis | JSON Informationen |
| --- | --- |
| **SYSTEM** | Keine zusätzlichen Informationen für Starten/Stoppen der Datenbank. |
| **LOGIN** <br/> **JOB** <br/> **CALLIN** | Anmelden/Abmelden eines Benutzers, <br/> Starten/Stoppen eines Hintergrundprogramms bzw. <br/> Beginnen/Beenden eines externen Datenbankaufrufs liefern folgende JSON Informationen: <br/><ul><li>**$JOB**: die Prozessnummer</li><li>**$IO**: das Standard Eingabe/Ausgabe Gerät</li><li>**$ROLES**: die Berechtigungen in der Datenbank</li><li>**$USERNAME**: der IRIS Benutzername</li><li>**ClientIPAddress**: die IP-Adresse des Aufrufers</li><li>**ClientNodeName**: der Host-Name des Aufrufers</li><li>**UserName**: der Betriebssystem Benutzername</li></ul><br/> Leider können keine Informationen darüber zur Verfügung gestellt werden, welches Programm bzw. welcher Befehl aufgerufen wird, da InterSystems IRIS diese Information nicht zur Verfügung stellt. |

#### System Ereignis für Betriebssystemaufrufe

Mit der Option `CALLOUT` können System Ereignisse für Betriebssystemaufrufe behandelt werden, die über die ars-blue Methode Betriebssystem Befehle ausführen (`arsblue.util.Exec`) aufgerufen werden.

Folgende Informationen können in den Ereignis Details abgerufen werden:

| Ereignis | JSON Informationen |
| --- | --- |
| **CALLOUT** | Beginnen/Beenden eines Betriebssystembefehls liefert folgende JSON Informationen: <br/><ul><li>**$JOB**: die Prozessnummer</li><li>**$IO**: das Standard Eingabe/Ausgabe Gerät</li><li>**$ROLES**: die Berechtigungen in der Datenbank</li><li>**$USERNAME**: der InterSystems IRIS Benutzername</li><li>**ClientIPAddress**: die IP-Adresse des Aufrufers</li><li>**ClientNodeName**: der Host-Name des Aufrufers</li><li>**UserName**: der Betriebssystem Benutzername</li><li>**program**: der Betriebssystembefehl bzw. das Programm</li><li>**path**: das Verzeichnis im Betriebssystem</li><li>**stdin**: der Standard Eingabe-Datenstrom</li><li>**stdout**: der Standard Ausgabe-Datenstrom</li><li>**stderr**: der Standard Fehler-Datenstrom</li><li>**async**: Flag ob Befehl bzw. Programm im Hintergrund (`1`) oder Vordergrund (`0` = Default) ausgeführt wird</li><li>**pid**: die Prozess ID im Betriebssystem</li><li>**callback**: Name der Klasse und Methode, die nach dem Ausführen aufgerufen werden soll</li><li>**cmd**: der Befehl bzw. das Programm inklusive Verzeichnisses für das Betriebssystem</li></ul><br/> Folgende Information steht zusätzlich beim Beenden eines Betriebssystembefehls in den JSON Informationen zur Verfügung: <br/><ul><li>**status**: Status OK oder die Fehlermeldung für den Befehl bzw. das Programm</li></ul> |

### Persistierte Daten Ereignisse

Es können sich zu jeder Zeit Interessenten für persistierte Daten Ereignisse anmelden bzw. abmelden. Diese Ereignisse ähneln grob der Implementation eines Triggers in InterSystems IRIS, jedoch anders als bei InterSystems IRIS Datenbank Triggern, deren Implementation jedes Mal angepasst werden muss, wenn sich die Anforderung verändert, können sich über die arsblue Daten Ereignis-Implementation im laufenden Betrieb Prozess registrieren und auch wieder abmelden ohne das die Datenklasse geändert oder kompiliert werden muss. Dies erhöht die Wartbarkeit des Programmcodes, da nicht immer die Datenklasse mitgetestet werden muss, wenn sich die Businesslogik verändert.

Die Ereignisbehandlung kann für alle Persistierten Daten Ereignisse wie beschrieben angewendet werden. Um die Funktionalität zu aktivieren muss die Datenklasse von der arsblue Anbieterklasse `arsblue.event.PersistentEventProvider` abgeleitet und kompiliert werden. Ab diesem Zeitpunkt kann man sich für diese Datenklasse registrieren lassen um über Datenmanipulationen informiert zu werden.

#### Persistierter Daten Ereignis Adapter und Persistiertes Daten Ereignis

Persistierte Daten Ereignisse `arsblue.event.PersistentEvent` können über die Implementation des zugehörigen Adapters `arsblue.event.PersistentEventAdapter` empfangen werden. Das Daten Ereignis gibt dann Aufschluss darüber welche Datenmanipulation stattgefunden hat. Man wird nur über jene Daten Ereignisse informiert, für die man sich auch angemeldet hat.
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

Um sich für Persistierte Daten Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Method anmelden. Im nachfolgenden Beispiel wird das Persistierte Daten Ereignis für alle Datenmanipulationen der Beispielklasse synchron mit dem Beispieladapter angemeldet.
```
// Anmelden für synchrone Persistierte Daten Ereignisse
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(,"User.PersistentEventAdapter",0,,"User.Data")
```

#### Persistierte Daten Ereignisse asynchron mit Ereignisqueue behandeln

Um sich für Persistierte Daten Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Methode anmelden. Im nachfolgenden Beispiel werden die Persistierte Daten Ereignisse für Einfügen (nur ID), Aktualisieren (JSON Differenz Abbild zwischen vor und nach der Aktualisierung) über eine Ereignisqueue angemeldet.
```
// Anmelden für asynchrone System Ereignisse für Ereignisqueue
USER>set eventQueue=##class(arsblue.event.EventQueue).NameOpen("MyEventQueue")

USER>write $System.Status.GetErrorText(##class(arsblue.event.SystemEvent).AddEventListener(,"User.PersistentEventAdapter",,eventQueue,"User.Data","INSERT=1,UPDATE=2")
```

#### Persistierte Daten Ereignis asynchron in Benutzerprozess behandeln

Um sich für Persistierte Daten Ereignisse anzumelden muss man sich beim zugehörigen Ereignis mit der gewünschten Methode anmelden. Im nachfolgenden Beispiel werden die Persistierte Daten Ereignisse für Löschen über einen asynchronen Benutzerprozess angemeldet und abgefragt. Für die Abfrage wird eine entsprechende Instanz von `arsblue.event.PersistentEventListener` über Referenz zurückgeliefert. Die Beispielabfrage blockiert, bis ein entsprechendes Ereignis eintritt und das Ereignis wird im definierten Beispieladapter automatisch behandelt. Der Programmierer kann im weiteren Programm zusätzliche Schritte ausführen bzw. den Event noch weiter auswerten.
```
// Anmelden für asynchrone System Ereignisse für Benutzerprozess
USER>write $System.Status.GetErrorText(##class(arsblue.event.PersistentEvent).AddEventListener(.listener,"User.PersistentEventAdapter",,,"User.Data","INSERT=0,UPDATE=0,DELETE")

// Diese Abfrage kann nun solange wiederholt werden,
// bis der Benutzerprozess seine Arbeit erledigt hat.
USER>write $System.Status.GetErrorText(listener.GetNext(.event))

// Abmelden von angemeldeten Persistierte Daten Ereignissen
USER>kill listener
```
Wird die Instanz für die Abfrage aus dem Speicher entfernt (Variable wird gelöscht oder der Zuständigkeitsbereich der Variable wird verlassen), wird auch automatisch die Registrierung für dieses Persistierte Daten Ereignis entfernt.
