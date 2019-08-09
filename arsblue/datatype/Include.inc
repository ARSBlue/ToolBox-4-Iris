ROUTINE arsblue.datatype.Include [Type=INC]
/// This include contains datattype extensions
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at
#include arsblue.OS
#include arsblue.Status
#include arsblue.NLS

/// get date/time decimal value (leading zeros may be removed)
#define GETDATETIMEVALUE(%val)		$S($$$ISNUMERIC(%val):+%val,('$$$ISNULL(%val))&&($TR($E(%val,1,*-$L(+%val)),"0","")=""):+%val,1:%val)

/// get default display date-, time- and timestamp format
#define TimeStampDisplayFormat		##Expression($S($$$NLSFormat($$$FMTDateFormat)=1:"""MM/dd/yyyy HH:mm:ss.SSS""",1:"""dd/MM/yyyy HH:mm:ss.SSS"""))
#define DateTimeDisplayFormat		##Expression($S($$$NLSFormat($$$FMTDateFormat)=1:"""MM/dd/yyyy HH:mm:ss""",1:"""dd/MM/yyyy HH:mm:ss"""))
#define DateDisplayFormat			##Expression($S($$$NLSFormat($$$FMTDateFormat)=1:"""MM/dd/yyyy""",1:"""dd/MM/yyyy"""))
#define TimeDisplayFormat			##Expression("""HH:mm:ss""")
