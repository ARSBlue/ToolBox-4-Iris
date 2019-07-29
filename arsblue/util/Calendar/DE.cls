/// This class contains the holiday calculateion for country Germany 
Class arsblue.util.Calendar.DE Extends arsblue.util.Calendar
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
	// flexible holidays (prayers day)
	set h=$ZDH(yyyy_"1123",8),wd=(h+4)#7,h=h-$S(wd<3:4+wd,1:wd-3),holidays($ZD(h,8))=$LB("SN","prayers_day")
	
	// fixed holidays
	set holidays(yyyy_"0101")=$LB(1,"new_years_day")
	set holidays(yyyy_"0106")=$LB("BW,BY,ST","epiphany")
	set holidays(yyyy_"0214")=$LB(0,"valentines_day")
	set holidays(yyyy_"0308")=$LB(0,"womens_day")
	set holidays(yyyy_"0501")=$LB(1,"labor_day")
	set holidays(yyyy_"0808")=$LB(0,"augsburger_high_peace_festival")
	set holidays(yyyy_"0815")=$LB("SL","assumption_day")
	set holidays(yyyy_"0920")=$LB("TH","world_childrens_day")
	set holidays(yyyy_"1003")=$LB(1,"german_unity_day")
	set holidays(yyyy_"1031")=$LB("BB,HB,HH,MV,NI,SN,ST,SH,TH","reformation_day,halloween")
	set holidays(yyyy_"1101")=$LB("BW,BY,NW,RP,SL","all_saints_day")
	set h=$G(holidays(yyyy_"1224"),$LB()) set $LI(h,2)=$CASE($LG(h,2),"":"",:$LG(h,2)_",")_"christmas_eve",holidays(yyyy_"1224")=h
	set holidays(yyyy_"1225")=$LB(1,"christmas_day")
	set holidays(yyyy_"1226")=$LB(1,"boxing_day")
	set holidays(yyyy_"1231")=$LB(0,"new_years_eve")
	
	// flexible holidays (easter)
	set easter=$ZDH(..GetEaster(yyyy),8)
	set easter($ZD(easter,8))=$LB("BB,HE","easter_sunday")
	set easter($ZD(easter+1,8))=$LB(1,"easter_monday")
	set easter($ZD(easter+39,8))=$LB(1,"ascension_day")
	set easter($ZD(easter+49,8))=$LB("BB,HE","whit_sunday")
	set easter($ZD(easter+50,8))=$LB(1,"whit_monday")
	set easter($ZD(easter+60,8))=$LB("BW,BY,HE,NW,RP,SL","feast_of_corpus_christi")
	set easter($ZD(easter-2,8))=$LB(1,"good_friday")
	set easter($ZD(easter-3,8))=$LB(0,"maundy_thursday")
	set easter($ZD(easter-7,8))=$LB(1,"palm_sunday")
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
