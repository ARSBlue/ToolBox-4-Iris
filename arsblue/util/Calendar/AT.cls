/// This class contains the holiday calculateion for country Austria 
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
Class arsblue.util.Calendar.AT Extends arsblue.util.Calendar
{

/// Create holidays for year
/// <ul>
/// <li>yyyy...the year to created holidays for.</li>
/// <li>holidays...the created holidays (by reference).</li>
/// </ul>
ClassMethod CreateHolidays(yyyy As %Integer = 0, ByRef holidays)
{
	// flexible holidays (advent)
	set h=$ZDH(yyyy_"1224",8),h=h-((h+4)#7),holidays($ZD(h,8))=$LB(0,"4th_sunday_in_advent")
	set h=h-7,holidays($ZD(h,8))=$LB(0,"3th_sunday_in_advent")
	set h=h-7,holidays($ZD(h,8))=$LB(0,"2nd_sunday_in_advent")
	set h=h-7,holidays($ZD(h,8))=$LB(0,"1st_sunday_in_advent")
	
	// fixed holidays
	set holidays(yyyy_"0101")=$LB(1,"new_years_day")
	set holidays(yyyy_"0106")=$LB(1,"epiphany")
	set holidays(yyyy_"0214")=$LB(0,"valentines_day")
	set holidays(yyyy_"0319")=$LB("K,ST,T,V","josef_day")
	set holidays(yyyy_"0501")=$LB(1,"labor_day")
	set holidays(yyyy_"0504")=$LB("O","florian_day")
	set holidays(yyyy_"0815")=$LB(1,"assumption_day")
	set holidays(yyyy_"0924")=$LB("S","rupert_day")
	set holidays(yyyy_"1010")=$LB("K","popular_vote_day")
	set holidays(yyyy_"1026")=$LB(1,"national_holiday")
	set holidays(yyyy_"1031")=$LB(0,"halloween")
	set holidays(yyyy_"1101")=$LB(1,"all_saints_day")
	set holidays(yyyy_"1111")=$LB("B","martin_day")
	set holidays(yyyy_"1115")=$LB("N,W","leopold_day")
	set h=$G(holidays(yyyy_"1206"),$LB()) set $LI(h,2)=$CASE($LG(h,2),"":"",:$LG(h,2)_",")_"saint_nicholas_day",holidays(yyyy_"1206")=h
	set h=$G(holidays(yyyy_"1208"),$LB()),$LI(h,1)=1,$LI(h,2)="immaculate_conception_day"_$CASE($LG(h,2),"":"",:","_$LG(h,2)),holidays(yyyy_"1208")=h
	set h=$G(holidays(yyyy_"1224"),$LB()) set:($LG(h,1)<0.5) $LI(h,1)=0.5 set $LI(h,2)="christmas_eve"_$CASE($LG(h,2),"":"",:$LG(h,2)_","),holidays(yyyy_"1224")=h
	set holidays(yyyy_"1225")=$LB(1,"christmas_day")
	set holidays(yyyy_"1226")=$LB(1,"boxing_day")
	set holidays(yyyy_"1231")=$LB(0.5,"new_years_eve")
	
	// flexible holidays (easter)
	set easter=$ZDH(..GetEaster(yyyy),8)
	set easter($ZD(easter,8))=$LB(1,"easter_sunday")
	set easter($ZD(easter+1,8))=$LB(1,"easter_monday")
	set easter($ZD(easter+39,8))=$LB(1,"ascension_day")
	set easter($ZD(easter+49,8))=$LB(1,"whit_sunday")
	set easter($ZD(easter+50,8))=$LB(1,"whit_monday")
	set easter($ZD(easter+60,8))=$LB(1,"feast_of_corpus_christi")
	set easter($ZD(easter-2,8))=$LB(0,"good_friday")
	set easter($ZD(easter-3,8))=$LB(0,"maundy_thursday")
	set easter($ZD(easter-7,8))=$LB(0,"palm_sunday")
	set easter($ZD(easter-46,8))=$LB(0,"ash_wednesday")
	set easter($ZD(easter-47,8))=$LB(0,"shrove_tuesday")
	set easter($ZD(easter-48,8))=$LB(0,"shrove_monday")
	set easter=""
	for
	{
		set easter=$O(easter(easter)) quit:(easter="")
		set h=$G(holidays(easter),$LB())
		set:(($LG(h,1)<$LG(easter(easter),1))||($LG(h,1)="")) $LI(h,1)=$LG(easter(easter),1)
		set $LI(h,2)=$LG(easter(easter),2)_$CASE($LG(h,2),"":"",:","_$LG(h,2))
		set holidays(easter)=h
	}
}

}
