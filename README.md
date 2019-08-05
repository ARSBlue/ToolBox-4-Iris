# ARSBlue ToolBox-4-Iris

**API for InterSystems IRIS with a collection of practical and useful tools**

The **Toolbox-4-IRIS** includes functionality that is not available in InterSystems IRIS, but can greatly simplify the development of applications. This functionality includes additional classes, single methods or even more efficient macros. These are described in the respective packages.

**_Funktionen_**: These are generally static methods of an abstract class. Deviations from this rule are described as such..

## Content

- [Macros](#macros)
- [DataTypes](#datatypes)
- [Data Input and Output](#data-input-and-outuput)
- [Serverside Eventhandling](#serverside-eventhandling)
- [Useful Utilities](#useful-utilities)

## Macros

InterSystems IRIS contains a wide range of macros. The macros described in the package [arsblue](./arsblue) are not available in InterSystems IRIS, but facilitate the development of applications and increase their readability.

## DataTypes

InterSystems IRIS contains a wide range of DataTypes. The DataTypes described in the package [arsblue.datatype](./arsblue/datatype) are not available in InterSystems IRIS, but facilitate the development of applications and increase their readability.

## Data Input and Output

InterSystems IRIS contains a wide range of data input and output options. The functionality described in the package [arsblue.io](./arsblue/io) is not available in IRIS, but facilitates the development of applications.

## Serverside Eventhandling

InterSystems IRIS includes process-based event handling, but no ability to respond dynamically to system or data events (only through the implementation of triggers). The functionality described in the package [arsblue.event] (./arsblue/event) enables the development of applications which should react dynamically to system or data events.

## Useful Utilites

The utilities described in the package [arsblue.util] (./arsblue/util) extend the functionality of the standard functions that are not available in InterSystems IRIS.

## License ##

See the [LICENSE](./LICENSE) file for license rights and limitations (MIT).
