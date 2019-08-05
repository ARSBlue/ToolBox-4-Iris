# ARSBlue ToolBox-4-Iris -- Macros 

## Include Makro

The `arsblue.Include` include-file contains all the macros described below:

- [ObjectScript Macros](#objectscript-macros)
- [Status Macros](#status-macros)
- [National Language Support Macros](#national-language-support-macros)
- [JavaScript Macros](#javascript-macros)

## ObjectScript Macros

Die `arsblue.OS` include-file contains macros, that should abbreviate ObjectScript commands or give descriptive names for InterSystems IRIS standard functions.

| Macro | Description |
| --- | --- |
| **_String-Macros:_** ||
| **$$$NULL** | Corresponds to the NULL character (`$C(0)`) used in some InterSystems IRIS functions (e.g. streams, ...). |
| **$$$ISNULL(%val)** | Checks if the passed value (`%val`) is an empty string (`$$$NULLOREF`) or a NULL character (`$$$NULL`). |
| **$$$IFNULL(%val,%def)** | Checks the passed value (`%val`) and returns the default value (`%def`) if `$$$ISNULL` matches, otherwise the value (`%val`) itself. |
| **_Zahlen-Makros:_** ||
| **$$$MININT** | The value of the smallest possible integer number in InterSystems IRIS. |
| **$$$MAXINT** | The value of the largest possible integer number in InterSystems IRIS. |
| **$$$ISNUMERIC(%val)** | Checks if the passed value (`%val`) is a numeric value. Lead zeros and the special `$DOUBLE` values `INF`, `-INF` und `NAN` are interpreted as strings. |  
| **_Datum- bzw. Zeit-Makros:_** ||
| **$$$DAYINSEC** | Die Anzahl Sekunden für einen Tag (24 Stunden * 60 Minuten * 60 Sekunden = 86400 Sekunden). |
| **$$$TimeStamp** | Der aktuelle Zeitstempel im Format yyyyMMddHHmmss.SSSSS |
| **_$LIST-Makros:_** ||
| **$$$ISLIST(%val)** | Prüft, ob der übergebene Wert (`%val`) eine `$LIST` ist (im Gegensatz zu `$LISTVALID` darf es sich nicht um einen Leerstring handeln). |
| **$$$ISLISTEMPTY(%val)** | Prüft, ob der übergeben Wert (`%val`) eine `$LIST` mit mindestens einem nicht NULL-Eintrag ist. |
| **_Konvertierungsmakros:_** ||
| **$$$GETVALUE(%val)** | Prüft. ob der übergebene Wert (`%val`) eine Zahl ist und konvertiert diese als Zahl (z.B. `$DOUBLE`, ...) oder als Zeichenkette. |
| **$$$GETVALUEQ(%val)** | Wie `$$$GETVALUE` nur werden Zeichenketten mit doppelten Anführungszeichen umschlossen. |

## Status Makros

Die `arsblue.Status` Include-Datei beinhaltet Makros, die `%Library.Status` Abfragen erleichtern.

| Makro | Beschreibung |
| --- | --- |
| **$$$ISSTATUS(%val)** | Prüft, ob der übergebene Wert (`%val`) eine gültige `%Library.Status` Zeichenkette ist. |
| **_Warnungen:_** ||
| **$$$WARNING(%msg)** | Erzeugt einen Fehlerstatus mit dem Fehlercode `0` und der übergebenen Warnung (`%msg`). |
| **$$$ISWARNING(%sc)** | Prüft, ob es sich beim Status um eine Warnung handelt. |
| **$$$GETWARNING(%sc)** | Liefert die Warnung aus dem Status (`%sc`). |
| **_`QUIT`-Mit Rückgabewert-Makros:_** ||
| **$$$Quit(%sc)** | Prüft, ob der Status (`%sc`) ein Fehler ist und beendet den aktuellen Befehlsblock mit diesem Status. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verfügung steht, ein Befehl würde mehrmals ausgeführt werden! |
| **$$$QuitIf(%expr,%msg)** | Prüft, ob der Befehl (`%expr`) wahr ist und beendet den aktuellen Befehlsblock mit einem generellen Fehler mit dem übergebenen Fehlertext (`%msg`). |
| **$$$QuitOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und prüft, ob das Objekt einen SQL-Fehlercode aufweist und beendet den aktuellen Befehlsblock in diesem Fall mit einem SQL-Fehler mit der Fehlermeldung aus dem Objekt. |
| **$$$QuitError(%msg)** | Beendet den aktuellen Befehlsblock mit einem generellen Fehler mit dem übergebenen Fehlertext (`%msg`).|
| **_`THROW`-Makros:_** ||
| **$$$Throw(%sc)** | Prüft, ob der Status (`%sc`) ein Fehler ist und wirft eine Status-Ausnahme. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verfügung steht, ein Befehl würde mehrmals ausgeführt werden! |
| **$$$ThrowIf(%expr,%msg)** | Prüft, ob der Befehl (`%expr`) wahr ist und wirft eine generelle Fehler-Ausnahme mit dem übergebenen Fehlertext (`%msg`). |
| **$$$ThrowOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und prüft, ob das Objekt einen SQL-Fehlercode aufweist und wirft in diesem Fall eine SQL-Fehler-Ausnahme mit der Fehlermeldung aus dem Objekt. |
| **$$$ThrowError(%msg)** | Wirft eine generelle Fehler-Ausnahme mit dem übergebenen Fehlertext (`%msg`).|
| **_`RETURN`-Makros:_** ||
| **$$$Return(%sc)** | Prüft, ob der Status (`%sc`) ein Fehler ist und beendet die Methode mit diesem Status. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verfügung steht, ein Befehl würde mehrmals ausgeführt werden! |
| **$$$ReturnOnError(%sc)** | Setzt den Status (`%sc`) und prüft, ob der Status ein Fehler ist und beendet die Methode mit diesem Status. <br/> **_Achtung:_** im Gegensatz zu `$$$Return` funktioniert dieses Makro auch für übergebene Befehle! |
| **$$$RETURNONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und prüft, ob der Status ein Fehler ist und beendet die Methode mit diesem Status. | 
| **$$$ReturnIf(%expr,%msg)** | Prüft, ob der Befehl (`%expr`) wahr ist und beendet die Methode mit einem generellen Fehler mit dem übergebenen Fehlertext (`%msg`). |
| **$$$ReturnOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und prüft, ob das Objekt einen SQL-Fehlercode aufweist und beendet die Methode in diesem Fall mit einem SQL-Fehler mit der Fehlermeldung aus dem Objekt. |
| **$$$ReturnError(%msg)** | Beendet die Methode mit einem generellen Fehler mit dem übergebenen Fehlertext (`%msg`).|
| **_`QUIT`-Ohne Rückgabewert-Makros:_** ||
| **$$$Break(%expr)** | Prüft, ob der Befehl (`%expr`) wahr ist und beendet den aktuellen Befehlsblock. |
| **$$$BreakOnError(%expr)** | Prüft, ob der Befehl (`%expr`) ein Fehler-Status ist und beendet den aktuellen Befehlsblock. |
| **$$$BREAKONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und prüft, ob der Status ein Fehler ist und beendet den aktuellen Befehlsblock. | 
| **$$$BreakOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und prüft, ob das Objekt einen SQL-Fehlercode aufweist und beendet den aktuellen Befehlsblock. |
| **_`CONTINUE`-Makros:_** ||
| **$$$Continue(%expr)** | Prüft, ob der Befehl (`%expr`) wahr ist und beginnt den nächsten Schleifendurchlauf. |
| **$$$ContinueOnError(%expr)** | Prüft, ob der Befehl (`%expr`) ein Fehler-Status ist und beginnt den nächsten Schleifendurchlauf. |
| **$$$CONTINUEONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und prüft, ob der Status ein Fehler ist und beginnt den nächsten Schleifendurchlauf. | 
| **$$$ContinueOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und prüft, ob das Objekt einen SQL-Fehlercode aufweist und beginnt den nächsten Schleifendurchlauf. |

## National Language Support Makros

Die `arsblue.NLS` Include-Datei beinhaltet Makros, die NLS Einstellungen auslesen.

| Makro | Beschreibung |
| --- | --- |
| **$$$NLSFormat(%idx)** | Liefert die Einstellung für den entsprechenden Formatierungsindex (s. `%syNLS` Include-Datei) |
| **$$$NLSMonthAbbr** | Liefert die abgekrüzten Monatsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSMonthName** | Liefert die vollständigen Monatsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSWeekdayAbbr** | Liefert die abgekürzten Wochentagsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSWeekdayName** | Liefert die vollständigen Wochentagsnamen der aktuellen NLS-Einstellungen. |

## JavaScript Makros

Die `arsblue.JS` Include-Datei beinhaltet JavaScript-Makros. Die `arsblue.util.Json` Include-Datei ist Teil der JavaScript Makros. 

| Makro | Beschreibung |
| --- | --- |
| **_Zahlenmakros:_** ||
| **$$$JSMININT** | Der Wert der kleinsten möglichen Integer-Zahl in JavaScript. |
| **$$$JSMAXINT** | Der Wert der größten möglichen Integer-Zahl in JavaScript. |
| **$$$ISJSNUMERIC(%val)** | Prüft, ob der übergeben Wert (`%val`) ein numerischer JavaScript Wert ist. Vornullen und die speziellen `$DOUBLE`-Werte `INF`, `-INF` und `NAN` werden als Zeichenketten interpretiert. |  
| **_Konvertierungsmakros:_** ||
| **$$$GETJSVALUE(%val)** | Prüft. ob der übergebene Wert (`%val`) eine JavaScript-Zahl ist und konvertiert diese als Zahl (z.B. `$DOUBLE`, ...) oder als Zeichenkette. |
| **$$$GETJSVALUEQ(%val)** | Wie `$$$GETJSVALUE` nur werden Zeichenketten mit einfachen Anführungszeichen umschlossen. |


