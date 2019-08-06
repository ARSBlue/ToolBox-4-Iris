# ARSBlue ToolBox-4-Iris -- Util Package

- [Gregorian Calender](#gregorian-calender)
  - [Leap-Year](#leap-year)
  - [Number of days a month](#number-of-days-a-month)
  - [Number of Calender Weeks in the Year](#number-of-calendar-weeks-in-the-year)
  - [Calendar Week for Date](#calendar-week-for-date)
  - [First Day in Calendar Week](#first-day-in-calendar-week)
  - [Last Day in Calendar Week](#last-day-in-calendar-week)
  - [Weekday for Date](#weekday-for-date)
  - [Easter Sunday](#easter-sunday)
  - [Public Holidays](#public-holidays)
- [Date, Time and Timestamp](#date-time-and-timestamp)
  - [Free Formatting](#free-formatting)
- [Execute Operating System Commands](#execute-operating-system-commands)
  - [Capture Output and Error Output](#capture-output-and-error-output)
  - [Submit Input](#submit-input)
  - [Specify Directory](#specify-directory)
  - [Use Callback](#use-callback)
  - [Execute Command asynchronously](#execute-command-asynchronously)
  - [Execute Command asynchronously with Callback](#execute-command-asynchronously-with-callback)
- [JSON Utilities](#json-utilities)
  - [Include JSON Macro in Source Code](#include-json-macro-in-source-code)
  - [JSON Index Search by Value](#json-index-search-by-value)
  - [Copy JSON Arrays or Objects](#copy-json-arrays-or-objects)
    - [Copy JSON](#copy-json)
    - [Copy JSON with Overwrite the Target Data](#copy-json-with-overwrite-the-target-data)
    - [JSON Copying of Non-Existant Data](#json-copying-of-non-existant-data)
    - [JSON Copy from Existing Data](#json-copy-from-existing-data)
  - [Check JSON Arrays or Objects for Equality](#check-json-arrays-or-objects-for-equality)
  - [Compare JSON Arrays or Objects](#compare-json-arrays-or-objects)
  - [Export Data Objects to JSON](#export-data-objects-to-json)
  - [Import Data Objects from JSON](#import-data-objects-from-json)
  - [JSON and `$LIST`](#json-and-list)
  - [JSON and `%Library.Status`](#json-and-librarystatus)
  - [Read JSON](#read-json)
  - [Write JSON](#write-json)

## Gregorian Calender

The class `arsblue.util.Calendar` supports problems with date and time. The following are the features that are not present in any standard InterSystems IRIS date or time implementation. Detailed information on the method parameters of the presented methods or all available methods can be found in the InterSystems IRIS class documentation.

The functions have been implemented due to European requirements, i.e. one week starts with Monday and ends with Sunday, and the holidays are the same as the configured locale. Currently, the holidays are available for Germany (Protestant and Roman Catholic feast days) and Austria (Roman Catholic feast days). However, the interface can be individually extended for each country.

The methods described below have a range of values from 31/12/1840 to 31/12/9999 based on the IRIS `$HOROLOG` implementation. Below or above no values can be supplied. Resulting special cases are mentioned in the following methods.

### Leap-Year

This method can be used to check a year whether it is a leap year.
```
USER>write ##class(arsblue.util.Calendar).IsLeapYear(2019)
0
USER>write ##class(arsblue.util.Calendar).IsLeapYear(2020)
1
```

### Number of days a month

This method can be used to determine the number of days in a month. Leap years are taken into account.
```
USER>write ##class(arsblue.util.Calendar).GetDaysInMonth(2019,2)
28
USER>write ##class(arsblue.util.Calendar).GetDaysInMonth(2020,2)
29
```

### Number of Calendar Weeks in the Year

This method can be used to determine the number of calendar weeks in a year.
```
USER>write ##class(arsblue.util.Calendar).GetWeeksInYear(2019)
52
USER>write ##class(arsblue.util.Calendar).GetWeeksInYear(2020)
53
```

### Calendar Week for Date

This method can be used to determine the calendar week for a date.
```
USER>set var=20160101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20160101 is 53 in 2015
USER>set var=20170101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20170101 is 52 in 2016
USER>set var=20180101 write "week for ",var," is ",##class(arsblue.util.Calendar).GetWeekInYear(.var)," in ",var
week for 20180101 is 01 in 2018
```

### First Day in Calendar Week

This method can be used to determine the first day (Monday) for a calendar week.
```
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201553)
20151228
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201652)
20161226
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201752)
20171225
```
Since the calendar week is not year-old, there is a special variant of this method, which does not deliver the first day of the calendar week at the turn of the year, but the first day of the year (otherwise, this method works the same as the standard method).
```
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeek(201901)
20181231
USER>write ##class(arsblue.util.Calendar).GetFirstDayInWeekInYear(201901)
20190101
```
Since the correct date can not be delivered due to the InterSystems IRIS `$HOROLOG` implementation for calendar week 1840/53, the first valid InterSystems IRIS `$HOROLOG` date (31.12.1840) will be delivered.

### Last Day in Calendar Week

This method can be used to determine the last day (Sunday) for a calendar week.
```
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201553)
20160103
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201652)
20170101
USER>write ##class(arsblue.util.Calendar).GetLastDayInWeek(201752)
20171231
```
Since the correct date can not be delivered due to the InterSystems IRIS `$HOROLOG` implementation for the calendar week 9999/52, the last valid InterSystems IRIS `$HOROLOG` date (31.12.9999) will be delivered.

### Weekday for Date

With this method the day of the week can be determined for a date (`1` = Monday to `7` = Sunday).
```
USER>write ##class(arsblue.util.Calendar).GetDayInWeek(20190101)
2
```

### Easter Sunday

With this method, the Easter Sunday can be determined for a year. This day is used for the calculation of most church holidays for the Evangelical or Roman Catholic Church.
```
USER>write ##class(arsblue.util.Calendar).GetEaster(2019)
20190421
```
Due to the InterSystems IRIS `$HOROLOG` implementation, Easter Sunday can not be determined before 1841 or after 9999.

### Public Holidays

This method can be used to determine for a date whether it is a holiday or not. Furthermore, all holidays of a year can be determined with the same method. The example shown below uses Austria (AT) as the country setting.

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
The list of all holidays is given by reference only and contains per date an InterSystems IRIS `$LIST` with the information whether it is a whole (`1`), a half (`.5`) or no (`0`) legal Holiday is about or whether it is a holiday that is committed only in certain states (comma-separated list of all provincial abbreviations) and if two holidays on the same date, their identifiers are given as a comma-separated list.

Due to the InterSystems IRIS `$HOROLOG` implementation no holidays can be determined before the year 1841 and after the year 9999.

If holidays are needed for a country that has not yet been implemented, this can be done simply by creating a class `arsblue.util.Calendar.<Country code>` and extending the class `arsblue.util.Calendar`. Only the method `GetHoliday(...)` has to be overwritten.
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
You should always calculate all possible holidays. The caching of holidays is the responsibility of the application that implements them!

## Date, Time and Timestamp

The `arsblue.util.DateTime` class contains the functionality that could not be accommodated directly by the InterSystems IRIS specification of data types (for example, no SQL procedures are allowed in data types, etc.).

### Free Formatting

This method allows you to freely move the date, time or timestamp to another format.
```
USER>write ##class(arsblue.util.DateTime).Format(20190406213405.123, "yyyyMMddHHmmss.SSS", "EEEE, dd-MM-yyyy/ww HH:mm:ss (SSS)")
Samstag, 06-04-2019/14 21:34:05 (123)
```
The same method can also be called as an SQL procedure.
```
SELECT arsblue_util.DateTime_Format(20190406213405.123, 'yyyyMMddHHmmss.SSS','EEEE, dd-MM-yyyy/ww HH:mm:ss (SSS)')
```

## Execute Operating System Commands

The standard InterSystems IRIS implementation already offers a number of options for executing a command in the operating system. The class `arsblue.util.Exec` extends these functionalities to simplify the processing in InterSystems IRIS.

### Capture Output and Error Output

In the standard InterSystems IRIS implementation, the programmer himself has to take care of capturing the output or the error output. The output and error output can be queried directly via data streams.
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
The output and error output can also be captured in the same data stream (example see [Submit Input](#submit-input)). The output and error output can also be output on the current device by passing the current `$IO` variable for the data streams (example see [Specify Directory](#specify-directory)).

### Submit Input

In the standard InterSystems IRIS implementation, the programmer himself has to take care of the transfer of the input. The input can be transferred directly via a data stream.
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
The command "unknown_cmd" is either misspelled or could not be found.
```
The example above now shows that the output and the error output in each case give no indication of the order in which they happened. It makes sense to expect multiple outputs and error outputs to merge the two into one data stream.
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
The command "unknown_cmd" is either misspelled or could not be found.
``` 

### Specify Directory

In the standard InterSystems IRIS implementation, it is not directly possible to execute the command in a directory of the operating system. The directory in which the operating system command is to be executed can be specified.
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

### Use Callback

In the standard InterSystems IRIS implementation, it is not directly possible to specify a function to be executed after the operating system command. The difference to editing in the calling function is the direct access to the parameters used in the call.

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

**_Callback Sample:_**
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

### Execute Command asynchronously

In the standard InterSystems IRIS implementation, it is not directly possible to query the status of an operating system command executed in the background (separate process). The process number can be queried directly.
```
USER>write $System.Status.GetErrorText(##class(arsblue.util.Exec).Call("dir /S /B >NUL","C:\InterSystems\IRIS",,,,1,.pid)),!,"pid=",pid
 
pid=28636
USER>while (##class(arsblue.util.Exec).IsProcessRunning(pid)) { write "." } write "finished"
......finished
```

### Execute Command asynchronously with Callback

In the standard InterSystems IRIS implementation, it is not directly possible to respond to an operating system command that runs in the background. The callback function allows you to execute commands in InterSystems IRIS after the operating system command completes in the background.
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

## JSON Utilities

Many functions already exist in the standard InterSystems IRIS JSON implementation. The functions described here combine some of the functions or expand them for improved handling of JSON objects. On the one hand the functions of the class `arsblue.util.Json` are available and on the other hand there is the corresponding macro `arsblue.util.Json` in order to be able to use the most important functions of the class in shortened notation in the source code. In the following, the functions are always described with the equivalent macro (if any).

### Include JSON Macro in Source Code

To be able to use the macro in your own source code, it is necessary to include it in the first line of the class.
```
Include (arsblue.util.Json)

/// my class
Class my.Class {
  ...
}
```

### JSON Index Search by Value

**_Syntax:_**
```
 ##class(arsblue.util.Json).IndexOf(<JSON-Array-Oder-Objekt>,<Wert>[,<Start-Index>])
```

**_Macro:_**
```
$$$JSON.IndexOf(<JSON-Array-Oder-Objekt>,<Wert>[,<Start-Index>])
```

By default, the search returns the index where the value occurs first. The optional parameter `Start-Index` can be used to search for further occurrences. If no index for a value is found, an empty string is returned.

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

**_JSON Object:_**
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

### Copy JSON Arrays or Objects

**_Syntax:_**
```
 ##class(arsblue.util.Json).Copy(<JSON-Quell-Array-Oder-Objekt>,<JSON-Ziel-Array-Oder-Objekt>[,<Bedingung>])
```

**_Macro:_**
```
$$$JSON.Copy(<JSON-Quell-Array-Oder-Objekt>,<JSON-Ziel-Array-Oder-Objekt>[,<Bedingung>])
```
 
With this function, JSON arrays or objects can be copied or linked. If an empty destination array or object is specified, it is a pure copy function. If a non-empty target array or object is specified, the data in the destination is connected to the data of the source. The way the data is connected can be specified by the condition.

| Condition | Description |
| --- | --- |
| **0** (Default) | Copies all data from the source and overwrites the data in the destination if necessary. |
| **1** | Copies only those data of the source that are not present in the destination. |
| **2** | Copies only those data of the source, which exist in the destination and overwrites these. |

#### Copy JSON

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target=""
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target))
 
USER>write target.%ToJSON()
{"array":[1,2,3],"object":{"a":"b","c":"d"}}
```
This condition creates a depth copy. The advantage over the variant proposed by InterSystems IRIS (`set target={}.%FromJson(source.% ToJson())`) is that object references are copied, which in the InterSystems IRIS standard case are not exported to JSON and thus no longer can be imported from JSON.

#### Copy JSON with Overwrite the Target Data

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,0))
 
USER>write target.%ToJSON()
{"array":[1,2,3],"object":{"a":"b","b":"z","c":"d"}}
```
With this condition JSON arrays are completely replaced, in JSON objects the data is only overwritten.

#### JSON Copying of Non-Existant Data

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,1))
 
USER>write target.%ToJSON()
{"array":[3,4,5,1,2],"object":{"a":"x","b":"z","c":"d"}}
```
In this condition, non-existent values are added to JSON arrays at the end; JSON objects will only insert non-existent data.

#### JSON Copy from Existing Data

```
USER>set source={"array":[1,2,3],"object":{"a":"b","c":"d"}},target={"array":[3,4,5],"object":{"a":"x","b":"z"}}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).Copy(source,.target,2))
 
USER>write target.%ToJSON()
{"array":[3,4,5],"object":{"a":"b","b":"z"}}
```
With this condition, JSON arrays remain untouched; in JSON objects, only existing data is overwritten.

### Check JSON Arrays or Objects for Equality

**_Syntax:_**
```
 ##class(arsblue.util.Json).Equals(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```

**_Macro:_**
```
$$$JSON.Equals(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```
 
With this function, JSON arrays or objects can be checked for equality.
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
All levels of the two JSON arrays or objects are compared. The advantage over the variant proposed by InterSystems IRIS (`set equals=(json1.% ToJSON()=json2.%ToJSON())`) is that object references are compared, which in the InterSystems IRIS standard case are not exported to JSON and thus can not be compared. Furthermore, the IRIS JSON export takes into account the order of creation of the values, so it is not possible to check whether a JSON object (which depends only on the content and not the order - as in the JSON array) really does is equal to.
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

### Compare JSON Arrays or Objects

**_Syntax:_**
```
 ##class(arsblue.util.Json).Diff(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```

**_Macro:_**
```
$$$JSON.Diff(<JSON-Array-Oder-Objekt>,<JSON-Vergleichs-Array-Oder-Objekt>)
```
 
This function can be used to compare JSON arrays or objects.
```
USER>set json1={"a":"b","c":["d","e","f"]},json2={"c":["d","e","f"],"a":"b"}
 
USER>write ##class(arsblue.util.Json).Diff(json1,json2)
 
USER>set json1={"a":"b","c":["d","E","f"]},json2={"c":["d","e","f"],"a":"B"}
 
USER>write ##class(arsblue.util.Json).Diff(json1,json2).%ToJSON()
{"a":["b","B"],"c":[null,["E","e"]]}
```
All levels of the two JSON arrays or objects are compared. If no JSON array or object is returned, the two JSON arrays or objects are identical; otherwise, in the returned JSON array or object, those values are defined as JSON array (`[<value-1>,<value-2>]`) that have changed (in a JSON array, `null` means that the value at this index has not changed, but there is an index behind it that contains a change).

### Export Data Objects to JSON

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromObject(<Objektreferenz>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>][,<Transiente-Daten-exportieren>])
 ##class(arsblue.util.Json).GetJSONFromExtent(<Objekt-ID>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>])
```

**_Macro:_**
```
$$$JSON.GetJSONFromObject(<Objektreferenz>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>][,<Transiente-Daten-exportieren>])
$$$JSON.GetJSONFromExtent(<Objekt-ID>,<Exportierte-JSON-Objektreferenz>[,<Alle-Daten-exportieren>][,<ID/GUID-nicht-exportieren>])
```

With these functions, data objects can be exported to JSON. The difference between the two methods is that the `GetJSONFromObject` method works with the loaded object references in memory, whereas `GetJSONFromExtent` works with the data in the respective object global. The InterSystems IRIS architecture is designed to load a data object only once, i.e. no matter how many times an object is loaded with the same object id, it always points to the same object reference in memory (with all its changes already made). This is sometimes not desirable and the application wants to know what is actually still in the object global or what changes are already available in the object world. For this, the possibility was created to read this data as JSON directly from the Extent.

With the `GetJSONFromObject` method, all object references stored in memory can be exported to JSON. It is not mandatory that these are persistable data, only that they are derived from `%Library.RegisteredObject`.
The programmer can decide if he wants to export all data or just the "header" data (ie class, ID and if available GUID).
The programmer can decide if he wants to export all data except the "header" data. This option is particularly interesting if you need to communicate with third-party systems that are not necessarily aware of internal class names and ID's.
The programmer can decide if he also wants to export transient data. Of course, this option is not available for `GetJSONFromExtent` because only non-transient data can be exported here.

### Import Data Objects from JSON

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetObjectFromJSON(<JSON-Objekt>,<Importierte-Objektreferenz>[,<Alle-Daten-importieren>][,<ID/GUID-nicht-importieren>][,<Transiente-Daten-importieren>])
```

**_Macro:_**
```
$$$JSON.GetObjectFromJSON(<JSON-Objekt>,<Importierte-Objektreferenz>[,<Alle-Daten-importieren>][,<ID/GUID-nicht-importieren>][,<Transiente-Daten-importieren>])
```

With this function, data objects can be imported from JSON. The object references are loaded (if data objects) and changed accordingly but not saved (if data objects). The memory of the data objects is the responsibility of the programmer. In principle, all classes derived from `%Library.RegisteredObject` can be imported.
The developer can decide if he wants to import all the data or just the "header" data (i.e. class, ID and if available GUID). This corresponds to an availability check, as it is only possible to check whether a data object can be loaded with the given "header" data.
The programmer can decide if he wants to import all data except the "header" data. This option is especially interesting when you need to make copies of data, i.e. an export with subsequent import without "header" data creates a copy of the exported data (if automatic IDs are used).
The programmer can decide if he also wants to import transient data.

### JSON and `$LIST`

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromList(<$LIST>)
 ##class(arsblue.util.Json).GetListFromJSON(<JSON-Array>)
```

**_Macro:_**
```
$$$JSON.GetJSONFromList(<$LIST>)
$$$JSON.GetListFromJSON(<JSON-Array>)
```

With these functions a `$LIST` can be used to create a JSON array or from a JSON array a `$LIST`.
```
USER>set list=$LISTBUILD("a","b","c",$LISTBUILD(1,2,3))
 
USER>write ##class(arsblue.util.Json).GetJSONFromList(list).%ToJSON()
["a","b","c",[1,2,3]]

USER>set json=["a","b","c",[1,2,3]]
 
USER>zwrite ##class(arsblue.util.Json).GetListFromJSON(json)
$lb("a","b","c",$lb(1,2,3))
```

### JSON and `%Library.Status`

**_Syntax:_**
```
 ##class(arsblue.util.Json).GetJSONFromStatus(<Status>)
 ##class(arsblue.util.Json).GetStatusFromJSON(<JSON-Objekt>)
```

**_Macro:_**
```
$$$JSON.GetJSONFromStatus(<Status>)
$$$JSON.GetStatusFromJSON(<JSON-Objekt>)
```

These functions can be used to create a JSON object from a `%Library.Status` or a `%Library.Status` from a JSON object.
```
USER>set status=$System.Status.Error(5001,"This is an error!")
 
USER>write ##class(arsblue.util.Json).GetJSONFromStatus(status).%ToJSON()
{"_ClassName":"%Library.Status","_Status":[[5001,"This is an error!",null,null,null,null,null,null,null,[null,"USER",["e^zError+1^%SYSTEM.Status.1^1","e^^^0"]]]]}
USER>set json={"_ClassName":"%Library.Status","_Status":[[5001,"This is an error!",null,null,null,null,null,null,null,[null,"USER",["e^zError+1^%SYSTEM.Status.1^1","e^^^0"]]]]}
 
USER>write $System.Status.GetErrorText(##class(arsblue.util.Json).GetStatusFromJSON(json))
FEHLER #5001: This is an error!
```

### Read JSON

**_Syntax:_**
```
 ##class(arsblue.util.Json).%FromJSON(<Zeichenkette-Oder-Datenstrom>)
```

**_Macro:_**
```
$$$JSON.%FromJSON(<Zeichenkette-Oder-Datenstrom>)
```

With this function JSON can be read from a string or a data stream. The difference to the standard InterSystems IRIS implementation is that both strict and non-strict JSON syntax (object keywords with or without single quotes), single-line as well as multi-line comments and JavaScript functions (stored as data stream objects) are allowed. The limitation is that the object keywords always have to be at the beginning of a new line (spaces and tabs are ignored).

### Write JSON

**_Syntax:_**
```
 ##class(arsblue.util.Json).%ToJSON(<JSON-Array-Oder-Objekt>,<Ausgabedatenstrom-Objektreferenz>[,<Einrückungszeichen>][,<Einrückungsebene>])
```

**_Macro:_**
```
$$$JSON.%ToJSON(<JSON-Array-Oder-Objekt>,<Ausgabedatenstrom-Objektreferenz>[,<Einrückungszeichen>][,<Einrückungsebene>])
```

This feature allows JSON to be written to an output stream. The output is automatically formatted. The formatting can be adjusted with the additional parameters. The standard InterSystems IRIS implementation (`% ZEN.Auxiliary.jsonProvider`) unfortunately has an incorrect or incomplete implementation for some data types.
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
