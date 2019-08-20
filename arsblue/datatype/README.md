# ARSBlue ToolBox-4-Iris -- Data Type Package

The package [arsblue.datatype](./arsblue/datatype) contains additional dynamic data types for date, time, and timestamps that are not present in InterSystems IRIS, but greatly facilitate the development of applications and increase readability.

These data types include formatting, memory footprint, SQL and performance, and more.

**_Documentation_**: The documentation is available in English [README.md](./README.md) as well as in German [README_DE.md](./README_DE.md).

- [Date, Time and Timestamp](#date-time-and-timestamp)
  - [Formatting](#formatting)
  - [Memory Requirements](#memory-requirements)
  - [SQL and Performance](#sql-and-performance)
  - [Migration of InterSystems IRIS Standard Data Types](#migration-of-InterSystems-iris-standard-data-types)
  - [Current Date for Class Attributes](#current-date-for-class-attributes)

## Date, Time and Timestamp

The standard InterSystems IRIS data types include a large selection of more or less flexible date, time, and timestamp data types. The data types described below are highly dynamic and require - unlike most InterSystems IRIS data types - significantly less memory.

### Formatting

All described date, time, and timestamp data types are preconfigured but can be customized to any format. The following formats can be used:

| Pattern Character | Description |
| --- | --- |
| **y** <br/> (Year) | **yy**: year in the current century (e.g. 19 => 2019) <br/> **yyyy**: full year (e.g. 2019) |
| **M** <br/> (Month in the Year) | **M**: month as one or two digit number (e.g. 1 - 12) <br/> **MM**: month as two digit number with leading zeros (e.g. 01 - 12) <br/> **MMM** : abbreviated month name with NLS (e.g. Jan, Feb, Mar, ...) <br/> **MMMM**: month name with NLS (e.g. January, February, March, ...) |
| **d** <br/> (Day of the Month) | **d**: day as a one- or two-digit number (e.g. 1-31). <br/> **dd**: day as a two-digit number with leading zeros (e.g. 01-31) |
| **w** <br/> (Week a Year) | **w**: week as a one- or two-digit number (e.g. 1-53) <br/> **ww**: week as a two-digit number with leading zeros (e.g. 01-53) |
| **E** <br/> (Name of the Weekday) | **E**: single-digit weekday name with NLS (e.g. M, D, M, ...) <br/> **EE**: two-digit weekday name with NLS (e.g. Mo, Tu, We, ...) <br /> **EEE**: abbreviated weekday name with NLS (e.g. Mon, Tue, Wed, ...) <br/> **EEEE**: Weekday name with NLS (e.g. Monday, Tuesday, Wednesday, ...) |
| **u** <br/> (Day of the Week) | **u**: day in the week (e.g. 1 - 7 for Monday - Sunday) |
| **H** <br/> (Hour a Day) | **H**: hour as a one-digit number (e.g. 0-24) <br/> **HH**: hour as a two-digit number with leading zeroes (e.g. 00-24) |
| **m** <br/> (Minute in Hour) | **m**: minute as a one-digit number (e.g. 0-59) <br/> **mm**: Minute as a two-digit number with leading zeros (e.g. 00-59) |
| **s** <br/> (Second in Minute) | **s**: second as a one-digit number (e.g. 0-59) <br /> **ss**: second as a two-digit number with leading zeros (e.g. 00-59) |
| **S** <br/> (Parts of a Second) | **S**: tenth of a second <br/> **SS**: hundredth of a second <br/> **SSS**: thousandth of a second = millisecond (standard for `$ ZTS`) <br/> **SSSS**: Ten thousandths of a second = microsecond |
| [**$H**[**D**\|**T**]\|**$ZTS**] <br/> (InterSystems IRIS Horolog) | **$H**: corresponds to `$HOROLOG` in InterSystems IRIS <br/> **$HD**: corresponds to the date portion of `$HOROLOG` <br/> **$HT**: corresponds to the time portion of `$HOROLOG` <br/> **$ZTS**: corresponds  `$ZTIMESTAMP` in InterSystems IRIS |

The date, time, and timestamp data types described below are specified using these formatting criteria. Each of the data types can therefore be adapted to individual needs by specifying the corresponding parameters in the definition of the properties. An example of such a case is the data type `arsblue.datatype.YearWeek`, which can be used for statistical purposes. In the ODBC, XSD or JSON representation, the first day (Monday) of the corresponding week is used (except at the turn of the year, the first day of the year is used, so as not to violate any selection criteria).

This also applies to ODBC and XSD formats, which have been specified at the value defined as the default for the respective implementation.

In addition, additional formats are specified for JSON and JavaScript. For JSON there is the respective method for conversion to and from the logical format. For JavaScript the format has only been specified and it is not checked for syntax and semantics.

| Data Type | Logical Format | Display Format (depending on NLS) | ODBC Format | XSD Format | JSON Format | JavaScript Format |
| --- | --- | --- | --- | --- | --- | --- |
| `arsblue.datatype.Date` | yyyyMMdd | dd/MM/yyyy <br/> MM/dd/yyyy | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.DateTime` | yyyyMMddHHmmss | dd/MM/yyyy HH:mm:ss <br/> MM/dd/yyyy HH:mm:ss | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.Time` | HHmmss | HH:mm:ss | HH:mm:ss | HH:mm:ssZ | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |
| `arsblue.datatype.TimeStamp` | yyyyMMddHHmmss.SSS | dd/MM/yyyy HH:mm:ss.SSS <br/> MM/dd/yyyy HH:mm:ss.SSS | yyyy-MM-dd HH:mm:ss | yyyy-MM-ddTHH:mm:ssZ | yyyy-MM-ddTHH:mm:ss.SSS | Y-m-d\TH:i:s.u |
| `arsblue.datatype.YearWeek` | yyyyww | yyyy/ww | yyyy-MM-dd | yyyy-MM-dd | yyyy-MM-ddTHH:mm:ss | Y-m-d\TH:i:s |

### Memory Requirements

One of the great advantages of these types of data is that they are handled or stored as decimal numbers in InterSystems IRIS. The following table shows the difference between the standard InterSystems IRIS data types and the arsblue data types. The specified memory requirement in bytes only corresponds to the content of the respective data type, in fact two additional bytes per attribute are required (because of `$LISTBUILD`): Number of bytes for this attribute and data type of the attribute.

| arsblue Data Types | Bytes | IRIS Data Types | Bytes |
| --- | --- | --- | --- |
| `arsblue.datatype.Date` | 4 | `%Library.Date` | 0 – 3 |
| `arsblue.datatype.DateTime` | 6 | `%Library.DateTime` | 19 |
| `arsblue.datatype.Time` | 0 – 3 | `%Library.Time` | 0 – 3 |
| `arsblue.datatype.TimeStamp` | 9 | `%Library.TimeStamp` | 19 |
| `arsblue.datatype.YearWeek` | 3 | - | - |

Since InterSystems IRIS uses only the absolutely necessary memory for decimal values, date and time can vary within the specified range. The low memory requirement is achieved by using decimal values for the implementation. For this reason, there are the following restrictions:

- Minimum Timestamp due to InterSystems IRIS `$HOROLOG` Implementation: **1840/12/31 00:00:00.0**
- Maximum Timestamp due to InterSystems IRIS `$HOROLOG` Implementation: **9999/12/31 23:59:59.9999**

Due to the dependency on the InterSystems IRIS `$HOROLOG` and decimal value implementation, it is unfortunately not possible to record a date outside the limits mentioned above.

### SQL and Performance

Another benefit of the data types is evident in SQL queries. Unlike the standard InterSystems IRIS data types, the ars-blue data types are in a human readable and sortable format. This allows queries to be made in logical format rather than in the display format, saving the time and date from being converted to and from InterSystems IRIS `$HOROLOG`. Similarly, the date / time format as well as the timestamp is already in a format that allows you to easily query periods without conversion.

A correct SQL query for a date range with a separate date and time attribute can be done using standard InterSystems IRIS date and time data types only by complex transformation of both attributes to a date / time attribute. By contrast, the same problem can be solved very simply with ars-blue date and time attributes, e.g. by concatenating the two attributes or by multiplying and adding the two attributes:
```
SELECT (Date || $EXTRACT(1000000 + Time,2,7)) AS DateTime
  FROM MyClassWithDateAndTime
  WHERE ((Date * 1000000) + Time) BETWEEN ? AND ?
```
Despite the non-native implementation of the arsblue date, time and timestamp data types and the resulting advantages (memory, readability), there is no difference in the performance of SQL queries in logical mode and a non-significant degradation in display mode noticeable by the non-native implementation in ObjectScript (varies depending on SQL query and OS of the DBMS).

### Migration of InterSystems IRIS Standard Data Types

To replace existing standard InterSystems IRIS date, time and timestamp data types with arsblue date, time and timestamp data types, without having to migrate the datasets, this is easily possible by using the respective data type and in logical format defines the format of the original data type.
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
This does not address the increased memory requirements, which would require an actual migration of the datasets, but provides the benefit of being able to define flexible output formats.

### Current Date for Class Attributes

The current date of a class attribute in logical format can be determined by the name of the attribute.
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
The date and time of the currently set time zone, taking into account summer time, is used.
