ROUTINE arsblue.Status [Type=INC]
/// This include extends the functionality of %occStatus and contains macros for working with status

/// check for status
#define ISSTATUS(%val)				$S(%val=$$$OK:$$$YES,(($L(%val)>2)&&($E(%val,1,2)="0 ")&&($LV($E(%val,3,*)))):$$$YES,1:$$$NO)

/// warning is a special kind of status with an errorcode of zero and a warning message
#define WARNING(%msg)				$$$ERROR(0,%msg)
#define ISWARNING(%sc)				($$$ISERR(%sc)&&('$System.Status.GetErrorCodes(%sc)))
#define GETWARNING(%sc)				$LG($LG($E(%sc,3,*),1),2)

/// quit with status macros
#define Quit(%sc)					quit:$$$ISERR(%sc) %sc
/// %occStatus.inc: #define QuitOnError(%expr)     Set sc=%expr Quit:$$$ISERR(sc) sc
/// %occStatus.inc: #define QUITONERROR(%sc,%expr) Set %sc=%expr Quit:$$$ISERR(%sc) %sc
#define QuitIf(%expr,%msg)			quit:(%expr) $$$ERROR($$$GeneralError,%msg)
#define QuitOnSQLError(%rs,%rssql)	set %rs=%rssql quit:(%rs.%SQLCODE<0) $$$ERROR($$$SQLError,%rs.%Message)
#define QuitError(%msg)				quit $$$ERROR($$$GeneralError,%msg)

/// throw status exception macros
#define Throw(%sc)					throw:$$$ISERR(%sc) ##class(%Exception.StatusException).ThrowIfInterrupt(%sc)
/// %occStatus.inc: #define ThrowOnError(%expr)    Set sc=%expr Throw:$$$ISERR(sc) ##class(%Exception.StatusException).ThrowIfInterrupt(sc)
/// %occStatus.inc: #define THROWONERROR(%sc,%expr) Set %sc=%expr Throw:$$$ISERR(%sc) ##class(%Exception.StatusException).ThrowIfInterrupt(%sc)
#define ThrowIf(%expr,%msg)			throw:(%expr) ##class(%Exception.StatusException).ThrowIfInterrupt($$$ERROR($$$GeneralError,%msg))
#define ThrowOnSQLError(%rs,%rssql)	set %rs=%rssql throw:(%rs.%SQLCODE<0) ##class(%Exception.StatusException).ThrowIfInterrupt($$$ERROR($$$SQLError,%rs.%Message))
#define ThrowError(%msg)			throw ##class(%Exception.StatusException).ThrowIfInterrupt($$$ERROR($$$GeneralError,%msg))

/// return with status macros
#define Return(%sc)					return:$$$ISERR(%sc) %sc
#define ReturnOnError(%expr)     	set sc=%expr return:$$$ISERR(sc) sc
#define RETURNONERROR(%sc,%expr) 	set %sc=%expr return:$$$ISERR(%sc) %sc
#define ReturnIf(%expr,%msg)		return:(%expr) $$$ERROR($$$GeneralError,%msg)
#define ReturnOnSQLError(%rs,%rssql)	set %rs=%rssql return:(%rs.%SQLCODE<0) $$$ERROR($$$SQLError,%rs.%Message)
#define ReturnError(%msg)			return $$$ERROR($$$GeneralError,%msg)

/// quit on expression macros
#define Break(%expr)				quit:(%expr)
#define BreakOnError(%expr)			$$$Break($$$ISERR(%expr))
#define BREAKONERROR(%sc,%expr)		set %sc=%expr $$$Break($$$ISERR(%sc))
#define BreakOnSQLError(%rs,%rssql)	set %rs=%rssql $$$Break(%rs.%SQLCODE<0)

/// continue on expression macros
#define Continue(%expr)				continue:(%expr)
#define ContinueOnError(%expr)		$$$Continue($$$ISERR(%expr))
#define CONTINUEONERROR(%sc,%expr)	set %sc=%expr $$$Continue($$$ISERR(%sc))
#define ContinueOnSQLError(%rs,%rssql)	set %rs=%rssql $$$Continue(%rs.%SQLCODE<0)
