ROUTINE arsblue.OS [Type=INC]
/// This include contains object script extensions
///
/// ARSBlue ToolBox-4-Iris
/// Copyright &copy; 2019 ARS Blue GmbH
/// http://www.ars-blue.at

/// IRIS defines internal an empty string/stream as NULL
#define NULL					$C(0)
#define ISNULL(%val)			((%val=$$$NULLOREF)||(%val=$$$NULL))
#define IFNULL(%val,%def)		$S($$$ISNULL(%val):%def,1:%val)

/// IRIS only supports 64-bit integer values with 19-digits
/// (see https://docs.intersystems.com/iris20181/csp/docbook/DocBook.UI.Page.cls?KEY=GCOS_types#GCOS_types_numlarge)
#define MININT					-9223372036854775808
#define MAXINT					9223372036854775807

/// IRIS date/time/timestamp support
#define DAYINSEC				##Expression(24*60*60)
#define TimeStamp				(+$ZSTRIP($ZDT($NOW(),3,,6),"*P",,"."))

/// $LIST handling
#define ISLIST(%val)			('$$$ISNULL(%val)&&$LV(%val))
#define ISLISTEMPTY(%val)		$S('$$$ISLIST(%val):$$$YES,1:($LL(%val)<=1)&&('$LD(%val,1)))

/// numeric check (numbers with leading zeros are strings, double INF, -INF and NAN are rejected)
#define ISNUMERIC(%num)			$S('$ISVALIDNUM(%num):$$$NO,$CASE($ZCVT(%num,"U"),"INF":$$$YES,"-INF":$$$YES,"NAN":$$$YES,:$$$NO):$$$NO,%num?1."0"1.N.E:$$$NO,1:$$$YES)

/// get value (string or numeric)
#define GETVALUE(%val)			$S($$$ISNUMERIC(%val):+%val,1:""_%val)
#define GETVALUEQ(%val)			$S($$$ISNUMERIC(%val):+%val,1:""""_%val_"""")

/// namespace handling
#define NspDest(%obj)			"^[""^"_$P($ZU(90,22,$TR($ZU(5),"^","@"),"rOBJ"),"^",2,3)_"""]"_%obj

/// class handling
#define TypeOf(%obj,%cls)		$S($IsObject(%obj):%obj.%Extends(%cls),1:('$$$ISNULL(%obj))&&($ZSTRIP(%obj,"*E'A",,"%.")=%obj)&&($$$comClassDefined(%obj))&&($ClassMethod(%obj,"%Extends",%cls)))
#define InitTypeOf(%obj,%cls)	set:('($$$TypeOf(%obj,%cls))) %obj=$ClassMethod(%cls,"%New")
#define ClassName(%type)		$S($IsObject(%type):$Method(%type,"%ClassName",1),1:$ClassMethod(%type,"%ClassName",1))
#define ClassType(%type)		$S(%type="":"%Library.String",$F(%type,":"):$$$comMemberKeyGet($P(%type,":",1),$$$cCLASSproperty,$P(%type,":",2),$$$cPROPtype),1:$ClassMethod(%type,"%ClassName",1))
#define LastModified(%cls)		$P($$$comClassKeyGet(%cls,$$$cCLASStimechanged),".",1)
