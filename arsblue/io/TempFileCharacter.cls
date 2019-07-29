/// This class creates a temporary file binary stream which will be deleted on dispose of its instance.
Class arsblue.io.TempFileCharacter Extends %Stream.FileCharacter
{

/// create a temporary file or use the given filename as temporary filename.
Method %OnNew(filename As %String) As %Status
{
	$$$QuitOnError(##super())
	$$$QuitOnError(..LinkToFile($G(filename,##class(%File).TempFilename())))
	quit $$$OK
}

/// delete the temporary file on dispose
Method %OnClose() As %Status
{
	$$$QuitOnError(##super())
	do ##class(%File).Delete(..Filename)
	quit $$$OK
}

}
