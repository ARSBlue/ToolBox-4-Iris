/// This datatype special for year/week instances.
/// NOTE: the valid format patterns are described in arsblue.datatype.DateTimeFormat!
/// 
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.datatype.YearWeek Extends arsblue.datatype.Date [ ClientDataType = DATE, OdbcType = DATE, SqlCategory = DATE ]
{

/// The datatype logical format (if it's a valid numeric value, it will be stored as decimal value).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter LOGICALFORMAT As %String = "yyyyww";

/// The datatype display format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter DISPLAYFORMAT As %String = "yyyy/ww";

}
