Include arsblue.datatype.Include

/// This class contains all functions around date and time
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.util.Calendar Extends %RegisteredObject [ Abstract ]
{

/// Check date (yyyy...year, MM...month, dd...day in month, ww...week in year)
ClassMethod CheckDate(ByRef yyyy As %String = "", ByRef MM As %String = "", ByRef dd As %String = "", ByRef ww As %String = "") As %Status
{
	if (yyyy'="")
	{
		set:($L(yyyy)=8) MM=$E(yyyy,5,6),dd=$E(yyyy,7,8),yyyy=$E(yyyy,1,4) // yyyyMMdd in yyyy
		set:($L(yyyy)=6) ww=$E(yyyy,5,6),yyyy=$E(yyyy,1,4) // yyyyww in yyyy
		set:($L(yyyy)<4) yyyy=$E(2000,1,4-$L(yyyy))_yyyy
		quit:(yyyy'?4N || '$ISVALIDNUM(yyyy,,1840,9999)) $$$ERROR($$$GeneralError,"invalid year "_yyyy)
	}
	if (MM'="")
	{
		set:($L(MM)<2) MM="0"_MM
		quit:(MM'?2N || '$ISVALIDNUM(MM,,1,12)) $$$ERROR($$$GeneralError,"invalid month "_MM)
	}
	if (dd'="")
	{
		set:($L(dd)<2) dd="0"_dd
		quit:(dd'?2N || '$ISVALIDNUM(dd,,1,31)) $$$ERROR($$$GeneralError,"invalid day "_dd)
	}
	if (ww'="")
	{
		set:($L(ww)<2) ww="0"_ww
		quit:(ww'?2N || '$ISVALIDNUM(ww,,1,53)) $$$ERROR($$$GeneralError,"invalid week "_ww)
	}
	quit $$$OK
}

/// Get date from horolog (yyyyMMdd)
ClassMethod GetDate(horolog As %Integer = -1) As %String
{
	quit:(horolog'?1.7N && '$ISVALIDNUM(horolog,,0,2980013)) ""
	quit $ZD(horolog,8)
}

/// Get date ($H1)
ClassMethod GetDateHorolog(yyyy As %Integer = 0, MM As %Integer = 0, dd As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,.MM,.dd)) -1
	quit $ZDH(yyyy_MM_dd,8)
}

/// Check time (HH...hour, mm...minute, ss...second)
ClassMethod CheckTime(ByRef HH As %String = "", ByRef mm As %String = "", ByRef ss As %String = "", ByRef SSSSSS As %String = "") As %Status
{
	if (HH'="")
	{
		set:($L(HH)=6) mm=$E(HH,3,4),ss=$E(HH,5,6),HH=$E(HH,1,2) // HHmmss in HH
		set:($L(HH)<2) HH="0"_HH
		quit:(HH'?2N || '$ISVALIDNUM(HH,,0,23)) $$$ERROR($$$GeneralError,"invalid hour "_HH)
	}
	if (mm'="")
	{
		set:($L(mm)<2) mm="0"_mm
		quit:(mm'?2N || '$ISVALIDNUM(mm,,0,59)) $$$ERROR($$$GeneralError,"invalid minute "_mm)
	}
	if (ss'="")
	{
		set:($L(ss)<2) ss="0"_ss
		quit:(ss'?2N || '$ISVALIDNUM(ss,,0,59)) $$$ERROR($$$GeneralError,"invalid second "_ss)
	}
	if (SSSSSS'="")
	{
		set:($L(SSSSSS)<6) SSSSSS=SSSSSS_$E("000000",1,6-$L(SSSSSS)) // milliseconds must be expanded at the end!
		quit:(SSSSSS'?1.6N || '$ISVALIDNUM(SSSS,,0,999999)) $$$ERROR($$$GeneralError,"invalid millisecond "_SSSSSS)
	}
	quit $$$OK
}

/// Get tiem from horolog (HHmmss)
ClassMethod GetTime(horolog As %Integer = -1) As %String
{
	quit:(horolog'?1.5N && '$ISVALIDNUM(horolog,,0,86399)) ""
	quit $TR($ZT(horolog,1),":","")
}

/// Get time ($H2)
ClassMethod GetTimeHorolog(HH As %Integer = 0, mm As %Integer = 0, ss As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckTime(.HH,.mm,.ss)) -1
	quit $ZTH(HH_":"_mm_":"_ss,1)
}

/// Check leap year (true/false)
ClassMethod IsLeapYear(yyyy As %Integer = 0) As %Boolean
{
	do ..CheckDate(.yyyy) // it doesn't matter if year is out of range => leap year works everytime
	quit ((yyyy#4)=0)&&(((yyyy#100)'=0)||((yyyy#400)=0))
}

/// Get days in month/year (dd)
ClassMethod GetDaysInMonth(yyyy As %Integer = 0, MM As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,.MM)) 0
    quit 30+((MM+(MM\8))#2)-$S(+MM=2:2-$S(..IsLeapYear(yyyy):1,1:0),1:0)
}

/// Get weeks in year (ww)
ClassMethod GetWeeksInYear(yyyy As %Integer = 0) As %Integer
{
 	quit:$$$ISERR(..CheckDate(.yyyy)) 0
 	quit:(yyyy=1840) 53 // cannot calculate, return fixed value
 	#dim firstDate as %Integer = $ZDH(yyyy_"0101",8)
	#dim firstDayOfWeek as %Integer = $ZD(firstDate,10)
	set:('firstDayOfWeek) firstDayOfWeek = 7
	#dim lastDate as %Integer = $ZDH(yyyy_"1231",8)
	#dim lastDayOfWeek as %Integer = $ZD(lastDate,10)
	set:('lastDayOfWeek) lastDayOfWeek = 7
	#dim isLeapYear as %Boolean = ..IsLeapYear(yyyy)
	/// ISO week date (http://en.wikipedia.org/wiki/ISO_week_date#Last_week)
	/// The long years, with 53 weeks in them, can be described by any of the following equivalent definitions:
	/// - any year starting on Thursday (dominical letter D or DC) and any leap year starting on Wednesday (ED)
	/// - any year ending on Thursday (D, ED) and any leap year ending on Friday (DC)
	/// - years in which 1 January and 31 December (in common years) or either (in leap years) are Thursdays
	/// All other week-numbering years are short years and have 52 weeks.
	quit:((firstDayOfWeek = 4) || (isLeapYear && (firstDayOfWeek = 3)) || (lastDayOfWeek = 4) || (isLeapYear && (lastDayOfWeek = 5)) || ((firstDayOfWeek = 4) && (lastDayOfWeek = 4))) 53
	quit 52
}

/// Get week in year (ww, return new yyyy if date not in week of same year)
ClassMethod GetWeekInYear(ByRef yyyy As %Integer = 0, MM As %Integer = 0, dd As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,.MM,.dd)) 0
	if (yyyy_MM_dd<(18410104)) { set yyyy=1840 quit 53 } // cannot calculate, return fixed values
	#dim horolog as %Integer = $ZDH(yyyy_MM_dd,8)
	quit:horolog<4 52 ; just to prevent a <VALUE OUT OF RANGE> error
	; see http://de.wikipedia.org/wiki/Woche
	; MS-Excel: KÜRZEN((A1-DATUM(JAHR(A1-REST(A1-2;7)+3);1;REST(A1-2;7)-9))/7)
	; quit $E(100+((horolog-($ZDH($E($ZD(horolog-((horolog+3)#7)+3,8),1,4)_"0101",5)+(((horolog+3)#7)-10)))\7),2,3)
 	
 	#dim ret as %Integer = 0
	#dim dayInWeek as %Integer = ..GetDayInWeek(yyyy,MM,dd)
	#dim dayInYear as %Integer = $ZD(horolog,14)
	/// ISO week date (http://en.wikipedia.org/wiki/ISO_week_date)
	#dim week As %Integer = (dayInYear - dayInWeek + 10)\7
	
	if (week<1)
	{
		set yyyy = yyyy-1
		set ret = ..GetWeeksInYear(yyyy)
	}
	elseif (week > ..GetWeeksInYear(yyyy))
	{
		set yyyy = yyyy+1
		set ret = "01"
	}
	else
	{
		set ret = $e(100 + week,2,3)
	}
	quit ret
}

/// Get first day in week (yyyyMMdd)
ClassMethod GetFirstDayInWeek(yyyy As %Integer = 0, ww As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,,,.ww)) 0
	quit:(ww>..GetWeeksInYear(.yyyy)) 0
	quit:(yyyy=1840) 18401231 // no date before this day
	; see http://de.wikipedia.org/wiki/Woche
	; MS-Excel: DATUM(A1;1;1)-WOCHENTAG(DATUM(A1;1;1);3)+(B1+RUNDEN(WOCHENTAG(DATUM(A1;1;1);3)/7;0)-1)*7
	#dim E1 as %Integer = (($ZDH(yyyy_"0101",5)+4)#7)-1
	set:E1<0 E1=6
	quit $ZD($ZDH(yyyy_"0101",5)-E1+((ww+((E1+3)\7)-1)*7),8)
}

/// Get first day of week in year (returns the yyyy0101 if first day of week one is in year before)
ClassMethod GetFirstDayInWeekInYear(yyyy As %Integer = 0, ww As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,,,.ww)) 0
	set date=..GetFirstDayInWeek(yyyy,ww) quit:(date=0) 0
	quit:(yyyy'=$E(date,1,4)) yyyy_"0101"
	quit date
}

/// Get last day in week (yyyyMMdd)
ClassMethod GetLastDayInWeek(yyyy As %Integer = 0, ww As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,,,.ww)) 0
	quit:(ww>..GetWeeksInYear(.yyyy)) 0
	quit:(yyyy=1840) 18410103 // cannot calculate, return fixed value
	quit:(yyyy_ww=999952) 99991231 // no date behind this value
	; see http://de.wikipedia.org/wiki/Woche
	; MS-Excel: DATUM(A1;1;1)-WOCHENTAG(DATUM(A1;1;1);3)+(B1+RUNDEN(WOCHENTAG(DATUM(A1;1;1);3)/7;0)-1)*7
	#dim E1 as %Integer = (($ZDH(yyyy_"0101",5)+4)#7)-1
	set:E1<0 E1=6
	quit $ZD($ZDH(yyyy_"0101",5)-E1+((ww+((E1+3)\7)-1)*7)+6,8)
}

/// Get day in week (u)
ClassMethod GetDayInWeek(yyyy As %Integer = 0, MM As %Integer = 0, dd As %Integer = 0) As %Integer
{
	quit:$$$ISERR(..CheckDate(.yyyy,.MM,.dd)) 0
	#dim horolog as %Integer = $ZDH(yyyy_MM_dd,8)
	#dim dayInWeek as %Integer = ((horolog+4)#7)
	quit $S(dayInWeek=0:7,1:dayInWeek)
}

/// Get easter sunday for year (yyyyMMdd)
ClassMethod GetEaster(yyyy As %Integer = 0) As %Integer
{
	do ..CheckDate(.yyyy) // it doesn't matter if year is out of range => get easter works everytime, but the result may be out of range!
	quit:(yyyy=1840) 0 // no valid easter date before 1841!
	
	s a=yyyy#19,b=yyyy\100,c=yyyy#100
	s h=((19*a)+b-(b\4)-((b-((b+8)\25)+1)\3)+15)#30
	s l=(32+(2*(b#4))+(2*(c\4))-h-(c#4))#7
	s m=(a+(11*h)+(22*l))\451
	s mm=$E(100+((h+l-(7*m)+114)\31),2,3)
	s dd=$E(100+((h+l-(7*m)+114)#31)+1,2,3)
	
	q yyyy_mm_dd
}

/// Get best name of holiday for date and/or all holidays for year.
/// the holiday date (yyyyMMdd) points to a listbuild of:
/// <ul>
/// <li>weight or list of states...the weight of the holiday (0...no holiday, 0.5...half holiday by law, 1...full holiday by law) or a comma separated list of states in which this holiday is a full holiday</li>
/// <li>holiday name(s)...the name(s) of the holiday (if more than one holiday is at the same date, they are comma separated listet</li>
/// </ul>
/// Returns the holiday name for the given date.
ClassMethod GetHoliday(yyyy As %Integer = 0, MM As %Integer = 1, dd As %Integer = 1, ByRef holidays) As %String
{
	kill holidays
	quit:$$$ISERR(..CheckDate(.yyyy,.MM,.dd)) ""
	quit:(yyyy=1840) "" // no valid holidays before 1841!
	
	set currentFormat=##class(%SYS.NLS.Format).%New("Current")
	set currentLocale=##class(%SYS.NLS.Locale).%New(currentFormat.Locale)
	
	if ('$D(^arsblue.util.CalendarD(currentLocale.CountryAbbr,yyyy)))
	{
		do:($$$comClassDefined(..%ClassName(1)_"."_currentLocale.CountryAbbr)) $ClassMethod(..%ClassName(1)_"."_currentLocale.CountryAbbr,"CreateHolidays",yyyy,.holidays)
		merge ^arsblue.util.CalendarD(currentLocale.CountryAbbr,yyyy)=holidays
	}
	else
	{
		merge holidays=^arsblue.util.CalendarD(currentLocale.CountryAbbr,yyyy)
	}
	
	quit $P($LG($G(holidays(yyyy_MM_dd)),2),",",1)
}

/// Create holidays for year
/// <ul>
/// <li>yyyy...the year to created holidays for.</li>
/// <li>holidays...the created holidays (by reference).</li>
/// </ul>
ClassMethod CreateHolidays(yyyy As %Integer = 0, ByRef holidays)
{
	// to be implemented for each country
}

}
