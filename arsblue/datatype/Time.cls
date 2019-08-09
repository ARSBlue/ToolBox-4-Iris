/// This datatype supports formated time instances.
/// NOTE: the valid format patterns are described in arsblue.datatype.DateTimeFormat!
/// 
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.datatype.Time Extends arsblue.datatype.DateTime [ ClientDataType = TIME, OdbcType = TIME, SqlCategory = TIME ]
{

/// The datatype logical format (if it's a valid numeric value, it will be stored as decimal value).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter LOGICALFORMAT As %String = "HHmmss";

/// The datatype display format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter DISPLAYFORMAT As %String = {##class(arsblue.datatype.DateTimeFormat).GetTimeDisplayFormat()};

/// The datatype XSD format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter XSDFORMAT As %String = "HH:mm:ssZ";

/// Declares the XSD type used when projecting XML Schemas.
Parameter XSDTYPE = "time";

/// The datatype ODBC format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter ODBCFORMAT As %String = "HH:mm:ss";

}
