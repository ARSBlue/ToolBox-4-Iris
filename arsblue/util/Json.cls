Include (arsblue.OS, arsblue.Status, arsblue.JS)

/// This class contains JSON utilities
Class arsblue.util.Json [ Abstract ]
{

/// Finds the JSON index of the first occurrence of a value.
/// The index may be a number if JSON is an array or a named key if JSON is an object.
/// <ul>
/// <li>json...the JSON object.</li>
/// <li>value...the value to search for in JSON object.</li>
/// <li>index...the index to search from in JSON object (optional).</li>
/// </ul>
/// Returns the index of first occurrence of the value or null if not found!
ClassMethod IndexOf(json As %DynamicAbstractObject = {$$$NULLOREF}, value As %RawString, index As %RawString = {$$$NULLOREF}) As %RawString
{
	quit:('$$$TypeOf(json,"%DynamicAbstractObject")) $$$NULLOREF
	
	set found=$$$NO
	set key=$$$NULLOREF
	set iterator=json.%GetIterator()
	while (iterator.%GetNext(.key, .jsonValue))
	{
		$$$Continue('$$$ISNULL(index) && (key']index))
		
		set type=json.%GetTypeOf(key)
		continue:($CASE(type,"null":$$$YES,"unassigned":$$$YES,:$$$NO))
				
		if ($CASE(type,"array":$$$YES,"object":$$$YES,:$$$NO) && $$$TypeOf(value,"%DynamicAbstractObject"))
		{
			if (..Equals(jsonValue, value))
			{
				set found=$$$YES
				quit
			}
		}
		else
		{
			if (jsonValue=value)
			{
				set found=$$$YES
				quit
			}
		}
	}
	quit $S(found:key,1:$$$NULLOREF)
}

