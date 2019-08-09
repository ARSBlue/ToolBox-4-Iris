ROUTINE arsblue.NLS [Type=INC]
/// This include contains NLS extensions
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
#include %syNLS

/// get NLS format:
/// for date-time: $$$FMTDateFormat,$$$FMTYearOption,$$$FMTTimeFormat,$$$FMTTimePrecision,$$$FMTDateSeparator,$$$FMTTimeSeparator,
///                $$$FMTAM,$$$FMTPM,$$$FMTNoon,$$$FMTMidnight,$$$FMTMonthAbbr,$$$FMTMonthName,$$$FMTWeekdayAbbr,$$$FMTWeekdayName,
///                $$$FMTDateMinimum,$$$FMTDateMaximum
/// for numeric: $$$FMTNumericGroupSize,$$$FMTDecimalSeparator,$$$FMTNumericGroupSeparator,$$$FMTPlusSign,$$$FMTMinusSign,$$$FMTCurrency
#define NLSMonthAbbr				##Expression(""""_$TR($P($$$NLSFormat($$$FMTMonthAbbr),$E($$$NLSFormat($$$FMTMonthAbbr)),2,*),$E($$$NLSFormat($$$FMTMonthAbbr)),",")_"""")
#define NLSMonthName				##Expression(""""_$TR($P($$$NLSFormat($$$FMTMonthName),$E($$$NLSFormat($$$FMTMonthName)),2,*),$E($$$NLSFormat($$$FMTMonthName)),",")_"""")
#define NLSWeekdayAbbr				##Expression(""""_$TR($P($$$NLSFormat($$$FMTWeekdayAbbr),$E($$$NLSFormat($$$FMTWeekdayAbbr)),3,*)_$E($$$NLSFormat($$$FMTWeekdayAbbr))_$P($$$NLSFormat($$$FMTWeekdayAbbr),$E($$$NLSFormat($$$FMTWeekdayAbbr)),2),$E($$$NLSFormat($$$FMTWeekdayAbbr)),",")_"""")
#define NLSWeekdayName				##Expression(""""_$TR($P($$$NLSFormat($$$FMTWeekdayName),$E($$$NLSFormat($$$FMTWeekdayName)),3,*)_$E($$$NLSFormat($$$FMTWeekdayName))_$P($$$NLSFormat($$$FMTWeekdayName),$E($$$NLSFormat($$$FMTWeekdayName)),2),$E($$$NLSFormat($$$FMTWeekdayName)),",")_"""")
#define NLSFormat(%idx)				$ZU(122,%idx)
