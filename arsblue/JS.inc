ROUTINE arsblue.JS [Type=INC]
/// This include contains javascript extensions

/// since JSON (javascript object notation) is part of javascript, json include will be automatically loaded when javascript macros are loaded
#include arsblue.util.Json

/// javascript only supports 54-bit integer values
/// (see javascript Number.MIN_SAFE_INTEGER and Number.MAX_SAFE_INTEGER)
#define JSMININT			-9007199254740991
#define JSMAXINT			9007199254740991

/// javascript timestamp
#define JSTimeStamp			$TR($ZDT($NOW(),3,,3)," ","T")

/// javascript numeric check
#define ISJSNUMERIC(%num)	$S('$$$ISNUMERIC(%num):$$$NO,(%num>$$$JSMAXINT)||(%num<$$$JSMININT):$$$NO,1:$$$YES)

/// get javascript value (string or numeric)
#define GETJSVALUE(%val)	$S($$$ISJSNUMERIC(%val):+%val,1:""_%val)
#define GETJSVALUEQ(%val)	$S($$$ISJSNUMERIC(%val):+%val,1:"'"_%val_"'")
