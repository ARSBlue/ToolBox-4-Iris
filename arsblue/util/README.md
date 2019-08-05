# ARSBlue IRIS Util Package

- [Gregorianischer Kalender](#gregorianischer-kalender)
  - [Schaltjahr](#schaltjahr)
  - [Anzahl Tage im Monat](#anzahl-tage-im-monat)
  - [Anzahl der Kalenderwochen im Jahr](#anzahl-der-kalenderwochen-im-jahr)
  - [Kalenderwoche f�r Datum](#kalenderwoche-f%C3%BCr-datum)
  - [Erster Tag in Kalenderwoche](#erster-tag-in-kalenderwoche)
  - [Letzter Tag in Kalenderwoche](#letzter-tag-in-kalenderwoche)
  - [Wochentag f�r Datum](#wochentag-f%C3%BCr-datum)
  - [Ostersonntag](#ostersonntag)
  - [Feiertage](#feiertage)
- [Datum, Zeit und Zeitstempel](#datum-zeit-und-zeitstempel)
  - [Frei Formattieren](#frei-formattieren)
- [Betriebssystem Befehle ausf�hren](#betriebssystem-befehle-ausf%C3%BChren)
  - [Ausgabe und Fehlerausgabe einfangen](#ausgabe-und-fehlerausgabe-einfangen)
  - [Eingabe �bergeben](#eingabe-%C3%BCbergeben)
  - [Verzeichnis angeben](#verzeichnis-angeben)
  - [R�ckruf verwenden](#r%C3%BCckruf-verwenden)
  - [Befehl asynchron ausf�hren](#befehl-asynchron-ausf%C3%BChren)
  - [Befehl asynchron ausf�hren mit R�ckruf](#befehl-asynchron-ausf%C3%BChren-mit-r%C3%BCckruf)
- [JSON Hilfsprogramme](#json-hilfsprogramme)
  - [JSON Makro in Quellcode einbinden](#json-makro-in-quellcode-einbinden)
  - [JSON Index Suche nach Wert](#json-index-suche-nach-wert)
  - [JSON Arrays bzw. Objekte kopieren](#json-arrays-bzw-objekte-kopieren)
    - [JSON kopieren](#json-kopieren)
    - [JSON kopieren mit �berschreiben der Zieldaten](#json-kopieren-mit-%C3%BCberschreiben-der-zieldaten)
    - [JSON kopieren von nicht vorhandenen Daten](#json-kopieren-von-nicht-vorhandenen-daten)
    - [JSON kopieren von vorhandenen Daten](#json-kopieren-von-vorhandenen-daten)
  - [JSON Arrays bzw. Objekte auf Gleichheit pr�fen](#json-arrays-bzw-objekte-auf-gleichheit-pr%C3%BCfen)
  - [JSON Arrays bzw. Objekte vergleichen](#json-arrays-bzw-objekte-vergleichen)
  - [Datenobjekte nach JSON exportieren](#datenobjekte-nach-json-exportieren)
  - [Datenobjekte von JSON importieren](#datenobjekte-von-json-importieren)
  - [JSON und `$LIST`](#json-und-list)
  - [JSON und `%Library.Status`](#json-und-librarystatus)
  - [JSON lesen](#json-lesen)
  - [JSON schreiben](#json-schreiben)

## Gregorianischer Kalender

Die Klasse `arsblue.util.Calendar` unterst�tz bei Datum und Zeit Problemen. Im Folgenden werden die Funktionen vorgestellt, die in keiner Standard IRIS Datum oder Zeit Implementation vorhanden sind. Eine detaillierte Information der Methodenparameter der vorgestellten Methoden bzw. aller verf�gbaren Methoden kann �ber die IRIS Klassendokumentation abgerufen werden.

Die Funktionen wurden aufgrund europ�ischer Anforderungen umgesetzt, d.h. eine Woche beginnt mit Montag und endet mit Sonntag und die Feiertage entsprechen der konfigurierten L�ndereinstellung. Derzeit stehen die Feiertage f�r Deutschland (Evangelische und R�misch-Katholische Festtage) und �sterreich (R�misch-Katholischen Festtage) zur Verf�gung. Die Schnittstelle kann aber f�r jedes Land individuell erweitert werden.

Die im Folgenden beschriebenen Methoden haben aufgrund der IRIS `$HOROLOG` Implementation einen Wertebereich f�r Datum von 31.12.1840 bis 31.12.9999, darunter bzw. dar�ber k�nnen keine Werte geliefert werden. Daraus resultierende Spezialf�lle werden in den folgenden Methoden erw�hnt.

### Schaltjahr

Mit dieser Methode kann ein Jahr �berpr�ft werden, ob es sich dabei um ein Schaltjahr handelt.
```
USER>write ##class(arsblue.util.Calendar).IsLeapYear(2019)
0
USER>write ##class(arsblue.util.Calendar).IsLeapYear(2020)
1
```

### Anzahl Tage im Monat

Mit dieser Methode kann die Anzahl der Tage in einem Monat ermittelt werden (unter Ber�cksichtigung von Schaltjahren).
```
USER>write ##class(arsblue.util.Calendar).GetDaysInMonth(2019,2)
28
USER>write ##class(arsblue.util.Calendar).GetDaysInMonth(2020,2)
29
```

### Anzahl der Kalenderwochen im Jahr

Mit dieser Methode kann die Anzahl der Kalenderwochen in einem Jahr ermittelt werden.
```
USER>write ##class(arsblue.util.Calendar).GetWeeksInYear(2019)
52
USER>write ##class(arsblue.util.Calendar).GetWeeksInYear(2020)
53
```

### Kalenderwoche f�r Datum

Mit dieser Methode kann die Kalenderwoche f�r ein Datum ermittelt werden.
```
USER>set var=20160101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20160101 is 53 in 2015
USER>set var=20170101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20170101 is 52 in 2016
USER>set var=20180101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20180101 is 01 in 2018
```

### Erster Tag in Kalenderwoche

Mit dieser Methode kann der erste Tag (Montag) f�r eine Kalenderwoche ermittelt werden.
```
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201553)
20151228
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201652)
20161226
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201752)
20171225
```
Da die Kalenderwoche nicht Jahrestreu ist, gibt es eine spezielle Variante dieser Methode, die beim Jahreswechsel nicht den ersten Tag der Kalenderwoche liefert, sondern den ersten Tag im Jahr (sonst funktioniert diese Methode aber gleich wie die Standardmethode).
```
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201901)
20181231
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeekInYear(201901)
20190101
```
Aufgrund der IRIS `$HOROLOG` Implementation kann f�r Kalenderwoche 1840/53 nicht das korrekte Datum geliefert werden, sondern es wird das erste valide IRIS `$HOROLOG` Datum (31.12.1840) geliefert.

### Letzter Tag in Kalenderwoche

Mit dieser Methode kann der letzte Tag (Sonntag) f�r eine Kalenderwoche ermittelt werden.
```
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201553)
20160103
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201652)
20170101
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201752)
20171231
```
Aufgrund der IRIS `$HOROLOG` Implementation kann f�r die Kalenderwoche 9999/52 nicht das korrekte Datum geliefert werden, sondern es wird das letzte valide IRIS `$HOROLOG` Datum (31.12.9999) geliefert.

### Wochentag f�r Datum

Mit dieser Methode kann der Wochentag f�r ein Datum bestimmt werden (`1`=Montag bis `7`=Sonntag).
```
USER>write ##class(arsblue.util.Calendar).GetDayInWeek(20190101)
2
```

### Ostersonntag

Mit dieser Methode kann der Ostersonntag f�r ein Jahr bestimmt werden. Dieser Tag wird f�r die Berechnung der meisten kirchlichen Festtage f�r die Evangelische bzw. R�misch-Katholische Kirche verwendet.
```
USER>write ##class(arsblue.util.Calendar).GetEaster(2019)
20190421
```
Aufgrund der IRIS `$HOROLOG` Implementation kann kein Ostersonntag vor dem Jahr 1841 oder nach dem Jahr 9999 ermittelt werden.

### Feiertage

Mit dieser Methode kann f�r ein Datum ermittelt werden, ob es sich um einen Feiertag handelt oder nicht. Weiters k�nnen mit derselben Methode auch alle Feiertage eines Jahres ermittelt werden. Das im Folgenden gezeigt Beispiel verwendet �sterreich (AT) als L�ndereinstellung.
```
USER>write ##class(arsblue.util.Calendar).GetHoliday(20190214,,,.holidays)
valentines_day
USER>zw holidays
holidays(20190101)=$lb(1,"new_years_day")
holidays(20190106)=$lb(1,"epiphany")
holidays(20190214)=$lb(0,"valentines_day")
holidays(20190304)=$lb(0,"shrove_monday")
holidays(20190305)=$lb(0,"shrove_tuesday")
holidays(20190306)=$lb(0,"ash_wednesday")
holidays(20190319)=$lb("K,ST,T,V","josef_day")
holidays(20190414)=$lb(0,"palm_sunday")
holidays(20190418)=$lb(0,"maundy_thursday")
holidays(20190419)=$lb(0,"good_friday")
holidays(20190421)=$lb(1,"easter_sunday")
holidays(20190422)=$lb(1,"easter_monday")
holidays(20190501)=$lb(1,"labor_day")
holidays(20190504)=$lb("O","florian_day")
holidays(20190530)=$lb(1,"ascension_day")
holidays(20190609)=$lb(1,"whit_sunday")
holidays(20190610)=$lb(1,"whit_monday")
holidays(20190620)=$lb(1,"feast_of_corpus_christi")
holidays(20190815)=$lb(1,"assumption_day")
holidays(20190924)=$lb("S","rupert_day")
holidays(20191010)=$lb("K","popular_vote_day")
holidays(20191026)=$lb(1,"national_holiday")
holidays(20191031)=$lb(0,"halloween")
holidays(20191101)=$lb(1,"all_saints_day")
holidays(20191111)=$lb("B","martin_day")
holidays(20191115)=$lb("N,W","leopold_day")
holidays(20191201)=$lb(0,"1st_sunday_in_advent")
holidays(20191206)=$lb(,"saint_nicholas_day")
holidays(20191208)=$lb(1,"immaculate_conception_day,2nd_sunday_in_advent")
holidays(20191215)=$lb(0,"3th_sunday_in_advent")
holidays(20191222)=$lb(0,"4th_sunday_in_advent")
holidays(20191224)=$lb(.5,"christmas_eve")
holidays(20191225)=$lb(1,"christmas_day")
holidays(20191226)=$lb(1,"boxing_day")
holidays(20191231)=$lb(.5,"new_years_eve")
```
Die Liste aller Festtage wird nur per Referenz �bergeben und enth�lt pro Datum eine IRIS `$LIST` mit der Information ob es sich dabei um einen ganzen (`1`), halben (`.5`) oder keinen (`0`) gesetzlichen Feiertag handelt bzw. ob es sich dabei um einen Feiertag handelt, der nur in gewissen Bundesl�ndern begangen wird (kommaseparierte Liste aller Bundesl�nderk�rzel) und falls zwei Festtage auf dasselbe Datum fallen, werden ihre Kennungen als kommaseparierte Liste angegeben.

Aufgrund der IRIS `$HOROLOG` Implementation k�nnen keine Feiertage vor dem Jahr 1841 und nach dem Jahr 9999 ermittelt werden.

Sollten die Feiertage f�r ein Land ben�tigt werden, dass noch nicht implementiert wurde, so kann dies einfach durch Erstellen einer Klasse `arsblue.util.Calendar.<L�ndercode>` und Erweitern der Klasse `arsblue.util.Calendar` erfolgen. Es muss dabei nur die Methode `GetHoliday(...)` �berschrieben werden.
```
/// Holidays for country XY
Class arsblue.util.Calendar.XY extends arsblue.util.Calendar
{
/// Create holidays for year
/// <ul>
/// <li>yyyy...the year to created holidays for.</li>
/// <li>holidays...the created holidays (by reference).</li>
/// </ul>
ClassMethod CreateHolidays(yyyy as %Integer = 0, ByRef holidays)
{
  // e.g. holiday by law: 1st of January each year
  Set holidays(yyyy_"0101")=$LB(1,"new_years_day")

  // e.g. not a real holiday, but you do not want to forget it
  Set holidays(yyyy_"0214")=$LB(0,"valentines_day")

  // e.g. holiday in just a few states (a, b and c) in country XY
  Set holidays(yyyy_"0301")=$LB("a,b,c","begin_of_spring")

  //... more holidays to define ...
}
}
```
Es sollten immer alle m�glichen Feiertage berechnet werden! Das Zwischenspeichern der Feiertage obliegt der Applikation, die sie implementiert!

## Datum, Zeit und Zeitstempel

Die Klasse `arsblue.util.DateTime` beinhaltet jene Funktionalit�t, die aufgrund der IRIS Spezifikation von Datentypen nicht direkt in diesen untergebracht werden konnte (z.B. sind keine SQL Prozeduren in Datentypen erlaubt, usw.).

### Frei Formattieren

Diese Methode erlaubt es Datum, Zeit oder Zeitstempel frei in ein anderes Format zu bringen.
```
USER>write ##class(arsblue.util.DateTime).Format(20190406213405.123, "yyyyMMddHHmmss.SSS", "EEEE, dd-MM-yyyy/ww HH:mm:ss (SSS)")
Samstag, 06-04-2019/14 21:34:05 (123)
```
Dieselbe Methode kann auch als SQL Prozedur aufgerufen werden.
```
SELECT arsblue_util.DateTime_Format(20190406213405.123, 'yyyyMMddHHmmss.SSS','EEEE, dd-MM-yyyy/ww HH:mm:ss (SSS)')
```

## Betriebssystem Befehle ausf�hren

Die Standard IRIS Implementation bietet bereits eine Reihe von M�glichkeiten, einen Befehl im Betriebssystem auszuf�hren. Die Klasse `arsblue.util.Exec` erweitert diese Funktionalit�ten um die Verarbeitung in IRIS zu vereinfachen.

### Ausgabe und Fehlerausgabe einfangen

In der Standard IRIS Implementation muss sich der Programmierer selbst um das Einfangen der Ausgabe bzw. der Fehlerausgabe k�mmern. Die Ausgabe und Fehlerausgabe k�nnen direkt �ber Datenstr�me abgefragt werden.
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir",,,.out,.err))

USER>do out.OutputToDevice()
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330
 
 Verzeichnis von c:\intersystems\iris\mgr\user
 
01.05.2019  14:30    <DIR>          .
01.05.2019  14:30    <DIR>          ..
12.04.2019  10:27     5 209 325 568 IRIS.DAT
17.04.2019  08:56                46 iris.lck
28.09.2018  16:57    <DIR>          stream
               2 Datei(en),  5 209 325 614 Bytes
               3 Verzeichnis(se), 94 616 862 720 Bytes frei 
USER>do err.OutputToDevice()

USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("unknown_cmd",,,.out,.err))
FEHLER #5001: unknown_cmd returns 1
USER>do out.OutputToDevice()
 
USER>do err.OutputToDevice()
Der Befehl "unknown_cmd" ist entweder falsch geschrieben oder konnte nicht gefunden werden.
```
Die Ausgabe und Fehlerausgabe k�nnen auch im selben Datenstrom eingefangen werden (Beispiel s. Eingabe �bergeben). Die Ausgabe und Fehlerausgabe k�nnen ebenfalls auf dem aktuellen Ger�t ausgegeben werden, indem f�r die Datenstr�me die aktuelle `$IO` Variable �bergeben wird (Beispiel s. Verzeichnis angeben).

### Eingabe �bergeben

In der Standard IRIS Implementation muss sich der Programmierer selbst um die �bergabe der Eingabe k�mmern. Die Eingabe kann direkt �ber einen Datenstrom �bergeben werden.
```
USER>set in=##class(%Stream.TmpCharacter).%New()
 
USER>do in.WriteLine("dir"),in.WriteLine("unknown_cmd")
 
USER>do in.OutputToDevice()
dir
unknown_cmd
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("cmd",,in,.out,.err))
 
USER>do out.OutputToDevice()
Microsoft Windows [Version 10.0.17134.706]
(c) 2018 Microsoft Corporation. Alle Rechte vorbehalten.
 
c:\intersystems\iris\mgr\user>dir
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330
 
 Verzeichnis von c:\intersystems\iris\mgr\user
 
01.05.2019  14:30    <DIR>          .
01.05.2019  14:30    <DIR>          ..
12.04.2019  10:27     5 209 325 568 IRIS.DAT
17.04.2019  08:56                46 iris.lck
28.09.2018  16:57    <DIR>          stream
               2 Datei(en),  5 209 325 614 Bytes
               3 Verzeichnis(se), 94 612 426 752 Bytes frei
 
c:\intersystems\iris\mgr\user>unknown_cmd
 
c:\intersystems\iris\mgr\user>
USER>do err.OutputToDevice()
Der Befehl "unknown_cmd" ist entweder falsch geschrieben oder konnte nicht gefunden werden.
```
Das Beispiel oben zeigt nun, dass die Ausgabe und Fehlerausgabe jeweils f�r sich keinen Aufschluss dar�ber geben, in welcher Reihenfolge diese passiert sind. Es ist sinnvoll, wenn mehrere Ausgaben und Fehlerausgaben erwartet werden, die beiden auf einen Datenstrom zusammenzuf�hren.
```
USER>set in=##class(%Stream.TmpCharacter).%New()
 
USER>do in.WriteLine("dir"),in.WriteLine("unknown_cmd")
 
USER>do in.OutputToDevice()
dir
unknown_cmd
 
USER>set outerr=##class(%Stream.TmpCharacter).%New()
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("cmd",,in,.outerr,.outerr))
 
USER>do outerr.OutputToDevice()
Microsoft Windows [Version 10.0.17134.706]
(c) 2018 Microsoft Corporation. Alle Rechte vorbehalten.
 
c:\intersystems\iris\mgr\user>dir
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330
 
 Verzeichnis von c:\intersystems\iris\mgr\user
 
01.05.2019  14:30    <DIR>          .
01.05.2019  14:30    <DIR>          ..
12.04.2019  10:27     5 209 325 568 IRIS.DAT
17.04.2019  08:56                46 iris.lck
28.09.2018  16:57    <DIR>          stream
               2 Datei(en),  5 209 325 614 Bytes
               3 Verzeichnis(se), 94 607 515 648 Bytes frei
 
c:\intersystems\iris\mgr\user>unknown_cmd
Der Befehl "unknown_cmd" ist entweder falsch geschrieben oder konnte nicht gefunden werden.
``` 

### Verzeichnis angeben

In der Standard IRIS Implementation ist es nicht direkt m�glich, den Befehl in einem Verzeichnis des Betriebssystems auszuf�hren. Das Verzeichnis, in dem der Betriebssystem Befehl ausgef�hrt werden soll, kann angegeben werden.
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir","C:\InterSystems\IRIS\mgr\stream",,$IO,$IO))
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330
 
 Verzeichnis von C:\InterSystems\IRIS\mgr\stream
 
28.09.2018  16:57    <DIR>          .
28.09.2018  16:57    <DIR>          ..
               0 Datei(en),              0 Bytes
               2 Verzeichnis(se), 94 609 014 784 Bytes frei
```

### R�ckruf verwenden

In der Standard IRIS Implementation ist es nicht direkt m�glich, eine Funktion anzugeben, die nach dem Betriebssystem Befehl ausgef�hrt werden soll. Der Unterschied zum Bearbeiten in der Aufrufenden Funktion, ist der direkte Zugriff auf die beim Aufruf verwendeten Parameter.

**_Callback Definition:_**
```
Class User.TestCallback [ Abstract ]
{
ClassMethod ExecCallback(params...)
{
  // kill process callback information
  kill ^callback(%pid)
  
  // copy all process parameters
  set ^callback(%pid,$I(^callback(%pid)))="PARAMS:"
  merge ^callback(%pid,$I(^callback(%pid)))=params
  
  // save process output
  set ^callback(%pid,$I(^callback(%pid)))="STDOUT:"
  do %out.Rewind()
  while ('%out.AtEnd)
  {
    set ^callback(%pid,$I(^callback(%pid)))=%out.ReadLine()
  }
  
  // save process error
  set ^callback(%pid,$I(^callback(%pid)))="STDERR:"
  do %err.Rewind()
  while ('%err.AtEnd)
  {
    set ^callback(%pid,$I(^callback(%pid)))=%err.ReadLine()
  }
}
}
```

**_Callback Beispiel:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir",,,,,,.pid,"User.TestCallback.ExecCallback","A","B","C",1,2,3))
 
USER>zw ^callback(pid)
^callback(21408)=17
^callback(21408,1)="PARAMS:"
^callback(21408,2)=6
^callback(21408,2,1)="A"
^callback(21408,2,2)="B"
^callback(21408,2,3)="C"
^callback(21408,2,4)=1
^callback(21408,2,5)=2
^callback(21408,2,6)=3
^callback(21408,3)="STDOUT:"
^callback(21408,4)=" Volume in Laufwerk C: hat keine Bezeichnung."
^callback(21408,5)=" Volumeseriennummer: F0D2-A330"
^callback(21408,6)=""
^callback(21408,7)=" Verzeichnis von c:\intersystems\iris\mgr\user"
^callback(21408,8)=""
^callback(21408,9)="01.05.2019  14:30    <DIR>          ."
^callback(21408,10)="01.05.2019  14:30    <DIR>          .."
^callback(21408,11)="12.04.2019  10:27     5 209 325 568 IRIS.DAT"
^callback(21408,12)="17.04.2019  08:56                46 iris.lck"
^callback(21408,13)="28.09.2018  16:57    <DIR>          stream"
^callback(21408,14)="               2 Datei(en),  5 209 325 614 Bytes"
^callback(21408,15)="               3 Verzeichnis(se), 94 259 175 424 Bytes frei"
^callback(21408,16)="STDERR:"
^callback(21408,17)=""
```

### Befehl asynchron ausf�hren

In der Standard IRIS Implementation ist es nicht direkt m�glich, den Status eines Betriebssystem Befehls, der im Hintergrund (separater Prozess) ausgef�hrt wird, abzufragen. Die Prozess Nummer kann direkt abgefragt werden.
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir /S /B >NUL","C:\InterSystems\IRIS",,,,1,.pid)),!,"pid=",pid
 
pid=28636
USER>while (##class(arsblue.util.Exec).IsProcessRunning(pid)) { write "." } write "finished"
......finished
```

### Befehl asynchron ausf�hren mit R�ckruf

In der Standard IRIS Implementation ist es nicht direkt m�glich, auf einen Betriebssystem Befehl zu reagieren, der im Hintergrund ausgef�hrt wird. �ber die R�ckruf Funktion ist es m�glich, in IRIS Befehle auszuf�hren, nachdem der Betriebssystem Befehl im Hintergrund abgeschlossen wurde.
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir",,,,,1,.pid,"User.TestCallback.ExecCallback","A","B","C",1,2,3))
 
USER>zw ^callback(pid)
^callback(1832)=17
^callback(1832,1)="PARAMS:"
^callback(1832,2)=6
^callback(1832,2,1)="A"
^callback(1832,2,2)="B"
^callback(1832,2,3)="C"
^callback(1832,2,4)=1
^callback(1832,2,5)=2
^callback(1832,2,6)=3
^callback(1832,3)="STDOUT:"
^callback(1832,4)=" Volume in Laufwerk C: hat keine Bezeichnung."
^callback(1832,5)=" Volumeseriennummer: F0D2-A330"
^callback(1832,6)=""
^callback(1832,7)=" Verzeichnis von c:\intersystems\iris\mgr\user"
^callback(1832,8)=""
^callback(1832,9)="01.05.2019  14:30    <DIR>          ."
^callback(1832,10)="01.05.2019  14:30    <DIR>          .."
^callback(1832,11)="12.04.2019  10:27     5 209 325 568 IRIS.DAT"
^callback(1832,12)="17.04.2019  08:56                46 iris.lck"
^callback(1832,13)="28.09.2018  16:57    <DIR>          stream"
^callback(1832,14)="               2 Datei(en),  5 209 325 614 Bytes"
^callback(1832,15)="               3 Verzeichnis(se), 94 599 979 008 Bytes frei"
^callback(1832,16)="STDERR:"
^callback(1832,17)=""
```

## JSON Hilfsprogramme

In der Standard IRIS JSON Implementation sind bereits viele Funktionen vorhanden. Die hier beschriebenen Funktionen kombinieren einige der Funktionen bzw. erweitern sie f�r einen verbesserten Umgang mit JSON Objekten. Zum einen stehen die Funktionen der Klasse `arsblue.util.Json` zur Verf�gung und zum anderen gibt es das entsprechende Makro `arsblue.util.Json` um die wichtigsten Funktionen der Klasse in gek�rzter Schreibweise im Quellcode verwenden zu k�nnen. Im Folgenden werden die Funktionen immer mit dem �quivalenten Makro (sofern vorhanden) beschrieben. 

### JSON Makro in Quellcode einbinden

Um das Makro im eigenen Quellcode verwenden zu k�nnen, ist es notwendig es in der ersten Zeile der Klasse einzubinden.
```
Include (arsblue.util.Json)

/// my class
Class my.Class {
  ...
}
```

### JSON Index Suche nach Wert

**_Syntax:_**
```
 ##class(arsblue.util.Json).IndexOf(<JSON-Array-Oder-Objekt>,<Wert>[,<Start-Index>])
```

**_Makro:_**
```
$$$JSON.IndexOf(<JSON-Array-Oder-Objekt>,<Wert>[,<Start-Index>])
```

Die Suche liefert Default den Index an dem der Wert als erstes vorkommt. �ber den optionalen Parameter `Start-Index` kann nach den weiteren Vorkommen gesucht werden. Wird kein Index f�r einen Wert gefunden, wird eine leere Zeichenkette zur�ckgeliefert.

**_JSON Array:_**
```
USER>set array=["a","b","a","c","a","d"]
 
USER>write ##class(arsblue.util.Json).IndexOf(array,"a")
0
USER>write ##class(arsblue.util.Json).IndexOf(array,"a",0)
2
USER>write ##class(arsblue.util.Json).IndexOf(array,"a",2)
4
USER>write ##class(arsblue.util.Json).IndexOf(array,"a",4)

```

**_JSON Objekt:_**
```
USER>set object={"key0":"a","key1":"b","key2":"a","key3":"c","key4":"a","key5":"d"}
 
USER>write ##class(arsblue.util.Json).IndexOf(object,"a")
key0
USER>write ##class(arsblue.util.Json).IndexOf(object,"a","key0")
key2
USER>write ##class(arsblue.util.Json).IndexOf(object,"a","key2")
key4
USER>write ##class(arsblue.util.Json).IndexOf(object,"a","key4")

```

### JSON Arrays bzw. Objekte kopieren

**_Syntax:_**
```
 ##class(arsblue.util.Json).Copy(<JSON-Quell-Array-Oder-Objekt>,<JSON-Ziel-Array-Oder-Objekt>[,<Bedingung>])
```

**_Makro:_**
```
$$$JSON.Copy(<JSON-Quell-Array-Oder-Objekt>,<JSON-Ziel-Array-Oder-Objekt>[,<Bedingung>])
```
 
Mit dieser Funktion k�nnen JSON Arrays bzw. Objekte kopiert bzw. verbunden werden. Wird ein leeres Ziel Array bzw. Objekt angegeben, handelt es sich um eine reine Kopierfunktion. Wird ein nicht leeres Ziel Array bzw. Objekt angegeben, werden die Daten im Zeil mit den Daten der Quelle verbunden. Die Art und Weise, wie die Daten verbunden werden, kann �ber die Bedingung angegeben werden.

| Bedingung | Beschreibung |
| --- | --- |
| **0** (Default) | Kopiert alle Daten der Quelle und �berschreibt ggf. die Daten im Ziel. |
| **1** | Kopiert nur jene Daten der Quelle, die im Ziel nicht vorhanden sind. |
| **2** | Kopiert nur jene Daten der Quelle, die im Ziel vorhanden sind und �berschreibt diese. |

#### JSON kopieren

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target=""
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target))
 
USER>write target.%ToJSON()
{"array":[1,2,3],"object":{"a":"b","c":"d"}}
```
Bei dieser Bedingung wird eine Tiefe-Kopie erstellt. Der Vorteil gegen�ber der von IRIS vorgeschlagenen Variante (`set target={}.%FromJson(source.%ToJson())`) ist, dass Objektreferenzen kopiert werden, welche im IRIS Standardfall nicht nach JSON exportiert und damit auch nicht mehr von JSON importiert werden k�nnen.

#### JSON kopieren mit �berschreiben der Zieldaten

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,0))
 
USER>write target.%ToJSON()
{"array":[1,2,3],"object":{"a":"b","b":"z","c":"d"}}
```
Bei dieser Bedingung werden JSON Arrays vollst�ndig ersetzt, in JSON Objekte werden die Daten nur �berschrieben.

#### JSON kopieren von nicht vorhandenen Daten

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,1))
 
USER>write target.%ToJSON()
{"array":[3,4,5,1,2],"object":{"a":"x","b":"z","c":"d"}}
```
Bei dieser Bedingung werden nicht vorhandene Werte in JSON Arrays am Ende hinzugef�gt, in JSON Objekten werden nur nicht vorhandene Daten eingef�gt.

#### JSON kopieren von vorhandenen Daten

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,2))
 
USER>write target.%ToJSON()
{"array":[3,4,5],"object":{"a":"b","b":"z"}}
```
Bei dieser Bedingung bleiben JSON Arrays unber�hrt, in JSON Objekten werden nur vorhandene Daten �berschrieben.

### JSON Arrays bzw. Objekte auf Gleichheit pr�fen

**_Syntax:_**
```
 ##class(arsblue.util.Json).Equals(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```

**_Makro:_**
```
$$$JSON.Equals(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```
 
Mit dieser Funktion k�nnen JSON Arrays bzw. Objekte auf Gleichheit gepr�ft werden.
```
USER>set json1={"a":[{"b":"c"},1,2,3]},json2={"a":[{"b":"c"},1,2,3]}
 
USER>write ##class(arsblue.util.Json).Equals(json1,json2)
1
USER>set json1={"a":[{"b":"c"},1,2,3]},json2={"a":[{"b":"c","d":"e"},1,2,3]}
 
USER>write ##class(arsblue.util.Json).Equals(json1,json2)
0
USER>set json1={"a":[{"b":"c"},1,2,3,4,5]},json2={"a":[{"b":"c"},1,2,3]}
 
USER>write ##class(arsblue.util.Json).Equals(json1,json2)
0
```
Es werden alle Ebenen der beiden JSON Arrays bzw. Objekte verglichen. Der Vorteil gegen�ber der von IRIS vorgeschlagenen Variante (`set equals=(json1.%ToJSON()=json2.%ToJSON())`) ist, dass Objektreferenzen verglichen werden, welche im IRIS Standardfall nicht nach JSON exportiert und damit auch nicht verglichen werden k�nnen. Des Weiteren wird im IRIS JSON Export die Reihenfolge der Anlage der Werte ber�cksichtigt, womit es nicht m�glich ist, zu pr�fen, ob ein JSON Objekt (bei dem es nur auf den Inhalt und nicht auf die Reihenfolge - wie beim JSON Array - ankommt) wirklich gleich ist.
```
USER>set json1={"a":"b","c":"d"},json2={"c":"d","a":"b"}
 
USER>write json1.%ToJSON(),!,json2.%ToJSON()
{"a":"b","c":"d"}
{"c":"d","a":"b"}
USER>write json1.%ToJSON()=json2.%ToJSON()
0
USER>write ##class(arsblue.util.Json).Equals(json1,json2)
1
```

### JSON Arrays bzw. Objekte vergleichen

**_Syntax:_**
```
 ##class(arsblue.util.Json).Diff(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```

**_Makro:_**
```
$$$JSON.Diff(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```
 
Mit dieser Funktion k�nnen JSON Arrays bzw. Objekte miteinander verglichen werden.
```
USER>set json1={"a":"b","c":["d","e","f"]},json2={"c":["d","e","f"],"a":"b"}
 
USER>write ##class(arsblue.util.Json).Diff(json1,json2)
 
USER>set json1={"a":"b","c":["d","E","f"]},json2={"c":["d","e","f"],"a":"B"}
 
USER>write ##class(arsblue.util.Json).Diff(json1,json2).%ToJSON()
{"a":["b","B"],"c":[null,["E","e"]]}
```
Es werden alle Ebenen der beiden JSON Arrays bzw. Objekte verglichen. Wird kein JSON Array bzw. Objekt zur�ckgeliefert, sind die beiden JSON Arrays bzw. Objekte ident, andernfalls werden im zur�ckgelieferten JSON Array bzw. Objekt jene Werte als JSON Array (`[<Wert-1>,<Wert-2>]`) aufgelistet, die sich ge�ndert haben (in einem JSON Array bedeutet `null`, dass sich der Wert an diesem Index nicht ge�ndert hat, aber es einen Index dahinter gibt, der eine �nderung beinhaltet).

### Datenobjekte nach JSON exportieren

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromObject(<Objektreferenz>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>][,<Transiente-Daten-exportieren>])
 ##class(arsblue.util.Json).GetJSONFromExtent(<Objekt-ID>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>])
```

**_Makro:_**
```
$$$JSON.GetJSONFromObject(<Objektreferenz>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>][,<Transiente-Daten-exportieren>])
$$$JSON.GetJSONFromExtent(<Objekt-ID>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>])
```

Mit diesen Funktionen k�nnen Datenobjekte nach JSON exportiert werden. Der Unterschied zwischen den beiden Methoden ist, dass die Methode `GetJSONFromObject` mit den geladenen Objektreferenzen im Speicher arbeitet, wohingegen `GetJSONFromExtent` mit den Daten in den jeweiligen Objektglobal arbeitet. Die IRIS Architektur ist dahingehend ausgelegt, dass ein Datenobjekt nur einmal geladen wird, d.h. egal wie oft ich ein Objekt mit derselben Objekt-ID lade, im Speicher verweist es immer auf dieselbe Objektreferenz (mit all ihren bereits durchgef�hrten �nderungen). Dies ist manchmal nicht erw�nscht, und die Applikation m�chte wissen, was den nun tats�chlich noch im Objektglobal steht bzw. welche �nderungen bereits im Objektglobal verf�gbar sind, daf�r wurde die M�glichkeit geschaffen, diese Daten als JSON direkt vom Extent einzulesen.
Mit der Methode `GetJSONFromObject` k�nnen alle im Speicher befindlichen Objektreferenzen nach JSON exportiert werden. Es ist nicht zwingend notwendig, dass es sich dabei um persistierbare Daten handelt, sondern nur, dass sie von `%Library.RegisteredObject` abgeleitet wurden.
Der Entwickler kann sich entscheiden, ob er alle Daten exportieren will oder nur die "Kopf"-Daten (also Klasse, ID und wenn vorhanden GUID).
Der Entwickler kann sich entscheiden, ob er alle Daten ausser den "Kopf"-Daten exportieren will. Diese Option ist vor allem daf�r interessant, wenn man mit Fremdsystemen kommunizieren muss, die nicht unbedingt �ber interne Klassennamen und ID's Bescheid wissen sollen.
Der Entwickler kann sich entscheiden, ob er auch transiente Daten exportieren will. Diese Option steht nat�rlich nicht f�r `GetJSONFromExtent` zur Verf�gung, da hier nur Nicht-transiente Daten exportiert werden k�nnen.

### Datenobjekte von JSON importieren

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetObjectFromJSON(<JSON-Objekt>,<Importierte-Objektreferenz>[,<Alle-Daten-importieren>][,<ID/GUID-nicht-importieren>][,<Transiente-Daten-importieren>])
```

**_Makro:_**
```
$$$JSON.GetObjectFromJSON(<JSON-Objekt>,<Importierte-Objektreferenz>[,<Alle-Daten-importieren>][,<ID/GUID-nicht-importieren>][,<Transiente-Daten-importieren>])
```

Mit dieser Funktion k�nnen Datenobjekte von JSON importiert werden. Dabei werden die Objektreferenzen geladen (falls Datenobjekte) und entsprechend ver�ndert aber nicht gespeichert (falls Datenobjekte). Das Speicher der Datenobjekte obliegt dem Entwickler. Es k�nnen prinzipiell alle von `%Library.RegisteredObject` abgeleiteten Klassen importiert werden.
Der Entwickler kann sich entscheiden, ob er alle Daten importieren will oder nur die "Kopf"-Daten (also Klasse, ID und wenn vorhanden GUID). Dies entspricht einer Verf�gbarkeitspr�fung, da nur kontrolliert werden kann, ob sich ein Datenobjekt mit den gegebenen "Kopf"-Daten laden l��t.
Der Entwickler kann sich entscheiden, ob er alle Daten ausser den "Kopf"-Daten importieren will. Diese Option ist vor allem daf�r interessant, wenn man Kopien von Daten erstellen muss, d.h. ein Export mit darauffolgendem Import ohne "Kopf"-Daten erzeugt eine Kopie der exportierten Daten (sofern mit automatischen IDs gearbeitet wird).
Der Entwickler kann sich entscheiden, ob er auch transiente Daten importieren will.

### JSON und `$LIST`

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromList(<$LIST>)
 ##class(arsblue.util.Json).GetListFromJSON(<JSON-Array>)
```

**_Makro:_**
```
$$$JSON.GetJSONFromList(<$LIST>)
$$$JSON.GetListFromJSON(<JSON-Array>)
```

Mit diesen Funktionen kann aus einer `$LIST` ein JSON Array bzw. aus einem JSON Array eine `$LIST` erzeugt werden.
```
USER>set list=$LISTBUILD("a","b","c",$LISTBUILD(1,2,3))
 
USER>write ##class(arsblue.util.Json).GetJSONFromList(list).%ToJSON()
["a","b","c",[1,2,3]]

USER>set json=["a","b","c",[1,2,3]]
 
USER>zwrite ##class(arsblue.util.Json).GetListFromJSON(json)
$lb("a","b","c",$lb(1,2,3))
```

### JSON und `%Library.Status`

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromStatus(<Status>)
 ##class(arsblue.util.Json).GetStatusFromJSON(<JSON-Objekt>)
```

**_Makro:_**
```
$$$JSON.GetJSONFromStatus(<Status>)
$$$JSON.GetStatusFromJSON(<JSON-Objekt>)
```

Mit diesen Funktionen kann aus einem `%Library.Status` ein JSON Objekt bzw. aus einem JSON Objekt ein `%Library.Status` erzeugt werden.
```
USER>set status=$System.Status.Error(5001,"This is an error!")
 
USER>write ##class(arsblue.util.Json).GetJSONFromStatus(status).%ToJSON()
{"_ClassName":"%Library.Status","_Status":[[5001,"This is an error!",null,null,null,null,null,null,null,[null,"USER",["e^zError+1^%SYSTEM.Status.1^1","e^^^0"]]]]}
USER>set json={"_ClassName":"%Library.Status","_Status":[[5001,"This is an error!",null,null,null,null,null,null,null,[null,"USER",["e^zError+1^%SYSTEM.Status.1^1","e^^^0"]]]]}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).GetStatusFromJSON(json))
FEHLER #5001: This is an error!
```

### JSON lesen

**_Syntax:_**
```
 ##class(arsblue.util.Json).%FromJSON(<Zeichenkette-Oder-Datenstrom>)
```

**_Makro:_**
```
$$$JSON.%FromJSON(<Zeichenkette-Oder-Datenstrom>)
```

Mit dieser Funktion kann JSON aus einer Zeichenkette bzw. einem Datenstrom gelesen werden. Der Unterschied zur Standard IRIS Implementation ist, dass sowohl strikte als auch nicht strikte JSON Syntax (Objektschl�sselw�rter mit oder ohne Hochkommas), einzeilige wie auch mehrzeilige Kommentare und JavaScript-Funktionen (werden als Datenstrom-Objekte gespeichert) erlaubt sind. Die Einschr�nkung dabei ist, dass die Objekt-Schl�sselw�rter immer am Anfang einer neuen Zeile (Leerzeichen und Tabulatoren werden dabei ignoriert) stehen m�ssen.

### JSON schreiben

**_Syntax:_**
```
 ##class(arsblue.util.Json).%ToJSON(<JSON-Array-Oder-Objekt>,<Ausgabedatenstrom-Objektreferenz>[,<Einr�ckungszeichen>][,<Einr�ckungsebene>])
```

**_Makro:_**
```
$$$JSON.%ToJSON(<JSON-Array-Oder-Objekt>,<Ausgabedatenstrom-Objektreferenz>[,<Einr�ckungszeichen>][,<Einr�ckungsebene>])
```

Mit dieser Funktion kann JSON in einen Ausgabedatenstrom geschrieben werden. Die Ausgabe wird dabei automatisch formatiert. Die Formatierung kann mit den Zusatzparametern angepasst werden. Die Standard IRIS Implementation (`%ZEN.Auxiliary.jsonProvider`) wei�t bei manchen Datentypen leider eine falsche bzw. unvollst�ndige Implementation auf.
```
USER>set json={"a":"b","c":[1,2,3]}
 
USER>do ##class(arsblue.util.Json).%ToJSON(json)
{
    "a": "b",
    "c": [
        1,
        2,
        3
    ]
}
```