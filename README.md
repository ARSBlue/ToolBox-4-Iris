# ARSBlue ToolBox-4-Iris

**API for InterSystems IRIS with a collection of handy and useful tools**

The **ToolBox-4-IRIS** contains a collection of handy and useful tools - features that are not available in InterSystems IRIS, but greatly simplify application development. This includes additional classes, individual methods or even more efficient macros, which are described in the respective packages.

**_Functions_**: These are generally static methods of an abstract class. Deviations from this rule are described as such.

**_Documentation_**: The documentation is available in English (README.md) as well as in German (README_DE.md).

## Content

- [Macros](#macros)
- [Data Types](#data-types)
- [Data Input and Output](#data-input-and-output)
- [Server-side Event Handling](#server-side-event-handling)
- [Useful Utilities](#useful-utilities)
- [License](#license)

## Macros

The package [arsblue](./arsblue) contains macros that are not present in InterSystems IRIS but that facilitate the development of applications and increase their readability.

These include e.g. general ObjectScript macros, status macros, National Language Support macros, and JavaScript macros.

## Data Types

The package [arsblue.datatype](./arsblue/datatype) contains additional dynamic data types for date, time, and timestamps that are not present in InterSystems IRIS, but greatly facilitate the development of applications and increase readability.

These data types include formatting, memory footprint, SQL and performance, and more.

## Data Input and Output

The package [arsblue.io](./arsblue/io) contains useful functions for working with files and directories that are not available in InterSystems IRIS, but considerably simplify the development of applications.

These include general file and directory functions, examining files or directories for existence or content, deleting files and directories, serializing object instances to/from JSON, and more.

## Server-side Event Handling

The functionality contained in the package [arsblue.event](./arsblue/event) enables the development of applications which should react dynamically to system or data events. Although InterSystems IRIS has process-based event handling, it has no ability to respond dynamically to system or data events (only through the implementation of triggers).

The package includes synchronous or asynchronous event handling by user process or event queue, synchronous or asynchronous application of system events, or handling of persisted data events.

## Useful Utilities

Die im Package [arsblue.util](./arsblue/util) beschriebenen Hilfsprogramme erweitern den Funktionsumfang der in InterSystems IRIS nicht vorhandenen Standardfunktionen.

Im Package enthalten sind unter anderem zahlreiche Kalender-Funktionen (Schaltjahr, Kalenderwoche, Wochentag, Feiertage etc.), eine Möglichkeit zur freien Formatierung von Datum, Zeit und Zeitstempel sowie Funktionen zur Ausführung von Betriebssystembefehlen und einige JSON Hilfsprogramme (zum Kopieren, Prüfen, Vergleichen, Exportieren, Importieren, Lesen, Schreiben etc.).

The utilities described in the package [arsblue.util](./arsblue/util) extend the functionality of the standard functions not available in InterSystems IRIS.

Included in the package are numerous calendar functions (leap year, calendar week, day of the week, holidays, etc.), a free formatting of date, time and timestamps, functions for executing operating system commands and some JSON utilities (for copying, checking, comparing, exporting, importing, reading, writing, etc.).

## License ##

For licensing rights and restrictions, see [LICENSE](./LICENSE) (MIT).
