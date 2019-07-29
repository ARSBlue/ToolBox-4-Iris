/// This datatype supports formated timestamp instances.
/// NOTE: the valid format patterns are described in arsblue.datatype.DateTimeFormat!
Class arsblue.datatype.TimeStamp Extends arsblue.datatype.DateTime [ ClientDataType = TIMESTAMP, OdbcType = TIMESTAMP, SqlCategory = TIMESTAMP ]
{

/// The datatype logical format (if it's a valid numeric value, it will be stored as decimal value).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
/// NOTE: timestamp is restricted to milliseconds because of comptibility with other systems (JSON,...)!
Parameter LOGICALFORMAT As %String = "yyyyMMddHHmmss.SSS";

/// The datatype display format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter DISPLAYFORMAT As %String = {##class(arsblue.datatype.DateTimeFormat).GetTimeStampDisplayFormat()};

/// The datatype JSON format.
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
/// NOTE: JSON/Javascript only support millisecond
Parameter JSONFORMAT As %String = "yyyy-MM-ddTHH:mm:ss.SSS";

/// The datatype javascript format (this format will not be used within IRIS, it's just a wrapper for JSON format).
/// NOTE: it's recommended do not use senseless formats which are not unique and meaningfull date/time formats!
Parameter JSFORMAT As %String = "Y-m-d\TH:i:s.u";

}