/// Copies all the properties of source to the specified target.
/// NOTE: JSON arrays will be concatinated and condition has no effect!
/// <ul>
/// <li>source...the source JSON object.</li>
/// <li>target...the target JSON object (will be created if missing).</li>
/// <li>condition...the copy condition:<ul>
///   <li>0...copy all source properties, overwriting target properties (default).</li>
///   <li>1...copy only source properties not available in target.</li>
///   <li>2...copy only source properties available in target overwriting target properties.</li>
/// </ul></li>
/// </ul>
/// Returns status OK if successfully copied from source to target JSON object, any other status signals failure!
ClassMethod Copy(source As %DynamicAbstractObject = {$$$NULLOREF}, ByRef target As %DynamicAbstractObject = {$$$NULLOREF}, condition As %Integer = 0) As %Status
{
	#dim status as %Status = $$$OK
	try
	{
		quit:('$IsObject(source))
		set:('$IsObject(target)) target=$ClassMethod(source.%ClassName(1),"%New")
		set sourceType=$CASE(source.%ClassName(1),"%Library.DynamicArray":"array","%Library.DynamicObject":"object",:"wrong source class type "_source.%ClassName(1))
		set targetType=$CASE(target.%ClassName(1),"%Library.DynamicArray":"array","%Library.DynamicObject":"object",:"wrong target class type "_target.%ClassName(1))
		$$$ThrowIf(sourceType'=targetType,"cannot copy different JSON types ("_sourceType_"<>"_targetType_")")
		$$$ThrowIf('$CASE(condition,0:$$$YES,1:$$$YES,2:$$$YES,:$$$NO),"cannot copy with invalid condition "_condition)
		
		set iterator=source.%GetIterator()
		while (iterator.%GetNext(.key,.value))
		{
			if (targetType="object")
			{
				set sourceTypeOf=source.%GetTypeOf(key)
				set targetTypeOf=target.%GetTypeOf(key)
				continue:((condition=2) && (targetTypeOf="unassigned"))
				
				if ((sourceTypeOf="array") || (sourceTypeOf="object"))
				{
					kill newValue
					set:(sourceTypeOf=targetTypeOf) newValue=target.%Get(key)
					$$$ThrowOnError(..Copy(value,.newValue,condition))
					set value=newValue
				}
				else
				{
					continue:((condition=1) && (targetTypeOf'="unassigned"))
				}
				
				do target.%Set(key,value)
			}
			else  // array
			{
				if (condition=0)
				{
					do target.%Set(key,value)
				}
				else
				{
					set index=..IndexOf(target,value)
					if ($$$ISNULL(index) && (condition=1))
					{
						do target.%Push(value)
					}
					elseif ('$$$ISNULL(index) && (condition=2))
					{
						do target.%Set(index,value)
					}
				}
			}
		}
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) json=$$$NULLOREF
	quit status
}

/// Check if two JSON objects and all there subobjects are equal.
/// <ul>
/// <li>json1...the 1st JSON object to compare</li>
/// <li>json2...the 2nd JSON object to compare</li>
/// <ul>
/// Returns true if both JSON objects are equal, false otherwise
ClassMethod Equals(json1 As %DynamicAbstractObject = {$$$NULLOREF}, json2 As %DynamicAbstractObject = {$$$NULLOREF}) As %Boolean
{
	#define CheckEquals(%expr) set equals=%expr quit:'equals
	
	quit:(json1=json2) $$$YES
	
	set json1IsNull=$$$ISNULL(json1),json2IsNull=$$$ISNULL(json2)
	quit:(json1IsNull && json2IsNull) $$$YES
	quit:((json1IsNull && 'json2IsNull) || ('json1IsNull && json2IsNull)) $$$NO
	
	quit:('$$$TypeOf(json1,"%DynamicAbstractObject") || '$$$TypeOf(json2,"%DynamicAbstractObject")) $$$NO
	
	quit:(json1.%ClassName(1)'=json2.%ClassName(1)) $$$NO
	
	set equals=$$$YES
	kill keys
	
	set iterator=json1.%GetIterator()
	while (equals && iterator.%GetNext(.key,.value))
	{
		set keys(key)=""
		
		$$$CheckEquals(json1.%GetTypeOf(key)=json2.%GetTypeOf(key))
		if ($$$TypeOf(value,"%DynamicAbstractObject"))
		{
			$$$CheckEquals(..Equals(value,json2.%Get(key)))
		}
		else
		{
			$$$CheckEquals(value=json2.%Get(key))
		}
	}
	
	quit:'equals $$$NO
	
	set iterator=json2.%GetIterator()
	while (equals && iterator.%GetNext(.key,.value))
	{
		continue:($D(keys(key))) // already checked
		set equals=$$$NO
		quit
	}
	
	quit $S(equals:$$$YES,1:$$$NO)
}

/// Get the differences between two JSON objects.
/// The returned json contains an array[json1,json2] if the given JSON objects are not comparable.
/// The returned json contains an array/object with the keys of the given objects where only those keys with a difference are available as an array[keyValue1,keyValue2] for the key.
/// <ul>
/// <li>json1...the 1st JSON object to check</li>
/// <li>json2...the 2nd JSON object to check</li>
/// <ul>
/// Returns the JSON object with the differences between the given JSON objects or null if no differences found!
ClassMethod Diff(json1 As %DynamicAbstractObject = {$$$NULLOREF}, json2 As %DynamicAbstractObject = {$$$NULLOREF}) As %DynamicAbstractObject
{
	quit:(json1=json2) $$$NULLOREF
	
	set json1IsNull=$$$ISNULL(json1),json2IsNull=$$$ISNULL(json2)
	set json1IsJSON=$$$TypeOf(json1,"%DynamicAbstractObject"),json2IsJSON=$$$TypeOf(json2,"%DynamicAbstractObject")
	if (json1IsNull && json2IsNull)
	{
		quit $$$NULLOREF
	}
	elseif ((json1IsNull && 'json2IsNull) || ('json1IsNull && json2IsNull) || 'json1IsJSON || 'json2IsJSON || (json1.%ClassName(1)'=json2.%ClassName(1)))
	{
		set json=[]
		
		if (json1IsNull) { do json.%Push("","null") }
		elseif (json1IsJSON) { do json.%Push(##class(%DynamicAbstractObject).%FromJSON(json1.%ToJSON())) }
		else  { do json.%Push(json1) }
		
		if (json2IsNull) { do json.%Push("","null") }
		elseif (json2IsJSON) { do json.%Push(##class(%DynamicAbstractObject).%FromJSON(json2.%ToJSON())) }
		else  { do json.%Push(json2) }
		
		quit json
	}
	
	set json=$ClassMethod(json1.%ClassName(1),"%New")
	kill keys
	
	set iterator=json1.%GetIterator()
	while (iterator.%GetNext(.key,.value1))
	{
		set keys(key)=""
		set value2=json2.%Get(key)
		
		set jsonDiff=$$$NULLOREF
		if (json1.%GetTypeOf(key)'=json2.%GetTypeOf(key))
		{
			set jsonDiff=[]
			
			if ($$$ISNULL(value1)) { do jsonDiff.%Push("","null") }
			elseif ($$$TypeOf(value1,"%DynamicAbstractObject")) { do jsonDiff.%Push(##class(%DynamicAbstractObject).%FromJSON(value1.%ToJSON())) }
			else  { do jsonDiff.%Push(value1) }
			
			if ($$$ISNULL(value2)) { do jsonDiff.%Push("","null") }
			elseif ($$$TypeOf(value2,"%DynamicAbstractObject")) { do jsonDiff.%Push(##class(%DynamicAbstractObject).%FromJSON(value2.%ToJSON())) }
			else  { do jsonDiff.%Push(value2) }
		}
		elseif ($$$TypeOf(value1,"%DynamicAbstractObject"))
		{
			set jsonDiff=..Diff(value1,value2)
		}
		elseif (value1'=value2)
		{
			set jsonDiff=[]
			
			if ($$$ISNULL(value1)) { do jsonDiff.%Push("","null") }
			elseif ($$$TypeOf(value1,"%DynamicAbstractObject")) { do jsonDiff.%Push(##class(%DynamicAbstractObject).%FromJSON(value1.%ToJSON())) }
			else  { do jsonDiff.%Push(value1) }
			
			if ($$$ISNULL(value2)) { do jsonDiff.%Push("","null") }
			elseif ($$$TypeOf(value2,"%DynamicAbstractObject")) { do jsonDiff.%Push(##class(%DynamicAbstractObject).%FromJSON(value2.%ToJSON())) }
			else  { do jsonDiff.%Push(value2) }
		}
		
		do:('$$$ISNULL(jsonDiff)) json.%Set(key,jsonDiff)
	}
	
	set iterator=json2.%GetIterator()
	while (iterator.%GetNext(.key,.value2))
	{
		continue:($D(keys(key))) // already checked
		
		set jsonDiff=[]
		
		if ($$$ISNULL(value2)) { do jsonDiff.%Set(1,"","null") }
		elseif ($$$TypeOf(value2,"%DynamicAbstractObject")) { do jsonDiff.%Set(1,##class(%DynamicAbstractObject).%FromJSON(value2.%ToJSON())) }
		else  { do jsonDiff.%Set(1,value2) }
		
		do json.%Set(key,jsonDiff)
	}
	
	quit $S(json.%Size()=0:$$$NULLOREF,1:json)
}

/// Get a JSON object from an objects extent.
/// <ul>
/// <li>oid...the object identifier (syntax: $LB([id],classname,[streamlocation])) for which a JSON object shall be returned</li>
/// <li>complete...true if all data from given object classname/id shall be exported, false (default) otherwise</li>
/// <li>ignoreId...true if the GUID/id from given object classname/id shall be ignored, false (default) otherwise</li>
/// <li>data...for internal use only - do not use or change!</li>
/// </ul>
/// Returns status OK if successfully exported JSON object from given object classname/id from extent, any other status signals failure and the JSON object is set to null!
ClassMethod GetJSONFromExtent(oid As %List = {$$$NULLOREF}, ByRef json As %DynamicAbstractObject = {$$$NULLOREF}, complete As %Boolean = {$$$NO}, ignoreId As %Boolean = {$$$NO}, ByRef data) As %Status [ ProcedureBlock = 0 ]
{
	// we have to use ProcedureBlock=0 because we want to read data content with @-syntax!
	new (oid,json,complete,ignoreId,data)
	
	#dim status as %Status=$$$OK
	try
	{
		set id=$LG(oid,1)
		set className=$LG(oid,2)
		$$$ThrowIf($$$ISNULL(className)||('$$$comClassDefined(className)),"cannot create JSON from invalid classname "_className)
		
		set classType=$$$comClassKeyGet(className,$$$cCLASSclasstype)
		$$$ThrowIf('$CASE(classType,$$$cCLASSCLASSTYPESTREAM:$$$YES,$$$cCLASSCLASSTYPEPERSISTENT:$$$YES,$$$cCLASSCLASSTYPESERIAL:$$$YES,:$$$NO),"cannot create JSON from invalid classtype "_classType)
		
		set json={}.%Set($$$JSONClassName,className)
		
		if (classType=$$$cCLASSCLASSTYPEPERSISTENT)
		{
			if ('$ClassMethod(className,"%Exists",oid))
			{
				set json=$$$NULLOREF
				quit
			}
			 
			if ('ignoreId)
			{
				set:(id'="") json.$$$JSONId=id
				set GUID=##class(%Persistent).%GUID(oid)
				set:(GUID'="") json.$$$JSONGUID=GUID // GUID disabled objects do not have a GUID
			}
			
			quit:('complete)
		}
		elseif (classType=$$$cCLASSCLASSTYPESTREAM)
		{
			if ('ignoreId)
			{
				set:(id'="") json.$$$JSONId=id
			}
			set location=$LG(oid,3)
			set:(location'="") json.$$$JSONStreamLocation=location
			quit:('complete)
		
			set object=##class(%Stream.Object).%Open($LB(id,className,location)) // we can use a new instance of stream, because it will be loaded from extent and not shared in memory like persistent objects do!
			$$$ThrowOnError(object.Rewind())
			set json.$$$JSONStreamSize=+object.Size
			set data=[],len=1024
			while (len>=0)
			{
				set content=object.Read(.len,.status) $$$Throw(status) $$$Break(len<0)
				do data.%Push($System.Encryption.Base64Encode($ZCVT(content,"O","UTF8")))
			}
			set json.$$$JSONStreamData=data
			
			quit
		}
		
		set storageStrategy=$$$comClassKeyGet(className,$$$cCLASSstoragestrategy)
		set dataLocation="data"
		
		kill properties
		if (classType=$$$cCLASSCLASSTYPEPERSISTENT)
		{
			set index=""
			while ($$$YES)
			{
				set index=$$$comClassArrayNext(className,$$$cCLASSindex,index) quit:(index="")
				quit:($$$comMemberKeyGet(className,$$$cCLASSindex,index,$$$cINDEXtype)=$$$cINDEXTYPEKEY)
			}
			$$$ThrowIf(index="","cannot find valid key index for classname "_className)
			
			set indexPosition=""
			while ($$$YES)
			{
				set indexPosition=$$$comSubMemberNext(className,$$$cCLASSindex,index,$$$cINDEXproperty,indexPosition) quit:(indexPosition="")
				set propertyName=$$$comSubMemberKeyGet(className,$$$cCLASSindex,index,$$$cINDEXproperty,indexPosition,$$$cINDEXPROPproperty)
				set properties(propertyName)=$LB(index,$$$cINDEXTYPEKEY,,indexPosition)
			}
			
			set dataLocation=$$$comMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdatalocation)
			set dataLocation=$S($E(dataLocation,*)=")":$E(dataLocation,1,*-1)_",",1:dataLocation_"(") // open first id key
			if ($E(dataLocation,1,11)="{%%PARENT}(") // search for parent(s)
			{
				set indexCnt=$$$comMemberKeyGet(className,$$$cCLASSindex,index,$$$cINDEXproperty)
				set:('indexCnt) indexCnt=1 // ID key only
				
				set parentId=$P(id,"||",1,*-indexCnt) // parent id
				set dataLocation=dataLocation_""""_$REPLACE($P(id,"||",*-(indexCnt-1),*),"||",""",""")_"""" // children id
				
				set parentClassName=className
				while ($E(dataLocation,1,11)="{%%PARENT}(")
				{
					set parentName=""
					while ($$$YES)
					{
						set parentName=$$$comMemberNext(parentClassName,$$$cCLASSproperty,parentName) quit:(parentName="")
						quit:($$$comMemberKeyGet(parentClassName,$$$cCLASSproperty,parentName,$$$cPROPcardinality)=$$$cPROPCARDINALITYPARENT)
					}
					$$$ThrowIf(parentName="","cannot export JSON for invalid parent relationship "_parentClassName)
	
					set parentClassName=$$$comMemberKeyGet(parentClassName,$$$cCLASSproperty,parentName,$$$cPROPtype)
	
					set index=""
					while ($$$YES)
					{
						set index=$$$comClassArrayNext(parentClassName,$$$cCLASSindex,index) quit:(index="")
						quit:($$$comMemberKeyGet(parentClassName,$$$cCLASSindex,index,$$$cINDEXtype)=$$$cINDEXTYPEKEY)
					}
					$$$ThrowIf(index="","cannot find valid key index for parent classname "_parentClassName)
					set indexCnt=$$$comMemberKeyGet(parentClassName,$$$cCLASSindex,index,$$$cINDEXproperty)
					set:('indexCnt) indexCnt=1 // ID key
					
					set parentLocation=$$$comMemberKeyGet(parentClassName,$$$cCLASSstorage,storageStrategy,$$$cSDEFdatalocation)
					
					set dataLocation=$S($E(parentLocation,*)=")":$E(parentLocation,1,*-1)_",""",1:parentLocation_"(""")_$REPLACE($P(parentId,"||",*-(indexCnt-1),*),"||",""",""")_""","_$E(dataLocation,12,*)
					set parentId=$P(parentId,"||",1,*-indexCnt) quit:(parentId="")
				}
			}
			else
			{
				set dataLocation=dataLocation_""""_$REPLACE(id,"||",""",""")_"""" // id keys
			}
		}

		set dataName=""
		while ($$$YES)
		{
			set dataName=$$$comStorageSubMemberNext(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName) quit:(dataName="")
			set dataStructure=$$$comStorageSubMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName,$$$cSDEFDATAstructure)
			set dataSubscript=$$$comStorageSubMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName,$$$cSDEFDATAsubscript)
			set propertyName=$$$comStorageSubMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName,$$$cSDEFDATAattribute)
			if (propertyName'="")
			{
				set properties(propertyName)=$LB(dataName,dataStructure,dataSubscript)
			}
			else
			{
				set dataPosition=""
				while ($$$YES)
				{
					set dataPosition=$$$comStorageSubSubMemberNext(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName,$$$cSDEFDATAvalue,dataPosition) quit:(dataPosition="")
					set propertyName=$$$comStorageSubSubMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFdata,dataName,$$$cSDEFDATAvalue,dataPosition,$$$cSDEFDATAattribute)
					set:(propertyName'="") properties(propertyName)=$LB(dataName,dataStructure,dataSubscript,dataPosition)
				}
			}
		}
		
		set propertyName=""
		while ($$$YES)
		{
			set propertyName=$$$comMemberNext(className,$$$cCLASSproperty,propertyName) quit:(propertyName="")
			set propertyType=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPtype)
			set propertyRuntimeType=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPruntimetype)
			set propertyRuntimeClassType=$$$comClassKeyGet(propertyRuntimeType,$$$cCLASSclasstype)
			set propertyRuntimeCardinality=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPcardinality)
			set propertyRuntimeCollection=$S(
				$$$TypeOf(propertyRuntimeType,"%Collection.AbstractArray"):$$$cPROPCOLLECTIONARRAY,
				$$$TypeOf(propertyRuntimeType,"%Collection.AbstractList"):$$$cPROPCOLLECTIONLIST,
				$$$TypeOf(propertyRuntimeType,"%RelationshipObject"):$$$cPROPCOLLECTIONLIST,
				1:""
			)
			
			set property=$G(properties(propertyName)) continue:((property="")&&($CASE(propertyRuntimeCardinality,$$$cPROPCARDINALITYMANY:$$$NO,$$$cPROPCARDINALITYCHILDREN:$$$NO,:$$$YES)))
			
			set propertyValue=$$$NULLOREF
			set dataStructure=$LG(property,2)
			set dataSubscript=$LG(property,3)
			set dataPosition=$LG(property,4)
			if (dataStructure=$$$cINDEXTYPEKEY)  // all key index properties
			{
				set propertyValue=$P(id,"||",dataPosition)
				$$$ThrowIf($$$ISNULL(propertyValue),"cannot export JSON for invalid key property "_className_"."_propertyName_"=$LB("_$LISTTOSTRING(property)_")") 
			}
			elseif (dataStructure=$$$cSDEFDATASTRUCTURELISTNODE)  // all datatype, persistent and serial
			{
				set global=dataLocation_$S(dataLocation="data":$S(dataSubscript="":"",1:"("_dataSubscript_")"),1:$S(dataSubscript="":")",1:","_dataSubscript_")"))
				set propertyValue=$LG($G(@global),dataPosition)
			}
			elseif (dataStructure=$$$cSDEFDATASTRUCTURESUBNODE)  // all %Collection.AbstractArray
			{
				set global=dataLocation_$S(dataLocation="data":"(",1:",")_dataSubscript_",key)"
				set key=""
				while ($$$YES)
				{
					set key=$O(@global,1,value) quit:(key="")
					set propertyValue=propertyValue_$LB($LB(key,value))
				}
			}
			elseif (dataStructure=$$$cSDEFDATASTRUCTURENODE)  // all %DynamicAbstractObject
			{
				set global=dataLocation_$S(dataLocation="data":"(",1:",")_dataSubscript_")"
				set propertyValue=##class(%DynamicAbstractObject).%FromJSON(@global)
			}
			elseif ($CASE(propertyRuntimeCardinality,$$$cPROPCARDINALITYMANY:$$$YES,$$$cPROPCARDINALITYCHILDREN:$$$YES,:$$$NO))  // all %RelationshipObject with cardinality many/children
			{
				set propertyInverse=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPinverse)
				set inverseSQLTableName=$$$comClassKeyGet(propertyType,$$$cCLASSsqlqualifiednameQ)
				set inverseSQLFieldName=$$$comMemberKeyGet(propertyType,$$$cCLASSproperty,propertyInverse,$$$cPROPsqlfieldname)
				set stmt=##class(%SQL.Statement).%New()
				$$$ThrowOnError(stmt.%Prepare("select ID from "_inverseSQLTableName_" where "_inverseSQLFieldName_"=?"))
				set result=stmt.%Execute(id)
				if (result.%SQLCODE<0) $$$Throw($$$ERROR($$$SQLError,result.%Message))
				while (result.%Next(.status))
				{
					$$$Throw(status)
					set propertyValue=propertyValue_$LB($LB(result.%Get("ID"),propertyType))
				}
			}
			else
			{
				$$$Throw("cannot read unknown data structure "_$LISTTOSTRING(property))
			}
			set:$$$ISNULL(propertyValue) propertyValue=$$$NULLOREF
			
			set jsonValue=$$$NULLOREF
			if ($$$TypeOf(propertyValue,"%DynamicAbstractObject"))
			{
				set jsonValue=propertyValue
			}
			elseif ((propertyRuntimeCollection'="")&&($CASE(propertyRuntimeCardinality,"":$$$YES,$$$cPROPCARDINALITYMANY:$$$YES,$$$cPROPCARDINALITYCHILDREN:$$$YES,:$$$NO)))
			{
				$$$ThrowIf('$LV(propertyValue),"cannot export JSON from invalid "_propertyRuntimeCollection_" "_$LISTTOSTRING(property)_$S(propertyRuntimeCardinality="":"",1:","_propertyRuntimeCardinality))
				set elementType=$S($$$comMemberDefined(propertyType,$$$cCLASSparameter,"ELEMENTTYPE"):$$$comMemberKeyGet(propertyType,$$$cCLASSparameter,"ELEMENTTYPE",$$$cPARAMdefault),1:propertyType)
				set elementType=$CASE(elementType,"":"%String",:elementType)
				set elementClassType=$$$comClassKeyGet(elementType,$$$cCLASSclasstype)
				set jsonValue=$S(propertyRuntimeCollection=$$$cPROPCOLLECTIONARRAY:{},1:[])
				
				for key=1:1:$LL(propertyValue)
				{
					set listData=$LG(propertyValue,key)
					if (propertyRuntimeCollection=$$$cPROPCOLLECTIONARRAY)
					{
						$$$ThrowIf('$LV(listData),"cannot export JSON from invalid "__propertyRuntimeCollection_" data "_$LISTTOSTRING(property)_$S(propertyRuntimeCardinality="":"",1:","_propertyRuntimeCardinality))
						set listKey=$LG(listData,1)
						set listValue=$LG(listData,2)
					}
					else
					{
						set listKey=key
						set listValue=listData
					}
					
					set jsonListValue=$$$NULLOREF
					if ($$$ISNULL(listValue))
					{
						set jsonListValue=$$$NULLOREF
					}					
					elseif ((elementClassType=$$$cCLASSCLASSTYPEPERSISTENT) || (elementClassType=$$$cCLASSCLASSTYPESTREAM))
					{
						if ('$$$ISLISTEMPTY(listValue))
						{
							set elementOid=$S($LV(listValue):$LB($LG(listValue,1),$LG(listValue,2,elementType),$LG(listValue,3)),1:$LB(listValue,elementType))
							set:((elementClassType=$$$cCLASSCLASSTYPESTREAM) && ($LG(elementOid,3)="")) $LI(elementOid,3)=$$$comMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFstreamlocation)
							$$$ThrowOnError(..GetJSONFromExtent(elementOid,.jsonListValue,complete,ignoreId))
						}
					}
					elseif (elementClassType=$$$cCLASSCLASSTYPESERIAL)
					{
						if ('$$$ISLISTEMPTY(listValue))
						{
							set:((propertyRuntimeCollection=$$$cPROPCOLLECTIONLIST) && $LV(listValue)) listValue=$LG(listValue,1)
							$$$ThrowOnError(..GetJSONFromExtent($LB("",elementType),.jsonListValue,complete,ignoreId,listValue))
						}
					}
					else
					{
						if ($$$TypeOf(elementType,"%Status") && $$$ISSTATUS(listValue))
						{
							set jsonListValue=..GetJSONFromStatus(listValue)
						}
						elseif ($LV(listValue))
						{
							set jsonListValue=..GetJSONFromList(listValue)
						}
						else
						{
							set:$$$comMemberDefined(className,$$$cCLASSmethod,propertyName_"Normalize") listValue=$ClassMethod(className,propertyName_"Normalize",listValue)
							set jsonListValue=$$$GETJSVALUE(listValue)
						}
					}
					
					if ($$$ISNULL(jsonListValue)) { do jsonValue.%Set($S(propertyRuntimeCollection=$$$cPROPCOLLECTIONLIST:listKey-1,1:listKey),"","null") }
					elseif ($$$TypeOf(elementType,"%Boolean")) { do jsonValue.%Set($S(propertyRuntimeCollection=$$$cPROPCOLLECTIONLIST:listKey-1,1:listKey),jsonListValue,"boolean") }
					else  { do jsonValue.%Set($S(propertyRuntimeCollection=$$$cPROPCOLLECTIONLIST:listKey-1,1:listKey),jsonListValue) }
				}
			}
			elseif ((propertyRuntimeClassType=$$$cCLASSCLASSTYPEPERSISTENT) || (propertyRuntimeClassType=$$$cCLASSCLASSTYPESTREAM))
			{
				if ('$$$ISLISTEMPTY(propertyValue))
				{
					set propertyOid=$S($LV(propertyValue):$LB($LG(propertyValue,1),$LG(propertyValue,2,propertyRuntimeType),$LG(propertyValue,3)),1:$LB(propertyValue,propertyRuntimeType))
					set:((propertyRuntimeClassType=$$$cCLASSCLASSTYPESTREAM) && ($LG(propertyOid,3)="")) $LI(propertyOid,3)=$$$comMemberKeyGet(className,$$$cCLASSstorage,storageStrategy,$$$cSDEFstreamlocation)
					$$$ThrowOnError(..GetJSONFromExtent(propertyOid,.jsonValue,$CASE(propertyRuntimeClassType,$$$cCLASSCLASSTYPESTREAM:$$$YES,:$CASE(propertyRuntimeCardinality,$$$cPROPCARDINALITYONE:$$$NO,$$$cPROPCARDINALITYPARENT:$$$NO,:complete)),ignoreId))
				}
			}
			elseif (propertyRuntimeClassType=$$$cCLASSCLASSTYPESERIAL)
			{
				if ('$$$ISLISTEMPTY(propertyValue))
				{
					$$$ThrowOnError(..GetJSONFromExtent($LB("",propertyRuntimeType),.jsonValue,complete,ignoreId,propertyValue))
				}
			}
			else
			{
				if ($$$TypeOf(propertyRuntimeType,"%Status") && $$$ISSTATUS(propertyValue))
				{
					set jsonValue=..GetJSONFromStatus(propertyValue)
				}
				elseif ($LV(propertyValue))
				{
					set jsonValue=..GetJSONFromList(propertyValue)
				}
				else
				{
					set:$$$comMemberDefined(className,$$$cCLASSmethod,propertyName_"Normalize") propertyValue=$ClassMethod(className,propertyName_"Normalize",propertyValue)
					set jsonValue=$$$GETJSVALUE(propertyValue)
				}
			}
			
			if ($$$ISNULL(jsonValue)) { do json.%Set(propertyName,"","null") }
			elseif ($$$TypeOf(propertyRuntimeType,"%Boolean")) { do json.%Set(propertyName,jsonValue,"boolean") }
			else  { do json.%Set(propertyName,jsonValue) }
		}
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) json=$$$NULLOREF
	quit status
}

/// Get a JSON object from an object.
/// <ul>
/// <li>object...the object for which a JSON object shall be returned</li>
/// <li>json...the JSON object from given object</li>
/// <li>complete...true if all data from given object shall be exported, false (default) otherwise</li>
/// <li>ignodeId...true if the GUID/id from given object shall be ignored, false (default) otherwise</li>
/// <li>allowTransient...true if transient data from given object shall be exported, false (default) otherwise</li>
/// </ul>
/// Returns status OK if successfully exported JSON object from given object, any other status signals failure and the JSON object is set to null!
ClassMethod GetJSONFromObject(object As %RegisteredObject = {$$$NULLOREF}, ByRef json As %DynamicAbstractObject = {$$$NULLOREF}, complete As %Boolean = {$$$NO}, ignoreId As %Boolean = {$$$NO}, allowTransient As %Boolean = {$$$NO}) As %Status
{
	#dim status as %Status=$$$OK
	try
	{
		if ($$$ISNULL(object))
		{
			set json=$$$NULLOREF
			quit
		}
		else
		{
			$$$ThrowIf('$$$TypeOf(object,"%RegisteredObject"),"cannot create JSON from invalid object")
		}
		
		set className=object.%ClassName(1)
		set json={}.%Set($$$JSONClassName,className)
		
		set classType=$$$comClassKeyGet(className,$$$cCLASSclasstype)
		if (classType=$$$cCLASSCLASSTYPEPERSISTENT)
		{
			if ('ignoreId)
			{
				set id=object.%Id()
				set:(id'="") json.$$$JSONId=id // un-saved objects do not have an id
				set GUID=##class(%Persistent).%GUID(object.%Oid())
				set:(GUID'="") json.$$$JSONGUID=GUID // GUID disabled objects do not have a GUID
			}
			
			quit:('complete)
		}
		elseif (classType=$$$cCLASSCLASSTYPESTREAM)
		{
			if ('ignoreId)
			{
				set id=object.%Id()
				set:(id'="") json.$$$JSONId=""_id // un-saved streams do not have an id
			}
			set json.$$$JSONStreamLocation=object.%Location
			quit:('complete)
			
			$$$ThrowOnError(object.Rewind())
			set json.$$$JSONStreamSize=+object.Size
			set data=[],len=1024
			while (len>=0)
			{
				set content=object.Read(.len,.status) $$$Throw(status) $$$Break(len<0)
				do data.%Push($System.Encryption.Base64Encode($ZCVT(content,"O","UTF8")))
			}
			set json.$$$JSONStreamData=data
			
			quit
		}
		
		set collection="",cardinality=""
		if ($$$TypeOf(object,"%Collection.AbstractArray"))
		{
			set collection=$$$cPROPCOLLECTIONARRAY
			set json={}
		}
		elseif ($$$TypeOf(object,"%Collection.AbstractList"))
		{
			set collection=$$$cPROPCOLLECTIONLIST
			set json=[]
		}
		elseif ($$$TypeOf(object,"%RelationshipObject"))
		{
			set collection=$$$cPROPCOLLECTIONLIST // works like a list but in real it's an array
			set cardinality=object.Cardinality
			set json=[]
		}
		
		if (collection="")
		{
			set propertyName=""
			for
			{
				set propertyName=$$$comMemberNext(className,$$$cCLASSproperty,propertyName) $$$Break(propertyName="")
				continue:($E(propertyName,1)="%")  // ignore any system property
				continue:($$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPprivate))  // do not export private property
				continue:($$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPmultidimensional))  // do not export multidimensional property
				
				set propertyType=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPruntimetype)
				set propertyClassType=$$$comClassKeyGet(propertyType,$$$cCLASSclasstype)
				set propertyCardinality=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPcardinality)
				
				continue:(propertyCardinality=$$$cPROPCARDINALITYPARENT) // we do not export parent relations, because children are subscripts of parents!
				
				continue:('$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPstorable) && (propertyCardinality="") && 'allowTransient)  // do not export transient property
				
				set value=$Property(object,propertyName)
				if ($$$ISNULL(value))
				{
					set value=$$$NULLOREF
				}
				elseif (propertyClassType=$$$cCLASSCLASSTYPEDATATYPE)
				{
					$$$ThrowIf($IsObject(value),"cannot export object as datatype")
					
					if ($LV(value))
					{
						set value=..GetJSONFromList(value)
					}
					elseif ($ClassMethod(propertyType,"%Extends","%Status") && $$$ISSTATUS(value))
					{
						set value=..GetJSONFromStatus(value)
					}
					else
					{
						set value=$$$GETJSVALUE(value)
					}
				}
				else
				{
					$$$ThrowIf('$IsObject(value),"cannot export datatype as object")
					
					if ('$$$TypeOf(value,"%DynamicAbstractObject"))
					{
						set jvalue=$$$NULLOREF
						$$$ThrowOnError(..GetJSONFromObject(value,.jvalue,$CASE(propertyClassType,$$$cCLASSCLASSTYPESTREAM:$$$YES,:$CASE(propertyCardinality,$$$cPROPCARDINALITYONE:$$$NO,$$$cPROPCARDINALITYPARENT:$$$NO,:complete)),ignoreId,allowTransient))
						set value=jvalue
					}
				}
			
				if ($$$ISNULL(value)) { do json.%Set(propertyName,"","null") }
				elseif ($CLASSMETHOD(propertyType,"%Extends","%Boolean")) { do json.%Set(propertyName,value,"boolean") }
				else  { do json.%Set(propertyName,value) }
			}
		}
		elseif ($CASE(cardinality,"":$$$YES,$$$cPROPCARDINALITYMANY:$$$YES,$$$cPROPCARDINALITYCHILDREN:$$$YES,:$$$NO))
		{
			set elementType=object.ElementType,elementType=$$$ClassType(elementType)
			set elementClassType=$$$comClassKeyGet(elementType,$$$cCLASSclasstype)
			
			set key=""
			while ($$$YES)
			{
				set value=object.GetNext(.key) $$$Break(key="")
				
				if ($$$ISNULL(value))
				{
					set value=$$$NULLOREF
				}
				elseif (elementClassType=$$$cCLASSCLASSTYPEDATATYPE)
				{
					$$$ThrowIf($IsObject(value),"cannot export object as datatype")
					
					if ($LV(value))
					{
						set value=..GetJSONFromList(value)
					}
					elseif ($ClassMethod(elementType,"%Extends","%Status") && $$$ISSTATUS(value))
					{
						set value=..GetJSONFromStatus(value)
					}
					else
					{
						set value=$$$GETJSVALUE(value)
					}
				}
				else
				{
					$$$ThrowIf('$IsObject(value),"cannot export datatype as object")
					
					if ('$$$TypeOf(value,"%DynamicAbstractObject"))
					{
						set jvalue=$$$NULLOREF
						$$$ThrowOnError(..GetJSONFromObject(value,.jvalue,$CASE(elementClassType,$$$cCLASSCLASSTYPESTREAM:$$$YES,:complete),ignoreId,allowTransient))
						set value=jvalue
					}
				}
			
				if ($$$ISNULL(value)) { do json.%Set($S(collection=$$$cPROPCOLLECTIONLIST:key-1,1:key),"","null") }
				elseif ($CLASSMETHOD(elementType,"%Extends","%Boolean")) { do json.%Set($S(collection=$$$cPROPCOLLECTIONLIST:key-1,1:key),value,"boolean") }
				else  { do json.%Set($S(collection=$$$cPROPCOLLECTIONLIST:key-1,1:key),value) }
			}
		}
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) json=$$$NULLOREF
	quit status
}

/// Get an object from an JSON object.
/// <ul>
/// <li>json...the JSON object with class information for which an object shall be returned</li>
/// <li>object...the object from the class information</li>
/// <li>complete...true if all data from given JSON object should be imported, false (default) otherwise</li>
/// <li>ignodeId...true if the GUID/id from given JSON object shall be ignored, false (default) otherwise</li>
/// <li>allowTransient...true if transient data from given JSON object shall be imported, false (default) otherwise</li>
/// </ul>
/// Returns status OK if successfully imported object from JSON object, any other status signals failure and the object is set to null!
ClassMethod GetObjectFromJSON(json As %DynamicAbstractObject = {$$$NULLOREF}, ByRef object As %RegisteredObject = {$$$NULLOREF}, complete As %Boolean = {$$$NO}, ignoreId As %Boolean = {$$$NO}, allowTransient As %Boolean = {$$$NO}) As %Status
{
	#dim status as %Status=$$$OK
	try
	{
		if ($$$ISNULL(json))
		{
			set object=$$$NULLOREF
			quit
		}
		elseif ($$$TypeOf(json,"%DynamicArray"))
		{
			set className=$S($IsObject(object):object.%ClassName(1),1:"")
			$$$ThrowIf('($$$TypeOf(className,"%Collection.AbstractList") || $$$TypeOf(className,"%Library.RelationshipObject")),"cannot import array into unknow list class "_className)
		}
		elseif ($$$TypeOf(json,"%DynamicObject"))
		{
			set className=json.$$$JSONClassName
			if (className="")
			{
				set className=$S($IsObject(object):object.%ClassName(1),1:"")
				$$$ThrowIf('$$$TypeOf(className,"%Collection.AbstractArray"),"cannot import object into unknown array class "_className)
			}
			elseif (className=$$$JSONStatusClassName)
			{
				set object=..GetStatusFromJSON(json)
				quit
			}
		}
		else
		{
			$$$Throw("cannot create object from invalid JSON")
		}
		
		set classType=$$$comClassKeyGet(className,$$$cCLASSclasstype)
		if (classType=$$$cCLASSCLASSTYPEPERSISTENT)
		{
			set:('$$$TypeOf(object,className)) object=$$$NULLOREF
			if ('ignoreId)
			{
				set:((json.$$$JSONGUID'="") && ('$IsObject(object) || (json.$$$JSONGUID'=##class(%Persistent).%GUID(object.%Oid())))) object=##class(%Persistent).%Open(##class(%GUID).%GUIDFind(json.$$$JSONGUID))
				set:((json.$$$JSONId'="") && ('$IsObject(object) || (json.$$$JSONId'=object.%Id()))) object=$ClassMethod(className,"%OpenId",json.$$$JSONId)
			}
			set:('$IsObject(object)) object=$ClassMethod(className,"%New")
			quit:('complete)
		}
		elseif (classType=$$$cCLASSCLASSTYPESTREAM)
		{
			set location=json.$$$JSONStreamLocation,id=""
			if ('ignoreId)
			{
				set id=$S(location="":"",1:json.$$$JSONId)
				set:((id'="")&&('$D(@(location_"("_id_")")))) id="" // this id does not exist in storage
			}
			set oid=$LB(id,className,location)
			set:('$$$TypeOf(object,className) || ($LISTTOSTRING(object.%Oid())'=$LISTTOSTRING(oid))) object=##class(%Stream.Object).%Open(oid)
			if (complete)
			{
				$$$ThrowOnError(object.Rewind())
				set data=json.$$$JSONStreamData
				if ($$$TypeOf(data,"%DynamicArray"))
				{
					set iterator=data.%GetIterator()
					while (iterator.%GetNext(.cnt,.content))
					{
						do object.Write($ZCVT($System.Encryption.Base64Decode(content),"I","UTF8"))
					}
				}
				set size=+json.$$$JSONStreamSize
				$$$ThrowIf((size'=object.Size),"stream import from JSON failed (difference in size: json="_size_", stream="_object.Size_")")
			}
			quit
		}
		else
		{
			$$$InitTypeOf(object,className)
		}
		
		set collection="",cardinality=""
		if ($$$TypeOf(object,"%Collection.AbstractArray"))
		{
			$$$ThrowIf('$$$TypeOf(json,"%DynamicObject"),"cannot import array from invalid JSON object")
			set collection=$$$cPROPCOLLECTIONARRAY
		}
		elseif ($$$TypeOf(object,"%Collection.AbstractList"))
		{
			$$$ThrowIf('$$$TypeOf(json,"%DynamicArray"),"cannot import list from invalid JSON array")
			set collection=$$$cPROPCOLLECTIONLIST
		}
		elseif ($$$TypeOf(object,"%RelationshipObject"))
		{
			$$$ThrowIf('$$$TypeOf(json,"%DynamicArray"),"cannot import relation from invalid JSON array")
			set collection=$$$cPROPCOLLECTIONLIST // works like a list but in real it's an array
			set cardinality=object.Cardinality
		}
		
		if (collection="")
		{
			set propertyName=""
			for
			{
				set propertyName=$$$comMemberNext(className,$$$cCLASSproperty,propertyName) $$$Break(propertyName="")
				continue:($E(propertyName,1)="%")  // ignore any system property
				continue:($$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPprivate))  // do not import private property
				continue:($$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPmultidimensional))  // do not import multidimensional property
				continue:($$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPreadonly))  // do not import read only property
				
				set propertyCardinality=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPcardinality)
				continue:('$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPstorable) && (propertyCardinality="") && 'allowTransient)  // do not import transient property
				
				set propertyType=$$$comMemberKeyGet(className,$$$cCLASSproperty,propertyName,$$$cPROPruntimetype)
				set propertyClassType=$$$comClassKeyGet(propertyType,$$$cCLASSclasstype)
				
				set propertyValue=$Property(object,propertyName)
				set propertyCollection=$S('$IsObject(propertyValue):"",$$$TypeOf(propertyValue,"%Collection.AbstractArray"):$$$cPROPCOLLECTIONARRAY,$$$TypeOf(propertyValue,"%Collection.AbstractList"):$$$cPROPCOLLECTIONLIST,$$$TypeOf(propertyValue,"%RelationshipObject"):$$$cPROPCOLLECTIONLIST,1:"")
				
				set value=json.%Get(propertyName)
				if ($$$ISNULL(value))
				{
					set propertyValue=$$$NULLOREF
				}
				elseif (propertyClassType=$$$cCLASSCLASSTYPEDATATYPE)
				{
					if ($$$TypeOf(value,"%DynamicArray"))
					{
						set propertyValue=..GetListFromJSON(value)
					}
					elseif ($$$TypeOf(value,"%DynamicObject") && (value.$$$JSONClassName=$$$JSONStatusClassName))
					{
						set propertyValue=..GetStatusFromJSON(value)
					}
					else
					{
						$$$ThrowIf($IsObject(value),"cannot import object as datatype")
						set propertyValue=$$$GETJSVALUE(value)
						set:($$$TypeOf(propertyType,"%Library.PosixTime")) propertyValue=+propertyValue
					}
				}
				else
				{
					$$$ThrowIf('$IsObject(value),"cannot import datatype as object")
					
					if ($$$TypeOf(propertyType,"%DynamicAbstractObject"))
					{
						set propertyValue=value
					}
					else
					{
						$$$ThrowOnError(..GetObjectFromJSON(value,.propertyValue,$CASE(propertyClassType,$$$cCLASSCLASSTYPESTREAM:$$$YES,:$CASE(propertyCardinality,$$$cPROPCARDINALITYONE:$$$NO,$$$cPROPCARDINALITYPARENT:$$$NO,:complete)),ignoreId,allowTransient))
					}
				}
				set $Property(object,propertyName)=propertyValue
			}
		}
		elseif ($CASE(cardinality,"":$$$YES,$$$cPROPCARDINALITYMANY:$$$YES,$$$cPROPCARDINALITYCHILDREN:$$$YES,:$$$NO))
		{
			set elementType=object.ElementType,elementType=$$$ClassType(elementType)
			set elementClassType=$$$comClassKeyGet(elementType,$$$cCLASSclasstype)
			
			kill elementValues
			set key=""
			while ($$$YES)
			{
				set elementValue=object.GetNext(.key) quit:(key="")
				continue:('$IsObject(elementValue))
				$$$ThrowOnError(..GetJSONFromObject(elementValue,.elementKey))
				set elementKey=$S($$$TypeOf(elementKey,"%DynamicObject"):elementKey.$$$JSONClassName_"#"_elementKey.$$$JSONId_"#"_elementKey.$$$JSONGUID,1:"")
				set:($TR(elementKey,"#","")'="") elementValues(elementKey)=elementValue
			}
			
			$$$ThrowOnError(object.Clear())

			set iterator=json.%GetIterator()
			while (iterator.%GetNext(.key,.value))
			{
				continue:($CASE(json.%GetTypeOf(key),"null":$$$YES,"unassigned":$$$YES,:$$$NO)) // ignore all null/unassigned values because we cleared the array/list before iteration!
				
				if ($$$ISNULL(value))
				{
					set elementValue=$$$NULLOREF
				}
				elseif (elementClassType=$$$cCLASSCLASSTYPEDATATYPE)
				{
					if ($$$TypeOf(value,"%DynamicArray"))
					{
						set elementValue=..GetListFromJSON(value)
					}
					elseif ($$$TypeOf(value,"%DynamicObject") && (value.$$$JSONClassName=$$$JSONStatusClassName))
					{
						set elementValue=..GetStatusFromJSON(value)
					}
					else
					{
						$$$ThrowIf($IsObject(value),"cannot import object as datatype")
						set elementValue=$$$GETJSVALUE(value)
					}
				}
				else
				{
					$$$ThrowIf('$IsObject(value),"cannot import datatype as object")
					
					if ($$$TypeOf(elementType,"%DynamicAbstractObject"))
					{
						set elementValue=value
					}
					else
					{
						set elementKey=$S($$$TypeOf(value,"%DynamicObject"):value.$$$JSONClassName_"#"_value.$$$JSONId_"#"_value.$$$JSONGUID,1:"")
						set elementValue=$S(elementKey'="":$G(elementValues(elementKey),$$$NULLOREF),1:$$$NULLOREF)
						$$$ThrowOnError(..GetObjectFromJSON(value,.elementValue,$CASE(elementClassType,$$$cCLASSCLASSTYPESTREAM:$$$YES,:complete),ignoreId,allowTransient))
					}
				}
				
				if (collection=$$$cPROPCOLLECTIONLIST)
				{
					$$$ThrowOnError(object.Insert(elementValue))
				}
				else
				{
					$$$ThrowOnError(object.SetAt(elementValue,key))
				}
			}
		}
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	set:$$$ISERR(status) object=$$$NULLOREF
	quit status
}

/// Convert a list to JSON array.
/// <ul>
/// <li>list...the list to convert</li>
/// </ul>
/// Returns the JSON array or null if list is not valid!
ClassMethod GetJSONFromList(list As %List = {$$$NULLOREF}) As %DynamicArray
{
	quit:((list=$$$NULLOREF)||'$LV(list)) $$$NULLOREF
	set array=[]
	for i=1:1:$LL(list)
	{
		if ('$LD(list,i))
		{
			do array.%Push("","null")
		}
		else
		{
			set value=$LI(list,i)
			if ($LV(value)) set value=..GetJSONFromList(value)
			else  set value=$$$GETJSVALUE(value)
			do array.%Push(value)
		}
	}
	quit array
}

/// Convert a JSON array to list.
/// <ul>
/// <li>array...the JSON array to convert</li>
/// </ul>
/// Returns the list or null if JSON array is not valid!
ClassMethod GetListFromJSON(array As %DynamicArray = {$$$NULLOREF}) As %List
{
	quit:('$$$TypeOf(array,"%DynamicArray")) $$$NULLOREF
	set list=""
	set arrayIterator=array.%GetIterator()
	while (arrayIterator.%GetNext(.key,.value))
	{
		continue:($CASE(array.%GetTypeOf(key),"null":$$$YES,"unassigned":$$$YES,:$$$NO))
		if ($$$TypeOf(value,"%DynamicArray")) set value=..GetListFromJSON(value)
		else  set value=$$$GETJSVALUE(value)
		set $LI(list,key+1)=value
	}
	quit list
}

/// Convert a status to JSON object.
/// <ul>
/// <li>status...the status to convert</li>
/// </ul>
/// Returns the JSON object or null if status is not valid!
ClassMethod GetJSONFromStatus(status As %Status = {$$$NULLOREF}) As %DynamicObject
{
	quit:('$$$ISSTATUS(status)) $$$NULLOREF
	set object={}.%Set($$$JSONClassName,$$$JSONStatusClassName)
	set object.$$$JSONStatus=$S($$$ISOK(status):status,1:..GetJSONFromList($E(status,3,*)))
	quit object
}

/// Convert a JSON object to status.
/// <ul>
/// <li>object...the JSON object to convert</li>
/// </ul>
/// Returns the status or null if JSON object is not valid!
ClassMethod GetStatusFromJSON(object As %DynamicObject = {$$$NULLOREF}) As %Status
{
	quit:('$$$TypeOf(object,"%DynamicObject")) $$$NULLOREF
	quit:(object.$$$JSONClassName'=$$$JSONStatusClassName) $$$NULLOREF
	set status=object.$$$JSONStatus
	set:($$$TypeOf(status,"%DynamicArray")) status="0 "_..GetListFromJSON(status)
	quit status
}

/// Given a JSON source, parse the source (even if keys are non-strict, but every key must be first element in line),
/// ignoring single-line (// ...) and multi-line (/* ... */) comments, and return an object of type %DynamicAbstractObject.
/// <ul>
/// <li>str...the string or stream to read from.</li>
/// </ul>
/// Returns the JSON object or throws an exception on any failure!
ClassMethod %FromJSON(str As %RawString = {$$$NULLOREF}) As %DynamicAbstractObject
{
	quit:($$$ISNULL(str)) $$$NULLOREF
	if ('$IsObject(str))
	{
		set string=str,str=##class(%Stream.TmpCharacter).%New()
		$$$ThrowOnError(str.Write(string))
	}
	else
	{
		$$$ThrowIf('$$$TypeOf(str,"%Stream.Object"),"cannot read JSON from invalid stream "_stream)
	}
	
	$$$ThrowOnError(str.Rewind())
	
	set inJsonObject=0
	set inComment=$$$NO
	set inFunction=$$$NO
	set jsonStream=##class(%Stream.TmpCharacter).%New()
	while ('str.AtEnd)
	{
		set line=$ZSTRIP(str.ReadLine(,.status,.eol),"<>W") $$$ThrowOnError(status)
		continue:(line="")
		
		set comment=$F(line,"//")
		set:(comment) line=$ZSTRIP($E(line,1,comment-3),">W")
		continue:(line="")
		
		set startComment=$F(line,"/*")
		set endComment=$F(line,"*/")
		while (inComment || (startComment || endComment))
		{
			if (endComment > 0)  // line contains ... */ ...
			{
				if (endComment < startComment)  // line starts with ... */ ... 
				{
					set line=$E(line,endComment,*)
					set endComment=$F(line,"*/")
				}
				else  // line contains [... /*] ... */ ...
				{
					set line=$E(line,1,startComment-3)_$E(line,endComment,*)
					set startComment=$F(line,"/*")
					set endComment=$F(line,"*/")
				}
				set inComment=$$$NO
			}
			else  // line contains ... /* ...
			{
				set line=$E(line,1,startComment-3)
				set inComment=$$$YES
				quit
			}
		}
		set line=$ZSTRIP(line,"<>W")
		continue:(line="")
		
		if ('inJsonObject)
		{
			set inJsonObject=$S($E(line,1)="{":1,1:2)
			if (inJsonObject=2)
			{
				$$$ThrowOnError(jsonStream.Write("{"))
			}
		}

		if (inFunction)
		{
			set inFunction=inFunction+$L(line,"{")-$L(line,"}")
			if ('inFunction)
			{
				set line=","""_$ZCVT($S($E(line,*)=",":$E(line,1,*-1),1:line),"O","JSON")_"""]"_$S($E(line,*)=",":",",1:"")
			}
			else
			{
				set line=","""_$ZCVT(line,"O","JSON")_""""
			}
		}
		else
		{
			set key=$S($F(line,":"):$ZSTRIP($P(line,":",1),">W"),1:"")
			if ('$$$ISNULL(key))
			{
				set line=$E(line,$L(key)+1,*)
				set qStart=$F("""",$E(key,1))
				set qEnd=$F("""",$E(key,*))
				set:('(qStart || qEnd)) key=""""_key_""""
				
				if ($E($ZSTRIP($P(line,":",2,*),"<W"),1,8)="function")
				{
					set inFunction=$L(line,"{")-$L(line,"}")
					set line=$P(line,":",1)_":["""_$ZCVT($ZSTRIP($P(line,":",2,*),"<W"),"O","JSON")
					if ('inFunction)
					{
						set $E(line,*)="""]"_$S($E(line,*)=",":",",1:"")
					}
					else
					{
						set line=line_""""
					}
				}
				else
				{
					set line=$REPLACE($TR($REPLACE(line,"\'",$$$NULL),"'",""""),$$$NULL,"\'") // convert single-quotes to double-quotes
				}
				
				set line=key_line
			}
			else
			{
				set line=$REPLACE($TR($REPLACE(line,"\'",$$$NULL),"'",""""),$$$NULL,"\'") // convert single-quotes to double-quotes
			}
		}
		
		$$$ThrowOnError(jsonStream.Write(line_$S(eol:str.LineTerminator,1:"")))
	}
	if (inJsonObject=2)
	{
		$$$ThrowOnError(jsonStream.Write("}"))
	}
	$$$ThrowOnError(jsonStream.Rewind())
	quit ##class(%DynamicAbstractObject).%FromJSON(jsonStream)
}

/// Convert a %DynamicAbstractObject into a formatted JSON string.
/// <ul>
/// <li>json...the json data to write.</li>
/// <li>stream...the stream to write into.</li>
/// <li>indent...the indent characters to write.</li>
/// <li>indentLevel...the indent level.</li>
/// </ul>
/// Returns status OK if successfully written JSON data to stream / device, any other status signals failure!
ClassMethod %ToJSON(json As %DynamicAbstractObject = {$$$NULLOREF}, ByRef stream As %Stream.Object, indent As %String = {$C(9)}, indentLevel As %Integer = 0) As %Status
{
	set outputToCurrentDevice=$$$NO,outputToFile=$$$NO
	set:('$D(stream)) outputToCurrentDevice=$$$YES,stream=$$$NULLOREF
	set:($$$ISNULL(stream)) stream=##class(%Stream.TmpCharacter).%New()
	if ('$IsObject(stream))
	{
		set filename=stream,outputToFile=$$$YES
		set stream=##class(%Stream.FileCharacter).%New()
		set stream.TranslateTable = "UTF8"
		$$$QuitOnError(stream.LinkToFile(filename))
		$$$QuitOnError(stream.Rewind())
	}
	elseif ('$$$TypeOf(stream,"%Stream.Object"))
	{
		quit $$$ERROR($$$GeneralError,"cannot write JSON to invalid stream "_stream)
	}
	
	#dim status as %Status = $$$OK
	try
	{
		if ('$IsObject(json))
		{
			$$$ThrowOnError(stream.Write("null"))
			quit
		}
		
		set jsonType=$S($$$TypeOf(json,"%DynamicObject"):"object",$$$TypeOf(json,"%DynamicArray"):"array",1:"oref")
		$$$ThrowIf(jsonType="oref","cannot write non JSON object to stream")
		
		set indentString="",lineCount=0
		set:(indent'="") $P(indentString,indent,indentLevel+1)=""

		$$$ThrowOnError(stream.Write($S(jsonType="object":"{",1:"[")))
		if (indent'="")
		{
			$$$ThrowOnError(stream.WriteLine())
		}
		
		set iterator=json.%GetIterator()
		while (iterator.%GetNext(.key,.value))
		{
			if ($I(lineCount)>1)
			{
				if (indent'="")
				{
					$$$ThrowOnError(stream.WriteLine(","))
				}
				else
				{
					$$$ThrowOnError(stream.Write(", "))
				}
			}
			$$$ThrowOnError(stream.Write(indentString_indent))
			
			if (jsonType="object")
			{
				$$$ThrowOnError(stream.Write(""""_$ZCVT(key,"O","JSON")_""": "))
			}
			
			set type=json.%GetTypeOf(key)
			if ((type="array") || (type="object"))
			{
				$$$ThrowOnError(..%ToJSON(value,stream,indent,indentLevel+1))
			}
			elseif (type="oref")
			{
				$$$ThrowIf('$$$TypeOf(value,"%Stream.Object"),"cannot write IRIS object to stream")
				
				$$$ThrowOnError(stream.Write(""""))
				$$$ThrowOnError(value.Rewind())
				while ('value.AtEnd)
				{
					set line=value.ReadLine(,.status,.eol) $$$Throw(status)
					continue:(line="")
					$$$ThrowOnError(stream.Write($ZCVT(line_$S(eol:value.LineTerminator,1:""),"O","JSON")))
				}
				$$$ThrowOnError(stream.Write(""""))
			}
			else
			{
				if ((type="boolean") || (value="true") || (value="false"))
				{
					$$$ThrowOnError(stream.Write($S((value="true")||value:"true",1:"false")))
				}
				elseif ((type="null") || (value=$$$NULL) || (value="null"))
				{
					$$$ThrowOnError(stream.Write("null"))
				}
				elseif ((type="number") && $$$ISJSNUMERIC(value))
				{
					$$$ThrowOnError(stream.Write(+value))
				}
				elseif ($$$ISLIST(value))
				{
					$$$ThrowOnError(..%ToJSON($$$JSON.GetJSONFromList(value),stream,indent,indentLevel+1))
				}
				else
				{
					set:($$$ISSTATUS(value)) value=$System.Status.GetErrorText(value)
					$$$ThrowOnError(stream.Write(""""_$ZCVT(value,"O","JSON")_""""))
				}
			}
		}
		
		if ((lineCount>0) && (indent'=""))
		{
			$$$ThrowOnError(stream.WriteLine())
		}
		
		$$$ThrowOnError(stream.Write(indentString_$S(jsonType="object":"}",1:"]")))
	}
	catch (exc)
	{
		set status=exc.AsStatus()
	}
	$$$Quit(status)
	
	if (outputToCurrentDevice)
	{
		$$$QuitOnError(stream.OutputToDevice())
	}
	elseif (outputToFile)
	{
		$$$QuitOnError(stream.%Save())
	}
	quit $$$OK
}

}
