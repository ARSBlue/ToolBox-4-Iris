# ARSBlue IRIS API

**Toolbox-4-IRIS** beinhaltet Funktionalit�t, die in IRIS nicht verf�gbar ist, aber die Entwicklung von Applikationen wesentlich vereinfachen kann. Diese Funktionalit�t umfasst zus�tzliche Klassen, einzelne Methoden oder auch effizientere Makros und werden in den jeweiligen Packages beschrieben.

**_Funktionen_**: dabei handelt es sich generell um statische Methoden einer abstrakten Klasse. Abweichungen von dieser Regel werden als solche beschrieben.

## Inhalt

- [Makros](#makros)
- [Datentypen](#datentypen)
- [Daten Ein- und Ausgabe](#daten-ein--und-ausgabe)
- [Serverseitige Ereignisbehandlung](#serverseitige-ereignisbehandlung)
- [N�tzliche Hilfsprogramme](#n%C3%BCtzliche-hilfsprogramme)

## Makros

IRIS beinhaltet ein gro�es Angebot an Makros. Die im Package [arsblue](./arsblue) beschriebenen Makros sind nicht in IRIS vorhanden, erleichtern aber die Entwicklung von Applikationen und erh�hen deren Lesbarkeit.

## Datentypen

IRIS beinhaltet ein gro�es Angebot an Datentypen. Die im Package [arsblue.datatype](./arsblue/datatype) beschriebenen Datentypen sind nicht in IRIS vorhanden, erleichtern aber die Entwicklung von Applikationen.

## Daten Ein- und Ausgabe

IRIS beinhaltet ein gro�es Angebot an Daten Ein- und Ausgabem�glichkeiten. Die im Package [arsblue.io](./arsblue/io) beschriebene Funktionalit�t ist nicht in IRIS vorhanden, erleichtert aber die Entwicklung von Applikationen.

## Serverseitige Ereignisbehandlung

IRIS beinhaltet eine prozessbasiertes Ereignisbehandlung, aber keine M�glichkeit dynamisch auf System- bzw. Datenereignisse (nur durch Implementation von Triggern) zu reagieren. Die im Package [arsblue.event](./arsblue/event) beschriebene Funktionalit�t erm�glicht die Entwicklung von Applikationen die dynamisch auf System- bzw. Datenereignisse reagieren k�nnen sollen.

## N�tzliche Hilfsprogramme

Die im Package [arsblue.util](./arsblue/util) beschriebenen Hilfsprogramme erweitern den Funktioneumfang der in IRIS nicht vorhandenen Standardfunktionen.