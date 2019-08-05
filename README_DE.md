# ARSBlue ToolBox-4-Iris - API für InterSystems IRIS mit einer Sammlung praktischer und nützlicher Tools

Die **Toolbox-4-IRIS** beinhaltet Funktionalität, die in InterSystems IRIS nicht verfügbar ist, aber die Entwicklung von Applikationen wesentlich vereinfachen kann. Diese Funktionalität umfasst zusätzliche Klassen, einzelne Methoden oder auch effizientere Makros. Diese sind  in den jeweiligen Packages beschrieben.

**_Funktionen_**: Dabei handelt es sich generell um statische Methoden einer abstrakten Klasse. Abweichungen von dieser Regel werden als solche beschrieben.

## Inhalt

- [Makros](#makros)
- [Datentypen](#datentypen)
- [Daten Ein- und Ausgabe](#daten-ein--und-ausgabe)
- [Serverseitige Ereignisbehandlung](#serverseitige-ereignisbehandlung)
- [Nützliche Hilfsprogramme](#n%C3%BCtzliche-hilfsprogramme)

## Makros

InterSystem IRIS beinhaltet ein großes Angebot an Makros. Die im Package [arsblue](./arsblue) beschriebenen Makros sind nicht in InterSystems IRIS vorhanden, erleichtern aber die Entwicklung von Applikationen und erhöhen deren Lesbarkeit.

## Datentypen

InterSystems IRIS beinhaltet ein großes Angebot an Datentypen. Die im Package [arsblue.datatype](./arsblue/datatype) beschriebenen Datentypen sind nicht in InterSystems IRIS vorhanden, erleichtern aber die Entwicklung von Applikationen.

## Daten Ein- und Ausgabe

InterSystems IRIS beinhaltet ein großes Angebot an Daten Ein- und Ausgabemöglichkeiten. Die im Package [arsblue.io](./arsblue/io) beschriebene Funktionalität ist nicht in IRIS vorhanden, erleichtert aber die Entwicklung von Applikationen.

## Serverseitige Ereignisbehandlung

InterSystems IRIS beinhaltet eine prozessbasiertes Ereignisbehandlung, aber keine Möglichkeit dynamisch auf System- bzw. Datenereignisse (nur durch Implementation von Triggern) zu reagieren. Die im Package [arsblue.event](./arsblue/event) beschriebene Funktionalität ermöglicht die Entwicklung von Applikationen, die dynamisch auf System- bzw. Datenereignisse reagieren können sollen.

## Nützliche Hilfsprogramme

Die im Package [arsblue.util](./arsblue/util) beschriebenen Hilfsprogramme erweitern den Funktioneumfang der in InterSystems IRIS nicht vorhandenen Standardfunktionen.

## License ##

Informationen zu Lizenzrechten und -beschränkungen finden Sie in [LICENSE](./LICENSE) (MIT).
