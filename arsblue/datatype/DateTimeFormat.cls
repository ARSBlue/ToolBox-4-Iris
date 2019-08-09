Include arsblue.datatype.Include

/// Date/Time format class to dynamically create date/time representations.
/// Valid format patterns (case-sensitive!):<ul>
/// <li>y...year (yyyy=4-digit or yy=2-digit representation)</li>
/// <li>M...month in year (M=1-digit, MM=2-digit, MMM=3-letter or MMMM=full-month-name representation)</li>
/// <li>d...day in month (d=1-digit or dd=2-digit representation)</li>
/// <li>w...week in year (w=1-digit or ww=2-digit representation)</li>
/// <li>E...day name in week (E=1-letter, EE=2-letter, EEE=3-letter or EEEE=full-weekday-name representation)</li>
/// <li>u...day in week (1-7 equals Monday-Sunday, u=1-digit representation)</li>
/// <li>H...hour in day (0-23, H=1-digit or HH=2-digit representation)</li>
/// <li>m...minute in hour (m=1-digit or mm=2-digit representation)</li>
/// <li>s...second in minute (s=1-digit or ss=2-digit representation)</li>
/// <li>S...millisecond (S...=1-4 digit representation)</li>
/// <li>$H...IRIS Date,Time format (single format pattern!)</li>
/// <li>$HD...IRIS Date format (single format pattern!)</li>
/// <li>$HT...IRIS Time format (single format pattern!)</li>
/// <li>$ZTS...IRIS Timestamp format (Date,Time.Milliseconds - single format pattern!)</li>
/// </ul>
/// NOTE: if using 1-digit format pattern of possible 2-digit values a valid separator character MUST be in front of/behind format pattern!
/// NOTE: if using 1-full letter format patterns a valid separator character MUST be in front of/behind format pattern!
/// This list is inspired by java.text.SimpleDateFormat!<br/>
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.datatype.DateTimeFormat Extends %RegisteredObject [ Abstract ]
{

/// Validate datatype with format patterns.
/// NOTE: general format will be checked, but only relevant information (patterns: y, M, d, w, H, m, s, S, $H, $HD, $HT and $ZTS) will be checked for valid values!
/// <ul>
/// <li>format...the format pattern to validate.</li>
/// </ul>
/// Returns status OK if successfully validated datatype, any other status signals failure!
ClassMethod ValidateDataType(format As %String = "") As %Status
{
	do %code.WriteLine("	// validate value for "_format)
	if ('%class.ProcedureBlock) do %code.WriteLine("	new (%val)")
	
	$$$QuitOnError(..ParseFormatPattern(format,.patterns))

	set match=""
	for pos=1:1:$L(format)
	{
		set pattern=$G(patterns(0,pos))
		if (pattern="") // not a pattern -> add character
		{
			set:($E(match,*)'="""") match=match_"1"""""
			set $E(match,*)=$E(format,pos)_""""
			continue
		}
		set pos=pos+$L(pattern)-1
		set match=match_$CASE(pattern,"MMMM":"3.A","MMM":"3A","M":"1.2N","d":"1.2N","w":"1.2N","EEEE":"3.A","EEE":"3A","EE":"2A","E":"1A",
		                              "$H":"1.7N1"",""1.5N","$HD":"1.7N","$HT":"1.5N","$ZTS":"1.7N1"",""1.5N1"".""1.6N","SSSS":"1.6N","SSS":"1.6N","SS":"1.6N","S":"1.6N",
		                              :$L(pattern)_"N")
	}
	do %code.WriteLine("	$$$QuitIf(%val'?"_match_",""invalid value (""_%val_"") does not match format "_format_""")")
	
	set year=$G(patterns(2,"yyyy"))
	if (year="")
	{
		set year=$G(patterns(2,"yy"))
		set:(year'="") year="""20""_"_year
	}
	set month=$G(patterns(2,"MM"),$G(patterns(2,"M")))
	set day=$G(patterns(2,"dd"),$G(patterns(2,"d")))
	if (month'="")
	{
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_month_",,1,12),""invalid number of months in year"")")
		if (day'="")
		{
			do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_day_",,1,"_$S(year="":"$LI($LFS(""31,29,31,30,31,30,31,31,30,31,30,31""),"_month_")",1:"##class(arsblue.util.Calendar).GetDaysInMonth("_year_","_month_")")_"),""invalid number of days in month"")")
			do:(year'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM(("_year_"*10000)+("_month_"*100)+"_day_",,18401231,99991231),""invalid date range (31/12/1840 - 31/12/9999)"")")
		}
		else
		{
			do:(year'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM(("_year_"*100)+"_month_",,184012,999912),""invalid date range (12/1840 - 12/9999)"")")
		}
	}
	set week=$G(patterns(2,"ww"),$G(patterns(2,"w")))
	if (week'="")
	{
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_week_",,1,"_$S(year="":53,1:"##class(arsblue.util.Calendar).GetWeeksInYear("_year_")")_"),""invalid number of weeks in year"")")
		do:(year'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM(("_year_"*100)+"_week_",,184053,999952),""invalid date range (1840/53 - 9999/52)"")")
	}
	elseif (month="")
	{
		do:(year'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_year_",,1840,9999),""invalid date range (1840 - 9999)"")")
	}
	set var=$G(patterns(2,"HH"),$G(patterns(2,"H")))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,23),""invalid number of hours"")")
	set var=$G(patterns(2,"mm"),$G(patterns(2,"m")))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,59),""invalid number of minutes"")")
	set var=$G(patterns(2,"ss"),$G(patterns(2,"s")))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,59),""invalid number of seconds"")")
	set var=$G(patterns(2,"SSSS"),$G(patterns(2,"SSS"),$G(patterns(2,"SS"),$G(patterns(2,"S")))))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,999999),""invalid number of milliseconds"")")
	set var=$G(patterns(2,"$H"))
	if (var'="")
	{
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM($P("_var_","","",1),,0,2980013),""invalid date range (0 - 2980013)"")")
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM($P("_var_","","",2),,0,86399),""invalid time range (0 - 86399)"")")
	}
	set var=$G(patterns(2,"$HD"))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,2980013),""invalid date range (0 - 2980013)"")")
	set var=$G(patterns(2,"$HT"))
	do:(var'="") %code.WriteLine("	$$$QuitIf('$ISVALIDNUM("_var_",,0,86399),""invalid time range (0 - 86399)"")")
	set var=$G(patterns(2,"$ZTS"))
	if (var'="")
	{
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM($P("_var_","","",1),,0,2980013),""invalid date range (0 - 2980013)"")")
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM($P($P("_var_",""."",1),"","",2),,0,86399),""invalid time range (0 - 86399)"")")
		do %code.WriteLine("	$$$QuitIf('$ISVALIDNUM($P("_var_",""."",2),,0,999999),""invalid time range (0 - 86399)"")")
	}
	
	quit $$$OK
}

