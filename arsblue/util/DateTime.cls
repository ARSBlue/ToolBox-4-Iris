Include arsblue.datatype.Include

/// This class contains addition functions around date and time
Class arsblue.util.DateTime Extends %RegisteredObject [ Abstract ]
{

/// Format date/time value from source format pattern to target format pattern.
/// <ul>
/// <li>%val...the date/time value to format.</li>
/// <li>sourceFormat...the source format pattern.</li>
/// <li>targetFormat...the target format pattern.</li>
/// <li>rebuild...true to manually rebuild the format method, false (default) otherwise.</li>
/// </ul>
/// Returns the value formated with target format pattern.
ClassMethod Format(%val As %RawString = "", sourceFormat As %String = "", targetFormat As %String = "", rebuild As %Boolean = {$$$NO}) As %RawString [ SqlProc ]
{
	new %class,%code,%property
	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="")) ""
	quit:((sourceFormat="") || (targetFormat="")) %val
	
	#dim convertClass as %String = "arsblue.temp.DateTime"
	#dim convertMethod as %String = $ZSTRIP($System.Encryption.Base64Encode($System.Encryption.MD5Hash(sourceFormat_"=>"_targetFormat)),"*E'A")
	
	if ('$$$comMemberDefined(convertClass,$$$cCLASSmethod,convertMethod) || rebuild)
	{
		set %class=##class(%Dictionary.ClassDefinition).%OpenId(convertClass)
		if ('$IsObject(%class))
		{
			set %class=##class(%Dictionary.ClassDefinition).%New()
			set %class.Name=convertClass
			set %class.Super="%RegisteredObject"
			set %class.IncludeCode="arsblue.datatype.Include"
		
			// next 2 lines are needed to create a default class definition
			do %class.ProcedureBlockReset()
			// do %class.GeneratedByReset()
			set %class.GeneratedBy="arsblue.util.DateTime"
			set %class.Description="Generated class for date/time conversion"
		
			$$$QuitOnError(%class.%Save())
		}
	
		set method=##class(%Dictionary.MethodDefinition).%OpenId(convertClass_"||"_convertMethod)
		if ('$IsObject(method))
		{
			set method=##class(%Dictionary.MethodDefinition).%New()
			set method.Name=convertMethod
			set method.ClassMethod=$$$YES
			set method.Description="Convert date/time from "_sourceFormat_" to "_targetFormat
			set method.FormalSpec="%val:%RawString="""""
			set method.ReturnType="%RawString"
		
			$$$QuitOnError(%class.Methods.Insert(method))
			$$$QuitOnError(%class.%Save())
		}
	
		if ((method.Implementation.Size<=0) || rebuild)
		{
			$$$QuitOnError(method.Implementation.Clear())
			
			set %code=method.Implementation
			do %code.WriteLine("	quit:(($ZU(115,13)&&(%val=$C(0)))||(%val="""")) """"")
			$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).ValidateDataType(sourceFormat))
			$$$QuitOnError(##class(arsblue.datatype.DateTimeFormat).FormatDataType(sourceFormat,targetFormat))
			// $$$QuitOnError(..GenerateCheckFormat(sourceFormat))
			// $$$QuitOnError(..GenerateConvertFormat(sourceFormat,targetFormat))
			do %code.WriteLine("	quit %val")
			$$$QuitOnError(method.%Save())
			$$$QuitOnError($System.OBJ.Compile(convertClass,"abc-diklry"))
		}
	}
	
	#dim val as arsblue.datatype.DateTime = $CLASSMETHOD(convertClass,convertMethod,%val)
	quit:($CASE($System.Status.GetErrorCodes(val),"":$$$YES,5034:$$$YES,:$$$NO)) val // return value if not an error
	set %objlasterror=val // set last error
	quit %val // return original value if error
}

}
