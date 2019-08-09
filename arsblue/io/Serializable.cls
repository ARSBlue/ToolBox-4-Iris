Include arsblue.util.Json

/// This class gives the possibility to export to JSON or import from JSON
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.io.Serializable Extends %RegisteredObject
{

/// Import data from JSON into this object
/// <ul>
/// <li>json...the JSON object with class information for which an object shall be returned</li>
/// <li>complete...true if all data from given JSON object should be imported, false (default) otherwise</li>
/// <li>ignodeId...true if the GUID/id from given JSON object shall be ignored, false (default) otherwise</li>
/// <li>allowTransient...true if transient data from given JSON object shall be imported, false (default) otherwise</li>
/// </ul>
/// Returns status OK if successfully imported from JSON object into this object, any other status signals failure!
Method %FromJSON(json As %DynamicAbstractObject = {$$$NULLOREF}, complete As %Boolean = {$$$NO}, ignoreId As %Boolean = {$$$NO}, allowTransient As %Boolean = {$$$NO}) As %Status
{
	quit $$$JSON.GetObjectFromJSON(json,$this,complete,ignoreId,allowTransient)
}

/// Export data from this object into JSON
/// <ul>
/// <li>json...the JSON object from given object</li>
/// <li>complete...true if all data from given object shall be exported, false (default) otherwise</li>
/// <li>ignodeId...true if the GUID/id from given object shall be ignored, false (default) otherwise</li>
/// <li>allowTransient...true if transient data from given object shall be exported, false (default) otherwise</li>
/// </ul>
/// Returns status OK if successfully exported JSON object from this object, any other status signals failure and the JSON object is set to null!
Method %ToJSON(ByRef json As %DynamicAbstractObject = {$$$NULLOREF}, complete As %Boolean = {$$$NO}, ignoreId As %Boolean = {$$$NO}, allowTransient As %Boolean = {$$$NO}) As %Status
{
	quit $$$JSON.GetJSONFromObject($this,.json,complete,ignoreId,allowTransient)
}

}