/// Format datatype from source to target.
/// <ul>
/// <li>sourceFormat...the source format patterns.</li>
/// <li>targetFormat...the target format patterns.</li>
/// </ul>
/// Returns status OK if successfully transformed from source to target format, any other status signals failure!
ClassMethod FormatDataType(sourceFormat As %String = "", targetFormat As %String = "") As %Status
{
	do %code.WriteLine("	// convert value from "_sourceFormat_" to "_targetFormat)
	if ('%class.ProcedureBlock) do %code.WriteLine("	new (%val)")

	$$$QuitOnError(..ParseFormatPattern(sourceFormat,.sourcePatterns))
	$$$QuitOnError(..ParseFormatPattern(targetFormat,.targetPatterns))
	
	if ($CASE($TR(sourceFormat,"yMdHmsSw",""),".":$$$YES,"":$$$YES,:$$$NO))
	{
		set FillPattern=$TR(sourceFormat,"yMdHmsSw","00000000")
		set PreComma=$L($P(FillPattern,".",1),"0")-1
		set PostComma=$L($P(FillPattern,".",2),"0")-1
		do:(PreComma) %code.WriteLine("	set:(%val'?"_PreComma_"N"_$S(PostComma:".1""."".N",1:"")_") %val=$E("""_$P(FillPattern,".",1)_""",1,*-$L("_$S(PostComma:"$P(%val,""."",1)",1:"%val")_"))_%val")
		do:(PostComma) %code.WriteLine("	set:(%val'?"_$S(PreComma:PreComma_"N1"".""",1:"")_PostComma_"N) $P(%val,""."",2)=$P(%val,""."",2)_$E("""_$P(FillPattern,".",2)_""",1,*-$L($P(%val,""."",2)))")
	}
	
	set initString=""
	for val=1:1:$G(sourcePatterns(1),0)
	{
		set initString=initString_$S(initString="":"",1:",")_"%val("_val_")="_sourcePatterns(1,val)
	}
	do:(initString'="") %code.WriteLine("	set "_initString)
	
	set formatString=""
	for targetPos=1:1:$L(targetFormat)
	{
		set pattern=$G(targetPatterns(0,targetPos))
		if (pattern="") // not a pattern -> add character
		{
			set:($E(formatString,*)'="""") formatString=formatString_$S(formatString="":"",1:"_")_""""""
			set $E(formatString,*)=$E(targetFormat,targetPos)_""""
			continue
		}
		set targetPos=targetPos+$L(pattern)-1
		
		set string=$G(sourcePatterns(2,pattern))
		if (string="") // need to calculate the pattern value
		{
			$$$ReturnOnError(..CalcFormatPattern(pattern,.sourcePatterns))
			set string=$G(sourcePatterns(2,pattern))
		}
		set formatString=formatString_$S(formatString="":"",1:"_")_string
	}
	do:(formatString'="") %code.WriteLine("	set %val="_formatString)
	
	quit $$$OK
}

/// Parse format patterns.
/// <ul>
/// <li>format...the format patterns to parse.</li>
/// <li>patterns...the parsed format patterns (by reference).</li>
/// </ul>
/// Returns status OK if successfully parsed format patterns, any oter status signals failure!
ClassMethod ParseFormatPattern(format As %String = "", ByRef patterns) As %Status
{
	// valid patterns must be sorted by length (from max. to min. possible format pattern)
	set validPatterns=$LB("yyyy","yy","MMMM","MMM","MM","M","dd","d","ww","w","EEEE","EEE","EE","E","u") // valid date format patterns
	set validPatterns=validPatterns_$LB("$HD","$HT","$H","$ZTS","HH","H","mm","m","ss","s","SSSS","SSS","SS","S") // valid time format patterns
	
	kill patterns
	set patterns=format
	
	// get all patterns and leave constant values
	for i=1:1:$LL(validPatterns)
	{
		set pattern=$LI(validPatterns,i)
		set patternReplace="",$P(patternReplace,$$$NULL,$L(pattern)+1)=""
		
		while ($$$YES)
		{
			set posB=$F(patterns,pattern)-1 $$$Break(posB<=0)
			set posA=posB-$L(pattern)+1
			set patterns(0,posA)=pattern
			set:'$D(patterns(4,pattern)) patterns(4,pattern)=posA
			set $E(patterns,posA,posB)=patternReplace
		}
	}
	
	// check for single format patterns
	for sfp="$H","$HD","$HT","$ZTS"
	{
		$$$ReturnIf($D(patterns(4,sfp))&&($L(patterns)'=$L(sfp)),"invalid format "_format_" ("_sfp_" is a single format pattern)")
		if ($D(patterns(4,sfp)))
		{
			set patterns(2,sfp)="%val"
			Return $$$OK
		}
	}
	
	// check for variable formats
	set valString="%val"
	set offset=0,offString=format
	set pos=""
	while ($$$YES)
	{
		set pos=$O(patterns(0,pos),1,pattern) $$$Break(pos="")
		if ($CASE(pattern,"MMMM":$$$YES,"M":$$$YES,"d":$$$YES,"w":$$$YES,"EEEE":$$$YES,
		                  "H":$$$YES,"m":$$$YES,"s":$$$YES,"SSSS":$$$YES,"SSS":$$$YES,"SS":$$$YES,"S":$$$YES,:$$$NO)) // get pattern value with $Piece function
		{
			set separator=$E(patterns,pos-1)
			$$$ReturnIf(separator=$$$NULL,"invalid format "_format_" (no valid separator character in front of format pattern "_pattern_")")
			
			set piece=$L($E(offString,1,$F(offString,pattern)-$L(pattern)),separator)
			set string=$S(piece:"$P("_valString_","""_separator_""","_piece_",*)",1:valString)
			set offString=$S(piece:$P(offString,separator,piece,*),1:offString)
			
			set separator=$E(patterns,pos+$L(pattern))
			$$$ReturnIf(separator=$$$NULL,"invalid format "_format_" (no valid separator character behind format pattern "_pattern_")")
			
			set patterns(2,pattern)=$S($E(pattern)="S":"$E(",1:"")_$S(separator="":string,1:"$P("_string_","""_separator_""",1)")_$S($E(pattern)="S":",1,"_$L(pattern)_")",1:"")
			set offString=$S(separator="":"",1:$P(offString,separator,2,*))
			set offset=$L(patterns)-$L(offString)
			
			set:(offString'="") patterns(1,$I(patterns(1)))=$S(separator="":string,1:"$P("_string_","""_separator_""",2,*)"),valString="%val("_patterns(1)_")"
		}
		else  // get pattern value with $Extract function
		{
			set patterns(2,pattern)="$E("_valString_","_(pos-offset)_","_(pos+$L(pattern)-1-offset)_")"
		}
	}
	
	quit $$$OK
}

/// Calculate missing patterns
/// <ul>
/// <li>pattern...the missing pattern.</li>
/// <li>patterns...the available patterns (by reference).</li>
/// </ul>
/// Returns status OK if successfully created missing patterns, any other status signals failure.
ClassMethod CalcFormatPattern(pattern As %String = "", ByRef patterns) As %Status
{
	quit:($D(patterns(2,pattern))) $$$OK
	
	if ($CASE(pattern,"yy":$$$YES,"yyyy":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"yy":"yyyy",:"yy")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$CASE(pattern,"yy":"$E("_string_",3,4)",:"""20"""_string)
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HD"),$G(patterns(2,"$ZTS"))))
		set:(string="") string="+$H"
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="$E($ZD("_string_",8),"_$CASE(pattern,"yy":3,:1)_",4)"
		quit $$$OK
	}
	elseif ($CASE(pattern,"M":$$$YES,"MM":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"M":"MM",:"M")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="M":"(+",1:"$E(100+")_string_$S(pattern="M":")",1:",2,3)")
			quit $$$OK
		}
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		set string=$G(patterns(2,"ww"),$G(patterns(2,"w")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="M":"(+",1:"")_"$E(##class(arsblue.util.Calendar).GetFirstDayInWeekInYear("_$G(patterns(2,"yyyy"))_"_"_string_"),5,6)"_$S(pattern="M":")",1:"")
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HD"),$G(patterns(2,"$ZTS"))))
		set:(string="") string="+$H"
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="M":"(+",1:"")_"$E($ZD("_string_",8),5,6)"_$S(pattern="M":")",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"MMM":$$$YES,"MMMM":$$$YES,:$$$NO))
	{
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="$LG($LFS("""_$S(pattern="MMM":$$$NLSMonthAbbr,1:$$$NLSMonthName)_"""),+"_$G(patterns(2,"MM"))_")"
		quit $$$OK
	}
	elseif ($CASE(pattern,"d":$$$YES,"dd":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"d":"dd",:"d")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="d":"(+",1:"$E(100+")_string_$S(pattern="d":")",1:",2,3)")
			quit $$$OK
		}
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		set string=$G(patterns(2,"ww"),$G(patterns(2,"w")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="d":"(+",1:"")_"$E(##class(arsblue.util.Calendar).GetFirstDayInWeekInYear("_$G(patterns(2,"yyyy"))_"_"_string_"),7,8)"_$S(pattern="d":")",1:"")
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HD"),$G(patterns(2,"$ZTS"))))
		set:(string="") string="+$H"
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="d":"(+",1:"")_"$E($ZD("_string_",8),7,8)"_$S(pattern="d":")",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"w":$$$YES,"ww":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"w":"ww",:"w")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="w":"(+",1:"$E(100+")_string_$S(pattern="w":")",1:",2,3)")
			quit $$$OK
		}
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		$$$QuitOnError(..CalcFormatPattern("dd",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="w":"",1:"")_"##class(arsblue.util.Calendar).GetWeekInYear("_$G(patterns(2,"yyyy"))_","_$G(patterns(2,"MM"))_","_$G(patterns(2,"dd"))_")"_$S(pattern="w":"",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"E":$$$YES,"EE":$$$YES,"EEE":$$$YES,"EEEE":$$$YES,:$$$NO))
	{
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		$$$QuitOnError(..CalcFormatPattern("dd",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S((pattern="E")||(pattern="EE"):"$E(",1:"")_"$LG($LFS("""_$CASE(pattern,"EEEE":$$$NLSWeekdayName,:$$$NLSWeekdayAbbr)_"""),##class(arsblue.util.Calendar).GetDayInWeek("_$G(patterns(2,"yyyy"))_","_$G(patterns(2,"MM"))_","_$G(patterns(2,"dd"))_"))"_$S((pattern="E")||(pattern="EE"):",1,"_$L(pattern)_")",1:"")
		quit $$$OK
	}
	elseif (pattern="u")
	{
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		$$$QuitOnError(..CalcFormatPattern("dd",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="##class(arsblue.util.Calendar).GetDayInWeek("_$G(patterns(2,"yyyy"))_","_$G(patterns(2,"MM"))_","_$G(patterns(2,"dd"))_")"
		quit $$$OK
	}
	elseif ($CASE(pattern,"H":$$$YES,"HH":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"H":"HH",:"H")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="H":"(+",1:"$E(100+")_string_$S(pattern="H":")",1:",2,3)")
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HT"),$G(patterns(2,"$ZTS"))))
		set:(string="") string=$S($D(patterns(2,"$HT")):"$P($P($ZU(188),"","",2),""."",1)",1:"$ZU(188)")
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="H":"(+",1:"")_"$E($ZT("_$S($D(patterns(2,"$HT")):string,1:"$P($P("_string_","","",2),""."",1)")_",1),1,2)"_$S(pattern="H":")",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"m":$$$YES,"mm":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"m":"mm",:"m")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="m":"(+",1:"$E(100+")_string_$S(pattern="m":")",1:",2,3)")
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HT"),$G(patterns(2,"$ZTS"))))
		set:(string="") string=$S($D(patterns(2,"$HT")):"$P($P($ZU(188),"","",2),""."",1)",1:"$ZU(188)")
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="m":"(+",1:"")_"$E($ZT("_$S($D(patterns(2,"$HT")):string,1:"$P($P("_string_","","",2),""."",1)")_",1),4,5)"_$S(pattern="m":")",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"s":$$$YES,"ss":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,$CASE(pattern,"s":"ss",:"s")))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="s":"(+",1:"$E(100+")_string_$S(pattern="s":")",1:",2,3)")
			quit $$$OK
		}
		set string=$G(patterns(2,"$H"),$G(patterns(2,"$HT"),$G(patterns(2,"$ZTS"))))
		set:(string="") string=$S($D(patterns(2,"$HT")):"$P($P($ZU(188),"","",2),""."",1)",1:"$ZU(188)")
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)=$S(pattern="s":"(+",1:"")_"$E($ZT("_$S($D(patterns(2,"$HT")):string,1:"$P($P("_string_","","",2),""."",1)")_",1),7,8)"_$S(pattern="s":")",1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"S":$$$YES,"SS":$$$YES,"SSS":$$$YES,"SSSS":$$$YES,:$$$NO))
	{
		set string=$G(patterns(2,"SSSS"),$G(patterns(2,"SSS"),$G(patterns(2,"SS"),$G(patterns(2,"S")))))
		if (string'="")
		{
			set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="(+$E("_string_",1,"_$L(pattern)_"))"
			quit $$$OK
		}
		set string=$G(patterns(2,"$ZTS"))
		set:(string="") string="$ZU(188)"
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="(+$E($P("_string_",""."",2),1,"_$L(pattern)_"))"
		quit $$$OK
	}
	elseif ($CASE(pattern,"$H":$$$YES,"$ZTS":$$$YES,:$$$NO))
	{
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		$$$QuitOnError(..CalcFormatPattern("dd",.patterns))
		$$$QuitOnError(..CalcFormatPattern("HH",.patterns))
		$$$QuitOnError(..CalcFormatPattern("mm",.patterns))
		$$$QuitOnError(..CalcFormatPattern("ss",.patterns))
		$$$QuitOnError(..CalcFormatPattern("SSS",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="##class(arsblue.util.Calendar).GetDateHorolog("_$G(patterns(2,"yyyy"))_","_$G(patterns(2,"MM"))_","_$G(patterns(2,"dd"))_")_"",""_##class(arsblue.util.Calendar).GetTimeHorolog("_$G(patterns(2,"HH"))_","_$G(patterns(2,"mm"))_","_$G(patterns(2,"ss"))_")"_$S(pattern="$ZTS":"_"".""_"_$G(patterns(2,"SSS")),1:"")
		quit $$$OK
	}
	elseif ($CASE(pattern,"$HD":$$$YES,:$$$NO))
	{
		$$$QuitOnError(..CalcFormatPattern("yyyy",.patterns))
		$$$QuitOnError(..CalcFormatPattern("MM",.patterns))
		$$$QuitOnError(..CalcFormatPattern("dd",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="##class(arsblue.util.Calendar).GetDateHorolog("_$G(patterns(2,"yyyy"))_","_$G(patterns(2,"MM"))_","_$G(patterns(2,"dd"))_")"
		quit $$$OK
	}
	elseif ($CASE(pattern,"$HT":$$$YES,:$$$NO))
	{
		$$$QuitOnError(..CalcFormatPattern("HH",.patterns))
		$$$QuitOnError(..CalcFormatPattern("mm",.patterns))
		$$$QuitOnError(..CalcFormatPattern("ss",.patterns))
		set patterns(3,$I(patterns(3)))=pattern,patterns(2,pattern)="##class(arsblue.util.Calendar).GetTimeHorolog("_$G(patterns(2,"HH"))_","_$G(patterns(2,"mm"))_","_$G(patterns(2,"ss"))_")"
		quit $$$OK
	}
	$$$QuitError("invalid format (cannot calculate "_pattern_" from format patterns)")
}

/// Get timestamp display format
/// NOTE: this is a workaround because macros in datatype within parameters are not working!
ClassMethod GetTimeStampDisplayFormat() As %String
{
	quit $$$TimeStampDisplayFormat
}

/// Get datetime display format
/// NOTE: this is a workaround because macros in datatype within parameters are not working!
ClassMethod GetDateTimeDisplayFormat() As %String
{
	quit $$$DateTimeDisplayFormat
}

/// Get date display format
/// NOTE: this is a workaround because macros in datatype within parameters are not working!
ClassMethod GetDateDisplayFormat() As %String
{
	quit $$$DateDisplayFormat
}

/// Get time display format
/// NOTE: this is a workaround because macros in datatype within parameters are not working!
ClassMethod GetTimeDisplayFormat() As %String
{
	quit $$$TimeDisplayFormat
}

}
