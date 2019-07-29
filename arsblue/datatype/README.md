# ARSBlue IRIS datatypes

## Datentypen

IRIS beinhaltet ein gro�es Angebot an Datentypen. Die in diesem Abschnitt beschriebene Funktionalit�t ist nicht in IRIS vorhanden, erleichtert aber die Entwicklung von Applikationen.

### Datum, Zeit und Zeitstempel

Die Standard IRIS Datentypen umfassen eine gro�e Auswahl an mehr oder weniger flexiblen Datum, Zeit und Zeitstempel Datentypen. Die im folgenden beschriebenen Datentypen sind hoch dynamisch und bieten im Gegensatz zu den meisten IRIS Datentypen den Vorteil wesentlich weniger Speicher zu ben�tigen.

#### Formatierung

Alle beschriebenen Datum-, Zeit- und Zeitstempel-Datentypen sind vorkonfiguriert, k�nnen aber an jedes beliebige Format angepasst werden. Es k�nnen folgende Formate verwendet werden:
| Muster | Charakter | Beschreibung
| --- | --- | --- |
| **y** <br/> (Jahr) | **yy**: Jahr im aktuellen Jahrhundert (z.B. 19 => 2019) <br/> **yyyy**: vollwertiges Jahr (z.B. 2019) |
| **M** <br/> (Monat im Jahr) | **M**: Monat als ein bzw. zweistellige Zahl (z.B. 1 � 12) <br/> **MM**: Monat als zweistellige Zahl mit Vornullen (z.B. 01 � 12) <br/> **MMM**: Abgek�rzter Monatsname mit NLS (z.B. Jan, Feb, Mar, ...) <br/> **MMMM**: Monatsname mit NLS (z.B. Januar, Februar, M�rz, ...) |
| **d** <br/> (Tag im Monat) | **d**: Tag als ein bzw. zweistellige Zahl (z.B. 1 � 31) <br/> **dd**: Tag als zweistellige Zahl mit Vornullen (z.B. 01 � 31) |
| **w** <br/> (Woche im Jahr) | **w**: Woche als ein bzw. zweistellige Zahl (z.B. 1 � 53) <br/> **ww**: Woche als zweistellige Zahl mit Vornullen (z.B. 01 � 53) |
| **E** <br/> (Name des Wochentags) | **E**: einstelliger Wochentagname mit NLS (z.B. M, D, M, ...) <br/> **EE**: zweistelliger Wochentagname mit NLS (z.B. Mo, Di, Mi, ...) <br/> **EEE**: Abgek�rzter Wochentagname mit NLS (z.B. Mon, Die, Mit, ...) <br/> **EEEE**: Wochentagname mit NLS (z.B. Montag, Dienstag, ...) |
| **u** <br/> (Tag in der Woche) | **u**: Tag in der Woche (z.B. 1 � 7 f�r Montag � Sonntag) |
| **H** <br/> (Stunde am Tag) | **H**: Stunde als einstellige Zahl (z.B. 0 � 24) <br/> **HH**: Stunde als zweistellige Zahl mit Vornullen (z.B. 00 � 24) |
| **m** <br/> (Minute in Stunde) | **m**: Minute als einstellige Zahl (z.B. 0 � 59) <br/> **mm**: Minute als zweistellige Zahl mit Vornullen (z.B. 00 � 59) |
| **s** <br/> (Sekunde in Minute) | **s**: Sekunde als einstellige Zahl (z.B. 0 � 59) <br/> **ss**: Sekunde als zweistellige Zahl mit Vornullen (z.B. 00 � 59) |
| **S** <br/> (Teile einer Sekunde) | **S**: Zehntel einer Sekunde <br/> **SS**: Hundertstel einer Sekunde <br/> **SSS**: Tausendstel einer Sekunde = Millisekunde (Standard f�r `$ZTS`) <br/> **SSSS**: Zehntausendstel einer Sekunde = Microsekunde |
| [**$H**[**D**|**T**]|**$ZTS**] <br/> (IRIS Horolog) | **$H**: entspricht `$HOROLOG` in IRIS <br/> **$HD**: entspricht dem Datumsanteil von `$HOROLOG` <br/> **$HT**: entspricht dem Zeitanteil von `$HOROLOG` <br/> **$ZTS**: entspricht `$ZTIMESTAMP` in IRIS |

