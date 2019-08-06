# ARSBlue ToolBox-4-Iris

**API für InterSystems IRIS mit einer Sammlung praktischer und nützlicher Tools**

Die **ToolBox-4-IRIS** enthält eine Sammlung praktischer und nützlicher Tools - sprich Features, die in InterSystems IRIS nicht verfügbar sind, aber die Entwicklung von Applikationen wesentlich vereinfachen. Dies umfasst zusätzliche Klassen, einzelne Methoden oder auch effizientere Makros, welche in den jeweiligen Packages beschrieben sind.

**_Funktionen_**: Dabei handelt es sich generell um statische Methoden einer abstrakten Klasse. Abweichungen von dieser Regel werden als solche beschrieben.

**_Dokumentation_**: Die Dokumentation steht sowohl in Englisch (README.md) als auch in Deutsch (README_DE.md) zur Verfügung.

## Inhalt

- [Makros](#makros)
- [Datentypen](#datentypen)
- [Daten Ein- und Ausgabe](#daten-ein-und-ausgabe)
- [Serverseitige Ereignisbehandlung](#serverseitige-ereignisbehandlung)
- [Nützliche Hilfsprogramme](#n%C3%BCtzliche-hilfsprogramme)
- [Lizenz](#lizenz)

## Makros

Im Package [arsblue](./arsblue) sind Makros enthalten, die in InterSystems IRIS nicht vorhanden sind, aber die Entwicklung von Applikationen erleichtern und die Lesbarkeit erhöhen. 

Dazu gehören z.B. allgemeine ObjectScript Makros, Status Makros, National Language Support Makros und JavaScript Makros.

## Datentypen

Das Package [arsblue.datatype](./arsblue/datatype) enthält zusätzliche, dynamische Datentypen für Datum, Zeit und Zeitstempel, die in InterSystems IRIS nicht vorhanden sind, aber die Entwicklung von Applikationen wesentlich erleichtern und die Lesbarkeit erhöhen. 

Diese Datentypen umfassen Formatierung, Speicherbedarf, SQL und Performance und ähnliches mehr.

## Daten Ein- und Ausgabe

Im Package [arsblue.io](./arsblue/io) sind nützliche Funktionen zum Arbeiten mit Dateien und Verzeichnissen enthalten, die in InterSystems IRIS nicht vorhanden sind, aber die Entwicklung von Applikationen wesentlich vereinfachen. 

Dazu gehören allgemeine Datei- und Verzeichnis-Funktionen, Prüfung von Dateien oder Verzeichnissen auf Existenz oder Inhalt, Löschen von Dateien und Verzeichnissen, Serialisierung von Objektinstanzen von/nach JSON und einiges mehr.

## Serverseitige Ereignisbehandlung

Mit der im Package [arsblue.event](./arsblue/event) enthaltenen Funktionalität wird die Entwicklung von Applikationen, die dynamisch auf System- bzw. Datenereignisse reagieren können sollen, ermöglicht. InterSystems IRIS verfügt zwar über eine prozessbasierte  Ereignisbehandlung, hat aber keine Möglichkeit dynamisch auf System- bzw. Datenereignisse (nur durch Implementation von Triggern) zu reagieren.

Zum Package gehören eine synchrone oder asynchrone Ereignisbehandlung durch Benutzerprozess oder Ereignisqueue, die synchrone oder asynchrone Anwendung von Systemereignissen oder die Behandlung persistierter Datenereignisse.

## Nützliche Hilfsprogramme

Die im Package [arsblue.util](./arsblue/util) beschriebenen Hilfsprogramme erweitern den Funktionsumfang der in InterSystems IRIS nicht vorhandenen Standardfunktionen.

Im Package enthalten sind unter anderem zahlreiche Kalender-Funktionen (Schaltjahr, Kalenderwoche, Wochentag, Feiertage etc.), eine Möglichkeit zur freien Formatierung von Datum, Zeit und Zeitstempel sowie Funktionen zur Ausführung von Betriebssystembefehlen und einige JSON Hilfsprogramme (zum Kopieren, Prüfen, Vergleichen, Exportieren, Importieren, Lesen, Schreiben etc.).

## Lizenz ##

Informationen zu Lizenzrechten und -beschränkungen finden Sie in [LICENSE](./LICENSE) (MIT).
