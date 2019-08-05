# ARSBlue ToolBox-4-Iris -- Data Types

- [Datum, Zeit und Zeitstempel](#datum-zeit-und-zeitstempel)
  - [Formatierung](#formatierung)
  - [Speicherbedarf](#speicherbedarf)
  - [SQL und Performance](#sql-und-performance)
  - [Migration von IRIS Standard Datentypen](#migration-von-iris-standard-datentypen)
  - [Aktuelles Datum für Klassenattribute](#aktuelles-datum-f%C3%BCr-klassenattribute)

## Datum, Zeit und Zeitstempel

Die Standard InterSystems IRIS Datentypen umfassen eine große Auswahl an mehr oder weniger flexiblen Datum, Zeit und Zeitstempel Datentypen. Die im folgenden beschriebenen Datentypen sind hoch dynamisch und benötigen im Gegensatz zu den meisten InterSystems IRIS Datentypen  wesentlich weniger Speicher.

### Formatierung

Alle beschriebenen Datum-, Zeit- und Zeitstempel-Datentypen sind vorkonfiguriert, können aber an jedes beliebige Format angepasst werden. Es können folgende Formate verwendet werden:

| Muster Charakter | Beschreibung |
| --- | --- |
| **y** <br/> (Jahr) | **yy**: Jahr im aktuellen Jahrhundert (z.B. 19 => 2019) <br/> **yyyy**: vollwertiges Jahr (z.B. 2019) |
| **M** <br/> (Monat im Jahr) | **M**: Monat als ein- bzw. zweistellige Zahl (z.B. 1 – 12) <br/> **MM**: Monat als zweistellige Zahl mit Vornullen (z.B. 01 – 12) <br/> **MMM**: abgekürzter Monatsname mit NLS (z.B. Jan, Feb, Mar, ...) <br/> **MMMM**: Monatsname mit NLS (z.B. Januar, Februar, März, ...) |
| **d** <br/> (Tag im Monat) | **d**: Tag als ein bzw. zweistellige Zahl (z.B. 1 – 31) <br/> **dd**: Tag als zweistellige Zahl mit Vornullen (z.B. 01 – 31) |
| **w** <br/> (Woche im Jahr) | **w**: Woche als ein bzw. zweistellige Zahl (z.B. 1 – 53) <br/> **ww**: Woche als zweistellige Zahl mit Vornullen (z.B. 01 – 53) |
| **E** <br/> (Name des Wochentags) | **E**: einstelliger Wochentagname mit NLS (z.B. M, D, M, ...) <br/> **EE**: zweistelliger Wochentagname mit NLS (z.B. Mo, Di, Mi, ...) <br/> **EEE**: Abgekürzter Wochentagname mit NLS (z.B. Mon, Die, Mit, ...) <br/> **EEEE**: Wochentagname mit NLS (z.B. Montag, Dienstag, ...) |
| **u** <br/> (Tag in der Woche) | **u**: Tag in der Woche (z.B. 1 – 7 für Montag – Sonntag) |
| **H** <br/> (Stunde am Tag) | **H**: Stunde als einstellige Zahl (z.B. 0 – 24) <br/> **HH**: Stunde als zweistellige Zahl mit Vornullen (z.B. 00 – 24) |
| **m** <br/> (Minute in Stunde) | **m**: Minute als einstellige Zahl (z.B. 0 – 59) <br/> **mm**: Minute als zweistellige Zahl mit Vornullen (z.B. 00 – 59) |
| **s** <br/> (Sekunde in Minute) | **s**: Sekunde als einstellige Zahl (z.B. 0 – 59) <br/> **ss**: Sekunde als zweistellige Zahl mit Vornullen (z.B. 00 – 59) |
| **S** <br/> (Teile einer Sekunde) | **S**: Zehntel einer Sekunde <br/> **SS**: Hundertstel einer Sekunde <br/> **SSS**: Tausendstel einer Sekunde = Millisekunde (Standard für `$ZTS`) <br/> **SSSS**: Zehntausendstel einer Sekunde = Microsekunde |
| [**$H**[**D**\|**T**]\|**$ZTS**] <br/> (InterSystems IRIS Horolog) | **$H**: entspricht `$HOROLOG` in IRIS <br/> **$HD**: entspricht dem Datumsanteil von `$HOROLOG` <br/> **$HT**: entspricht dem Zeitanteil von `$HOROLOG` <br/> **$ZTS**: entspricht `$ZTIMESTAMP` in InterSystems IRIS |

Die im Folgenden beschriebenen Datum-, Zeit- und Zeitstempel-Datentypen wurden mittels dieser Formatierungskriterien spezifiziert. Jeder der Datentypen kann daher über die Angabe der entsprechenden Parameter in der Definition der Eigenschaften an die individuellen Bedürfnisse angepasst werden. Ein Beispiel für einen solchen Fall ist der Datentyp `arsblue.datatype.YearWeek`, welcher für statistische Zwecke benutzt werden kann. 

In der ODBC, XSD bzw. JSON Repräsentation wird der erste Tag (Montag) der entsprechenden Woche herangezogen (ausgenommen beim Jahreswechsel wird der erste Tag im Jahr genommen, um etwaige Selektionskriterien nicht zu verletzen).

Dies gilt ebenso für ODBC und XSD Formate, welche auf den für die jeweilige Implementation als Standard definierten Wert spezifiziert wurden.
Zusätzlich werden für JSON und JavaScript weitere Formate spezifiziert. Für JSON gibt es die jeweilige Methode für die Konvertierung ins und vom logischen Format. Für JavaScript wurde das Format lediglich spezifiziert und es wird auch nicht auf Syntax und Semantik geprüft.

| Datentyp | Logisches Format | Display Format (je nach NLS) | ODBC Format | XSD Format | JSON Format | JavaScript Format |
| --- | --- | --- | --- | --- | --- | --- |
| `arsblue.datatype.Date` | yyyyMMdd | dd/MM/yyyy <br/> MM/dd/yyyy | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.DateTime` | yyyyMMddHHmmss | dd/MM/yyyy HH:mm:ss <br/> MM/dd/yyyy HH:mm:ss | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.Time` | HHmmss | HH:mm:ss | HH:mm:ss | HH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.TimeStamp` | yyyyMMddHHmmss.SSS | dd/MM/yyyy HH:mm:ss.SSS <br/> MM/dd/yyyy HH:mm:ss.SSS | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss.SSS | Y-m-d\TH:i:s.u |
| `arsblue.datatype.YearWeek` | yyyyww | yyyy/ww | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |

### Speicherbedarf

Einer der großen Vorteile dieser Datentypen liegt im Umstand, dass sie als Dezimalzahlen in InterSystems IRIS gehandhabt bzw. gespeichert werden. In der folgenden Tabelle wird der Unterschied zwischen den Standard InterSystems IRIS Datentypen und den ars-blue Datentypen aufgezeigt. Der angegebene Speicherbedarf in Bytes entspricht nur dem Inhalt des jeweiligen Datentyps, tatsächlich werden pro Attribut zwei zusätzliche Byte benötigt (wegen `$LISTBUILD`): Anzahl der Bytes für dieses Attribut und Datentyp des Attributes.

| ars-blue Datentyp | Bytes | IRIS Datentyp | Bytes |
| --- | --- | --- | --- |
| `arsblue.datatype.Date` | 4 | `%Library.Date` | 0 – 3 |
| `arsblue.datatype.DateTime` | 6 | `%Library.DateTime` | 19 |
| `arsblue.datatype.Time` | 0 – 3 | `%Library.Time` | 0 – 3 |
| `arsblue.datatype.TimeStamp` | 9 | `%Library.TimeStamp` | 19 |
| `arsblue.datatype.YearWeek` | 3 | - | - |

Da InterSystems IRIS nur den absolut notwendigen Speicher für Dezimalwerte belegt, können Datum und Zeit im angegebenen Bereich variieren. Der geringe Speicherbedarf wird durch Verwendung von Dezimalwerten für die Implementation erreicht. Aus diesem Grund gibt es folgende Einschränkungen:

- Minimaler Zeitstempel wegen InterSystems IRIS `$HOROLOG` Implementation: **1840/12/31 00:00:00.0**
- Maximaler Zeitstempel wegen InterSystems IRIS `$HOROLOG` Implementation: **9999/12/31 23:59:59.9999**

Durch die Abhängigkeit zur InterSystems IRIS `$HOROLOG` und Dezimalwert Implementation ist es leider nicht möglich ein Datum außerhalb der oben genannten Grenzen zu erfassen.

### SQL und Performance

Ein weiterer Vorteil der ars-blue Datentypen zeigt sich in SQL Abfragen. Im Gegensatz zu den Standard InterSystems IRIS Datentypen sind die arsblue Datentypen in einem menschlich lesbaren und sortierbaren Format. Man kann dadurch im logischen Format statt im Anzeigeformat Abfragen durchführen und erspart sich das Umrechnen von Datum und Zeit von und auf InterSystems IRIS `$HOROLOG`. Ebenso ist das Datum/Zeit Format wie auch der Zeitstempel bereits in einem Format, mit dem man einfach ohne Konvertierung Zeiträume abfragen kann.

Eine korrekte SQL Abfrage für einen Datumsbereich mit separatem Datum und Zeit Attribut kann mit Standard InterSystems IRIS Datum und Zeit Datentypen nur durch komplexe Umformung der beiden Attribute zu einem Datum/Zeit Attribut erfolgen. Dasselbe Problem kann mit arsblue Datum und Zeit Attributen hingegen sehr einfach gelöst werden, z.B. durch Verkettung der beiden Attribute oder durch Multiplikation und Addition der beiden Attribute:
```
SELECT (Date || $EXTRACT(1000000 + Time,2,7)) AS DateTime
  FROM MyClassWithDateAndTime
  WHERE ((Date * 1000000) + Time) BETWEEN ? AND ?
```
Trotz der nicht-nativen Implementation der arsblue Datum-, Zeit- und Zeitstempel Datentypen und der daraus resultierenden Vorteile (Speicher, Lesbarkeit), ist bei der Performance der SQL Abfragen im Logischen Modus kein Unterschied feststellbar und im Anzeigemodus eine nicht signifikante Verschlechterung durch die nicht-native Implementation in ObjectScript bemerkbar (variiert je nach SQL Abfrage und OS des DBMS).

### Migration von InterSystems IRIS Standard Datentypen

Um bestehende Standard InterSystems IRIS Datum-, Zeit- und Zeitstempel Datentypen durch arsblue Datum-, Zeit- und Zeitstempel Datentypen zu ersetzen, ohne dabei die Datensätze migrieren zu müssen, ist dies einfach möglich, indem man den jeweiligen Datentyp verwendet und im logischen Format das Format des originalen Datentyps definiert.
```
Class SomeClass Extends %Persistent
{
  /// migrate %Library.Date
  Property SomeDate As arsblue.datatype.Date (LOGICALFORMAT="$HD")

  /// migrate %Library.Time
  Property SomeTime As arsblue.datatype.Time (LOGICALFORMAT="$HT")

  /// migrate %Library.DateTime
  Property SomeDateTime As arsblue.datatype.DateTime (LOGICALFORMAT="yyyy-MM-dd HH:mm:ss")

  /// migrate %Library.TimeStamp
  Property SomeTimeStamp As arsblue.datatype.TimeStamp (LOGICALFORMAT="yyyy-MM-dd HH:mm:ss")
}
```
Dies behebt nicht den erhöhten Speicherbedarf, wofür eine tatsächliche Migration der Datensätze notwendig wäre, aber liefert den Vorteil flexible Ausgabeformate definieren zu können.

### Aktuelles Datum für Klassenattribute

Das aktuelle Datum eines Klassenattributs im logischen Format kann über den Namen des Attributs ermittelt werden.
```
USER>write ##class(SomeClass).SomeDateNow()
20190416
USER>write ##class(SomeClass).SomeTimeNow()
095413
USER>write ##class(SomeClass).SomeDateTimeNow()
20190416095445
USER>write ##class(SomeClass).SomeTimeStampNow()
20190416095549.605
USER>write ##class(SomeClass).SomeYearWeekNow()
201916
```
Es wird das Datum und die Zeit der aktuell eingestellten Zeitzone unter Berücksichtigung der Sommerzeit verwendet.
