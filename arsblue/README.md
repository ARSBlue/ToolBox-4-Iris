# ARSBlue IRIS Macros

## Include Makro

Die `arsblue.Include` Include-Datei beinhaltet alle unten beschriebenen Makros.

- [ObjectScript Makros](#objectscript-makros)
- [Status Makros](#status-makros)
- [National Language Support Makros](#national-language-support-makros)
- [JavaScript Makros](#javascript-makros)

## ObjectScript Makros

Die `arsblue.OS` Include-Datei beinhaltet Makros, die ObjectScript Befehle abk�rzen bzw. f�r IRIS Standard Funktionen sprechende Namen geben sollen.

| Makro | Beschreibung |
| --- | --- |
| **_Zeichenketten-Makros:_** ||
| **$$$NULL** | Entspricht dem NULL-Charakter (`$C(0)`), der in einigen IRIS Funktionen zur Anwendung kommt (z.B. Streams, ...). |
| **$$$ISNULL(%val)** | Pr�ft, ob der �bergebene Wert (`%val`) eine leere Zeichenkette (`$$$NULLOREF`) oder ein NULL-Charakter (`$$$NULL`) ist. |
| **$$$IFNULL(%val,%def)** | Pr�ft, den �bergebene Wert (`%val`) und liefert den Default-Wert (`%def`) wenn `$$$ISNULL` zutrifft, sonst den Wert (`%val`) selbst. |
| **_Zahlen-Makros:_** ||
| **$$$MININT** | Der Wert der kleinsten m�glichen Integer-Zahl in IRIS. |
| **$$$MAXINT** | Der Wert der gr��ten m�glichen Integer-Zahl in IRIS. |
| **$$$ISNUMERIC(%val)** | Pr�ft, ob der �bergeben Wert (`%val`) ein numerischer Wert ist. Vornullen und die speziellen `$DOUBLE`-Werte `INF`, `-INF` und `NAN` werden als Zeichenketten interpretiert. |  
| **_Datum- bzw. Zeit-Makros:_** ||
| **$$$DAYINSEC** | Die Anzahl Sekunden f�r einen Tag (24 Stunden * 60 Minuten * 60 Sekunden = 86400 Sekunden). |
| **$$$TimeStamp** | Der aktuelle Zeitstempel im Format yyyyMMddHHmmss.SSSSS |
| **_$LIST-Makros:_** ||
| **$$$ISLIST(%val)** | Pr�ft, ob der �bergebene Wert (`%val`) eine `$LIST` ist (im Gegensatz zu `$LISTVALID` darf es sich nicht um einen Leerstring handeln). |
| **$$$ISLISTEMPTY(%val)** | Pr�ft, ob der �bergeben Wert (`%val`) eine `$LIST` mit mindestens einem nicht NULL-Eintrag ist. |
| **_Konvertierungsmakros:_** ||
| **$$$GETVALUE(%val)** | Pr�ft. ob der �bergebene Wert (`%val`) eine Zahl ist und konvertiert diese als Zahl (z.B. `$DOUBLE`, ...) oder als Zeichenkette. |
| **$$$GETVALUEQ(%val)** | Wie `$$$GETVALUE` nur werden Zeichenketten mit doppelten Anf�hrungszeichen umschlossen. |

## Status Makros

Die `arsblue.Status` Include-Datei beinhaltet Makros, die `%Library.Status` Abfragen erleichtern.

| Makro | Beschreibung |
| --- | --- |
| **$$$ISSTATUS(%val)** | Pr�ft, ob der �bergebene Wert (`%val`) eine g�ltige `%Library.Status` Zeichenkette ist. |
| **_Warnungen:_** ||
| **$$$WARNING(%msg)** | Erzeugt einen Fehlerstatus mit dem Fehlercode `0` und der �bergebenen Warnung (`%msg`). |
| **$$$ISWARNING(%sc)** | Pr�ft, ob es sich beim Status um eine Warnung handelt. |
| **$$$GETWARNING(%sc)** | Liefert die Warnung aus dem Status (`%sc`). |
| **_`QUIT`-Mit R�ckgabewert-Makros:_** ||
| **$$$Quit(%sc)** | Pr�ft, ob der Status (`%sc`) ein Fehler ist und quittiert den aktuellen Befehlsblock mit diesem Status. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verf�gung steht, ein Befehl w�rde mehrmals ausgef�hrt werden! |
| **$$$QuitIf(%expr,%msg)** | Pr�ft, ob der Befehl (`%expr`) wahr ist und quittiert den aktuellen Befehlsblock mit einem generellen Fehler mit dem �bergebenen Fehlertext (`%msg`). |
| **$$$QuitOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und pr�ft, ob das Objekt einen SQL-Fehlercode aufweist und quittiert den aktuellen Befehlsblock in diesem Fall mit einem SQL-Fehler mit der Fehlermeldung aus dem Objekt. |
| **$$$QuitError(%msg)** | Quittiert den aktuellen Befehlsblock mit einem generellen Fehler mit dem �bergebenen Fehlertext (`%msg`).|
| **_`THROW`-Makros:_** ||
| **$$$Throw(%sc)** | Pr�ft, ob der Status (`%sc`) ein Fehler ist und wirft eine Status-Ausnahme. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verf�gung steht, ein Befehl w�rde mehrmals ausgef�hrt werden! |
| **$$$ThrowIf(%expr,%msg)** | Pr�ft, ob der Befehl (`%expr`) wahr ist und wirft eine generelle Fehler-Ausnahme mit dem �bergebenen Fehlertext (`%msg`). |
| **$$$ThrowOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und pr�ft, ob das Objekt einen SQL-Fehlercode aufweist und wirft in diesem Fall eine SQL-Fehler-Ausnahme mit der Fehlermeldung aus dem Objekt. |
| **$$$ThrowError(%msg)** | Wirft eine generelle Fehler-Ausnahme mit dem �bergebenen Fehlertext (`%msg`).|
| **_`RETURN`-Makros:_** ||
| **$$$Return(%sc)** | Pr�ft, ob der Status (`%sc`) ein Fehler ist und beendet die Methode mit diesem Status. <br/> **_Achtung:_** nur verwenden, wenn der Status in einer Variablen zur Verf�gung steht, ein Befehl w�rde mehrmals ausgef�hrt werden! |
| **$$$ReturnOnError(%sc)** | Setzt den Status (`%sc`) und pr�ft, ob der Status ein Fehler ist und beendet die Methode mit diesem Status. <br/> **_Achtung:_** im Gegensatz zu `$$$Return` funktioniert dieses Makro auch f�r �bergebene Befehle! |
| **$$$RETURNONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und pr�ft, ob der Status ein Fehler ist und beendet die Methode mit diesem Status. | 
| **$$$ReturnIf(%expr,%msg)** | Pr�ft, ob der Befehl (`%expr`) wahr ist und beendet die Methode mit einem generellen Fehler mit dem �bergebenen Fehlertext (`%msg`). |
| **$$$ReturnOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und pr�ft, ob das Objekt einen SQL-Fehlercode aufweist und beendet die Methode in diesem Fall mit einem SQL-Fehler mit der Fehlermeldung aus dem Objekt. |
| **$$$ReturnError(%msg)** | Beendet die Methode mit einem generellen Fehler mit dem �bergebenen Fehlertext (`%msg`).|
| **_`QUIT`-Ohne R�ckgabewert-Makros:_** ||
| **$$$Break(%expr)** | Pr�ft, ob der Befehl (`%expr`) wahr ist und unterbricht die aktuelle Schleife. |
| **$$$BreakOnError(%expr)** | Pr�ft, ob der Befehl (`%expr`) ein Fehler-Status ist und unterbricht die aktuelle Schleife. |
| **$$$BREAKONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und pr�ft, ob der Status ein Fehler ist und unterbricht die aktuelle Schleife. | 
| **$$$BreakOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und pr�ft, ob das Objekt einen SQL-Fehlercode aufweist und unterbricht die aktuelle Schleife. |
| **_`CONTINUE`-Makros:_** ||
| **$$$Continue(%expr)** | Pr�ft, ob der Befehl (`%expr`) wahr ist und beginnt den n�chsten Schleifendurchlauf. |
| **$$$ContinueOnError(%expr)** | Pr�ft, ob der Befehl (`%expr`) ein Fehler-Status ist und beginnt den n�chsten Schleifendurchlauf. |
| **$$$CONTINUEONERROR(%sc,%expr)** | Setzt das Ergebnis des Befehls (`%expr`) mit dem Variablennamen (`%sc`) und pr�ft, ob der Status ein Fehler ist und beginnt den n�chsten Schleifendurchlauf. | 
| **$$$ContinueOnSQLError(%rs,%rssql)** | Setzt das `%SQL.StatementResult`-Objekt mit dem Variablennamen (`%rs`) und pr�ft, ob das Objekt einen SQL-Fehlercode aufweist und beginnt den n�chsten Schleifendurchlauf. |

## National Language Support Makros

Die `arsblue.NLS` Include-Datei beinhaltet Makros, die NLS Einstellungen auslesen.

| Makro | Beschreibung |
| --- | --- |
| **$$$NLSFormat(%idx)$$$** | Liefert die Einstellung f�r den entsprechenden Formatierungsindex (s. `%syNLS` Include-Datei) |
| **$$$NLSMonthAbbr** | Liefert die abgekr�zten Monatsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSMonthName** | Liefert die vollst�ndigen Monatsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSWeekdayAbbr** | Liefert die abgek�rzten Wochentagsnamen der aktuellen NLS-Einstellungen. |
| **$$$NLSWeekdayName** | Liefert die vollst�ndigen Wochentagsnamen der aktuellen NLS-Einstellungen. |

## JavaScript Makros

Die `arsblue.JS` Include-Datei beinhaltet JavaScript-Makros.

| Makro | Beschreibung |
| --- | --- |
| **_Zahlenmakros:_** ||
| **$$$JSMININT** | Der Wert der kleinsten m�glichen Integer-Zahl in JavaScript. |
| **$$$JSMAXINT** | Der Wert der gr��ten m�glichen Integer-Zahl in JavaScript. |
| **$$$ISJSNUMERIC(%val)** | Pr�ft, ob der �bergeben Wert (`%val`) ein numerischer JavaScript Wert ist. Vornullen und die speziellen `$DOUBLE`-Werte `INF`, `-INF` und `NAN` werden als Zeichenketten interpretiert. |  
| **_Konvertierungsmakros:_** ||
| **$$$GETJSVALUE(%val)** | Pr�ft. ob der �bergebene Wert (`%val`) eine JavaScript-Zahl ist und konvertiert diese als Zahl (z.B. `$DOUBLE`, ...) oder als Zeichenkette. |
| **$$$GETJSVALUEQ(%val)** | Wie `$$$GETJSVALUE` nur werden Zeichenketten mit einfachen Anf�hrungszeichen umschlossen. |