Die im Folgenden beschriebenen Datum-, Zeit- und Zeitstempel-Datentypen wurden mittels dieser Formatierungskriterien spezifiziert. Jeder der Datentypen kann daher �ber die Angabe der entsprechenden Parameter in der Definition der Eigenschaften an die individuellen Bed�rfnisse angepasst werden. Ein Beispiel f�r einen solchen Fall ist der Datentyp `arsblue.datatype.YearWeek` welcher f�r statistische Zwecke benutzt werden kann. In der ODBC, XSD bzw. JSON Repr�sentation wird der erste Tag (Montag) der entsprechenden Woche herangezogen (ausgenommen beim Jahreswechsel wird der erste Tag im Jahr genommen, um etwaige Selektionskriterien nicht zu verletzen).
Dies gilt ebenso f�r ODBC und XSD Formate, welche auf den f�r die jeweilige Implementation als Standard definierten Wert spezifiziert wurden.
Zus�tzlich werden f�r JSON und JavaScript weitere Formate spezifiziert. F�r JSON gibt es die jeweilige Methode f�r die Konvertierung ins und vom logischen Format. F�r JavaScript wurde das Format lediglich spezifiziert und es wird auch nicht auf Syntax und Semantik gepr�ft.

| Datentyp | Logisches Format | Display Format (je nach NLS) | ODBC Format | XSD Format | JSON Format | JavaScript Format |
| --- | --- | --- | --- | --- | --- | --- |
| `arsblue.datatype.Date` | yyyyMMdd | dd/MM/yyyy <br/> MM/dd/yyyy | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.DateTime` | yyyyMMddHHmmss | dd/MM/yyyy HH:mm:ss <br/> MM/dd/yyyy HH:mm:ss | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.Time` | HHmmss | HH:mm:ss | HH:mm:ss | HH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.TimeStamp` | yyyyMMddHHmmss.SSS | dd/MM/yyyy HH:mm:ss.SSS <br/> MM/dd/yyyy HH:mm:ss.SSS | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss.SSS | Y-m-d\TH:i:s.u |
| `arsblue.datatype.YearWeek` | yyyyww | yyyy/ww | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |

#### Speicherbedarf

Einer der gro�en Vorteile dieser Datentypen liegt im Umstand, dass sie als Dezimalzahlen in IRIS gehandhabt bzw. gespeichert werden. In der folgenden Tabelle wird der Unterschied zwischen den Standard IRIS Datentypen und den ars-blue Datentypen aufgezeigt. Der angegebene Speicherbedarf in Bytes entspricht nur dem Inhalt des jeweiligen Datentyps, tats�chlich werden pro Attribut zwei zus�tzliche Byte ben�tigt (wegen `$LISTBUILD`): Anzahl der Bytes f�r dieses Attribut und Datentyp des Attributes.

| ars-blue Datentyp | Bytes | IRIS Datentype | Bytes |
| --- | --- | --- | --- |
| `arsblue.datatype.Date` | 4 | `%Library.Date` | 0 � 3 |
| `arsblue.datatype.DateTime` | 6 | `%Library.DateTime` | 19 |
| `arsblue.datatype.Time` | 0 � 3 | `%Library.Time` | 0 � 3 |
| `arsblue.datatype.TimeStamp` | 9 | `%Library.TimeStamp` | 19 |
| `arsblue.datatype.YearWeek` | 3 | - | - |

Da IRIS nur den absolut notwendigen Speicher f�r Dezimalwerte belegt, k�nnen Datum und Zeit im angegebenen Bereich variieren. Der geringe Speicherbedarf wird durch Verwendung von Dezimalwerten f�r die Implementation erreicht. Aus diesem Grund gibt es folgende Einschr�nkungen:

- Minimaler Zeitstempel wegen IRIS `$HOROLOG` Implementation: **1840/12/31 00:00:00.0**
- Maximaler Zeitstempel wegen IRIS `$HOROLOG` Implementation: **9999/12/31 23:59:59.9999**

Durch die Verschr�nkung mit der IRIS `$HOROLOG` und Dezimalwert Implementation ist es leider nicht m�glich ein Datum au�erhalb der oben genannten Grenzen zu erfassen.

#### SQL und Performance

Ein weiterer Vorteil der Datentypen zeigt sich in SQL Abfragen. Im Gegensatz zu den Standard IRIS Datentypen sind die ars-blue Datentypen in einem menschlich lesbaren und sortierbaren Format. Man kann dadurch im logischen Format statt im Anzeigeformat Abfragen durchf�hren und erspart sich das Umrechnen von Datum und Zeit von und auf IRIS `$HOROLOG`. Ebenso ist das Datum/Zeit Format wie auch der Zeitstempel bereits in einem Format, mit dem man einfach ohne Konvertierung Zeitr�ume abfragen kann.

Eine korrekte SQL Abfrage f�r einen Datumsbereich mit separatem Datum und Zeit Attribut kann mit Standard IRIS Datum und Zeit Datentypen nur durch komplexe Umformung der beiden Attribute zu einem Datum/Zeit Attribut erfolgen. Dasselbe Problem kann mit ars-blue Datum und Zeit Attributen hingegen sehr einfach gel�st werden, z.B. durch Verkettung der beiden Attribute oder durch Multiplikation und Addition der beiden Attribute:
```
SELECT (Date || $EXTRACT(1000000 + Time,2,7)) AS DateTime
  FROM MyClassWithDateAndTime
  WHERE ((Date * 1000000) + Time) BETWEEN ? AND ?
