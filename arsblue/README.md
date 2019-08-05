# ARSBlue ToolBox-4-Iris -- Macros 

## Include Macro

The `arsblue.Include` include-file contains all the macros described below:

- [ObjectScript Macros](#objectscript-macros)
- [Status Macros](#status-macros)
- [National Language Support Macros](#national-language-support-macros)
- [JavaScript Macros](#javascript-macros)

## ObjectScript Macros

Die `arsblue.OS` include-file contains macros, that should abbreviate ObjectScript commands or give descriptive names for InterSystems IRIS standard functions.

| Macro | Description |
| --- | --- |
| **_Macros with Strings:_** ||
| **$$$NULL** | Corresponds to the NULL character (`$C(0)`) used in some InterSystems IRIS functions (e.g. streams, ...). |
| **$$$ISNULL(%val)** | Checks if the passed value (`%val`) is an empty string (`$$$NULLOREF`) or a NULL character (`$$$NULL`). |
| **$$$IFNULL(%val,%def)** | Checks the passed value (`%val`) and returns the default value (`%def`) if `$$$ISNULL` matches, otherwise the value (`%val`) itself. |
| **_Macros with Numbers:_** ||
| **$$$MININT** | The value of the smallest possible integer number in InterSystems IRIS. |
| **$$$MAXINT** | The value of the largest possible integer number in InterSystems IRIS. |
| **$$$ISNUMERIC(%val)** | Checks if the passed value (`%val`) is a numeric value. Lead zeros and the special `$DOUBLE` values `INF`, `-INF` und `NAN` are interpreted as strings. |  
| **_Macros with Date and Time:_** ||
| **$$$DAYINSEC** | The number of seconds for a day (24 hours * 60 minutes * 60 seconds = 86400 seconds). |
| **$$$TimeStamp** | The current timestamp in the format yyyyMMddHHmmss.SSSSS |
| **_$LIST-Macros:_** ||
| **$$$ISLIST(%val)** | Checks if the passed value (`%val`) is `$LIST`. Unlike `$LISTVALID` this must not be an empty string. |
| **$$$ISLISTEMPTY(%val)** | Checks if the passed value (`%val`) is `$LIST` with at least one NULL entry. |
| **_Conversion Macros:_** ||
| **$$$GETVALUE(%val)** | Checks if the passed value (`%val`) is a number and converts it as a number (for example `$DOUBLE`, ...) or as a string. |
| **$$$GETVALUEQ(%val)** | Like `$$$GETVALUE` - only strings are enclosed in double quotes. |

## Status Macros

The `arsblue.Status` include-file contains macros that make `%Library.Status` queries easier.

| Macro | Description |
| --- | --- |
| **$$$ISSTATUS(%val)** | Checks if the passed value (`%val`) is a valid `%Library.Status` string. |
| **_Warnings:_** ||
| **$$$WARNING(%msg)** | Generates an error status with the error code `0` and the given warning (`%msg`). |
| **$$$ISWARNING(%sc)** | Checks if the status is a warning. |
| **$$$GETWARNING(%sc)** | Returns the warning from the status (`%sc`). |
| **_`QUIT`-Macros with Return Value:_** ||
| **$$$Quit(%sc)** | Checks if the status (`%sc`)  is an error and exits the current command block with this status. <br/> **_Attention:_** only use if the status is available in a variable, a command would be executed several times! |
| **$$$QuitIf(%expr,%msg)** | Checks if the command (`%expr`) is true and terminates the current command block with a general error with the given error text (`%msg`). |
| **$$$QuitOnSQLError(%rs,%rssql)** | Sets the `%SQL.StatementResult` object with the variable name (`%rs`) and checks if the object has a SQL error code and in this case exits the current command block with an SQL error with the error message from the object. |
| **$$$QuitError(%msg)** | Ends the current command block with a general error with the given error text (`%msg`). |
| **_`THROW`-Makros:_** ||
| **$$$Throw(%sc)** | Checks if the status (`%sc`) is an error and throws a status exception. <br/> **_Attention:_** only use if the status is available in a variable, a command would be executed several times! |
| **$$$ThrowIf(%expr,%msg)** | Checks if the command (`%expr`) is true and throws a general error exception with the given error text (`%msg`). |
| **$$$ThrowOnSQLError(%rs,%rssql)** | Sets the `%SQL.StatementResult` object with the variable name (`%rs`) and checks if the object has a SQL error code and throws an SQL error exception with the error message out of the object in this case. |
| **$$$ThrowError(%msg)** | Throws a general error exception with the given error text (`%msg`).|
| **_`RETURN`-Macros:_** ||
| **$$$Return(%sc)** | Checks if the status (`%sc`) is an error and ends the method with this status. <br/> **_Attention:_** only use if the status is available in a variable, a command would be executed several times! |
| **$$$ReturnOnError(%sc)** | Sets the status (`%sc`) and checks if the status is an error and ends the method with this status. <br/> **_Attention:_** Unlike `$$$Return` this macro also works for passed commands! |
| **$$$RETURNONERROR(%sc,%expr)** | Sets the result of the command (`%expr`) with the variable name (`%sc`) and checks if the status is an error and ends the method with this status. | 
| **$$$ReturnIf(%expr,%msg)** | Checks if the command (`%expr`) is true and terminates the method with a general error with the given error text (`%msg`). |
| **$$$ReturnOnSQLError(%rs,%rssql)** | Sets the `%SQL.StatementResult` object with the variable name (`%rs`) and checks if the object has a SQL error code and in this case exits the method with an SQL error with the error message from the object. |
| **$$$ReturnError(%msg)** | Ends the method with a general error with the given error text (`%msg`).|
| **_`QUIT`-Macros without Return Value:_** ||
| **$$$Break(%expr)** | Checks if the command (`%expr`) is true and exits the current command block. |
| **$$$BreakOnError(%expr)** | Checks if the command (`%expr`) is an error state and exits the current command block. |
| **$$$BREAKONERROR(%sc,%expr)** | Sets the result of the command (`%expr`) with the variable name (`%sc`) and checks if the status is an error and ends the current command block. | 
| **$$$BreakOnSQLError(%rs,%rssql)** | Sets the `%SQL.StatementResult` object with the variable name (`%rs`) and checks if the object has a SQL error code and exits the current command block. |
| **_`CONTINUE`-Macros:_** ||
| **$$$Continue(%expr)** | Checks if the command (`%expr`) is true and starts the next loop pass. |
| **$$$ContinueOnError(%expr)** | Checks if the command (`%expr`) is an error state and starts the next loop pass. |
| **$$$CONTINUEONERROR(%sc,%expr)** | Sets the result of the command (`%expr`) with the variable name (`%sc`) and checks if the status is an error and starts the next loop pass. | 
| **$$$ContinueOnSQLError(%rs,%rssql)** | Sets the `%SQL.StatementResult` object with the variable name (`%rs`) and checks if the object has an SQL error code and starts the next loop pass. |

## National Language Support Macros

Die `arsblue.NLS` include-file contains macros that read the NLS settings.

| Macro | Description |
| --- | --- |
| **$$$NLSFormat(%idx)** | Returns the setting for the corresponding formatting index (s. `%syNLS` include-file) |
| **$$$NLSMonthAbbr** | Returns the abbreviated month names of the current NLS settings. |
| **$$$NLSMonthName** | Returns the full month names of the current NLS settings. |
| **$$$NLSWeekdayAbbr** | Returns the abbreviated weekday names of the current NLS settings. |
| **$$$NLSWeekdayName** | Returns the complete weekday names of the current NLS settings. |

## JavaScript Macros

The `arsblue.JS` include-file contains JavaScript macros. The `arsblue.util.Json` include-file is part of JavaScript macros. 

| Macro | Description |
| --- | --- |
| **_Macros with Numbers:_** ||
| **$$$JSMININT** | The value of the smallest possible integer number in JavaScript. |
| **$$$JSMAXINT** | The value of the largest possible integer number in JavaScript. |
| **$$$ISJSNUMERIC(%val)** | Checks if the passed value  (`%val`)is a numeric JavaScript value. Lead zeros and the special `$DOUBLE` values `INF`, `-INF` und `NAN` are interpreted as strings. |  
| **_Conversion Macros:_** ||
| **$$$GETJSVALUE(%val)** | Checks if the passed value (`%val`) is a JavaScript number and converts it as a number (for example `$DOUBLE`, ...) or as a string. |
| **$$$GETJSVALUEQ(%val)** | Like `$$$GETJSVALUE` - only strings are enclosed in single quotes. |
