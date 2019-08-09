Include arsblue.datatype.Include

/// This datatype supports formated date/time instances.
/// NOTE: the valid format patterns are described in arsblue.datatype.DateTimeFormat!
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.datatype.DateTime Extends %Library.DataType [ ClientDataType = TIMESTAMP, DependsOn = arsblue.datatype.DateTimeFormat, OdbcType = TIMESTAMP, SqlCategory = TIMESTAMP ]
{

/// The datatype logical format (if it's a valid numeric value, it will be stored as decimal value).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter LOGICALFORMAT As %String = "yyyyMMddHHmmss";

/// The datatype display format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter DISPLAYFORMAT As %String = {##class(arsblue.datatype.DateTimeFormat).GetDateTimeDisplayFormat()};

/// The datatype XSD format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter XSDFORMAT As %String = "yyyy-MM-ddTHH:mm:ssZ";

/// Declares the XSD type used when projecting XML Schemas.
Parameter XSDTYPE = "dateTime";

/// The datatype ODBC format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter ODBCFORMAT As %String = "yyyy-MM-dd HH:mm:ss";

/// The datatype JSON format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter JSONFORMAT As %String = "yyyy-MM-ddTHH:mm:ss";

/// The datatype javascript format (this format will not be used within IRIS, it's just a wrapper for JSON format).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter JSFORMAT As %String = "Y-m-d\TH:i:s";

/// Converts <var>%val</var> to a normalized value.
ClassMethod Normalize(%val As %CacheString) As arsblue.datatype.DateTime [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("LOGICALFORMAT"),%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	quit $$$GETDATETIMEVALUE(%val)")
	quit $$$OK
}

/// Return $$$OK if the value is valid for the datatype, or an error code otherwise.
ClassMethod IsValid(%val As %CacheString) As %Status [ CodeMode = objectgenerator, GenerateAfter = IsValidDT, ServerOnly = 0 ]
{
	#; If subclass has a IsValidDT then call this
	if ((%property'="") &&
		($$$comSubMemberDefined(%class.Name,$$$cCLASSproperty,%property,$$$cPROPmethod,"IsValidDT")) &&
		($$$comSubMemberKeyGet(%class.Name,$$$cCLASSproperty,%property,$$$cPROPmethod,"IsValidDT",$$$cXXXXorigin)'="%Library.DataType"))
	{
		do %code.WriteLine("	quit $S(##class("_%class.Name_")."_%property_"IsValidDT(%val):$$$OK,1:$$$ERROR($$$DTFailure,%val))")
		quit $$$OK
	}
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) $$$OK")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).ValidateDataType(%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	quit $$$OK")
	quit $$$OK
}

/// Converts logical value into display format
ClassMethod LogicalToDisplay(%val As arsblue.datatype.DateTime) As %String [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("LOGICALFORMAT"),%parameter("DISPLAYFORMAT")))
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

/// Converts display value into logical format
ClassMethod DisplayToLogical(%val As %String) As arsblue.datatype.DateTime [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("DISPLAYFORMAT"),%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	$$$QuitOnError(##class("_%class.Name_")."_%property_"IsValid(%val))")
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

/// Converts logical value into XSD format
ClassMethod LogicalToXSD(%val As arsblue.datatype.DateTime) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("LOGICALFORMAT"),%parameter("XSDFORMAT")))
	do %code.WriteLine("	quit %val")
	Quit $$$OK
}

/// Converts XSD value into logical format
ClassMethod XSDToLogical(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("XSDFORMAT"),%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	$$$QuitOnError(##class("_%class.Name_")."_%property_"IsValid(%val))")
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

/// Converts logical value into ODBC format
ClassMethod LogicalToOdbc(%val As arsblue.datatype.DateTime) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("LOGICALFORMAT"),%parameter("ODBCFORMAT")))
	do %code.WriteLine("	quit %val")
	Quit $$$OK
}

/// Converts ODBC value into logical format
ClassMethod OdbcToLogical(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("ODBCFORMAT"),%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	$$$QuitOnError(##class("_%class.Name_")."_%property_"IsValid(%val))")
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

/// Converts logical value into JSON format
ClassMethod LogicalToJSON(%val As arsblue.datatype.DateTime) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("LOGICALFORMAT"),%parameter("JSONFORMAT")))
	do %code.WriteLine("	quit %val")
	Quit $$$OK
}

/// Converts JSON value into logical format
ClassMethod JSONToLogical(%val As %String) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(%parameter("JSONFORMAT"),%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	$$$QuitOnError(##class("_%class.Name_")."_%property_"IsValid(%val))")
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

/// Get the current date/time in logical format
ClassMethod Now() As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine("	set %val=$ZUTIL(188)") // this is a workaround because $NOW() doesn't take care about timezone and DST
	$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType("$ZTS",%parameter("LOGICALFORMAT")))
	do %code.WriteLine("	quit %val")
	quit $$$OK
}

}