```
Trotz der nicht-nativen Implementation der ars-blue Datum-, Zeit- und Zeitstempel Datentypen und der daraus resultierenden Vorteile (Speicher, Lesbarkeit), ist bei der Performance der SQL Abfragen im Logischen Modus kein Unterschied feststellbar und im Anzeigemodus eine nicht signifikante Verschlechterung durch die nicht-native Implementation in ObjectScript bemerkbar (variiert je nach SQL Abfrage und OS des DBMS).

#### Migration von IRIS Standard Datentypen

Um bestehende Standard IRIS Datum-, Zeit- und Zeitstempel Datentypen durch ars-blue Datum-, Zeit- und Zeitstempel Datentypen zu ersetzen, ohne dabei die Datens�tze migrieren zu m�ssen, ist dies einfach m�glich, indem man den jeweiligen Datentyp verwendet und im logischen Format das Format des originalen Datentyps definiert.
```
/// migrate %Library.Date
Property SomeDate As arsblue.datatype.Date (LOGICALFORMAT="$HD")

/// migrate %Library.Time
Property SomeTime As arsblue.datatype.Time (LOGICALFORMAT="$HT")

/// migrate %Library.DateTime
Property SomeDateTime As arsblue.datatype.DateTime (LOGICALFORMAT="yyyy-MM-dd HH:mm:ss")

/// migrate %Library.TimeStamp
Property SomeTimeStamp As arsblue.datatype.TimeStamp (LOGICALFORMAT="yyyy-MM-dd HH:mm:ss")
```
Dies behebt nicht den erh�hten Speicherbedarf, wof�r eine tats�chliche Migration der Datens�tze notwendig w�re, aber liefert den Vorteil flexible Ausgabeformate definieren zu k�nnen.

#### Aktuelles Datum f�r Klassenattribute

Das aktuelle Datum eines Klassenattributs im logischen Format kann �ber den Namen des Attributs ermittelt werden.
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
Es wird das Datum und die Zeit der aktuell eingestellten Zeitzone unter Ber�cksichtigung der Sommerzeit verwendet.
