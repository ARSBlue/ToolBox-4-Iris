/// This datatype supports formated date instances.
/// NOTE: the valid format patterns are described in arsblue.datatype.DateTimeFormat!
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.datatype.Date Extends arsblue.datatype.DateTime [ ClientDataType = DATE, OdbcType = DATE, SqlCategory = DATE ]
{

/// The datatype logical format (if it's a valid numeric value, it will be stored as decimal value).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter LOGICALFORMAT As %String = "yyyyMMdd";

/// The datatype display format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter DISPLAYFORMAT As %String = {##class(arsblue.datatype.DateTimeFormat).GetDateDisplayFormat()};

/// The datatype XSD format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter XSDFORMAT As %String = "yyyy-MM-dd";

/// Declares the XSD type used when projecting XML Schemas.
Parameter XSDTYPE = "date";

/// The datatype ODBC format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter ODBCFORMAT As %String = "yyyy-MM-dd";

}
