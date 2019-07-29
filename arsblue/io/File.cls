Include (arsblue.OS, arsblue.Status, arsblue.io.File, %occFile)

/// This class contains file utilities
Class arsblue.io.File [ Abstract ]
{

/// Get the normalized file path for given parts of file names.
/// If the first part of file names starts with a relative path (not with a file separator or drive name),
/// the current file directory will be used as location.
/// <ul>
/// <li>filename...one to many parts of file names to be concatinated and normalized to file path.</li>
/// </ul>
/// Returns the normalized file path.
ClassMethod GetFilePath(filename...) As %String
{
	set:('$D(filename)) filename($I(filename))=$$$FileCurrentDir_"/"
	set filepath=""
	for i=1:1:filename set filepath=filepath_$S(filepath="":"",1:"/")_$TR(filename(i),"\","/")
	set:(($E(filepath,1)'="/") && ($P(filepath,"/",1)'?1A1":")) filepath=$TR($$$FileCurrentDir,"\","/")_filepath
	set:($E(filepath,*)=":") filepath=filepath_"/"
	quit $$$FileNormalizeFilename(filepath)
}

/// Get the absolute directory path for a given file path.
/// If file path is a directory path, it returns the parent directory path. 
/// <ul>
/// <li>filepath...the full file path (optional, current directory is default).</li>
/// </ul>
/// Returns the absolute directory path.
ClassMethod GetDirectory(filepath As %String = "") As %String
{
	quit:(filepath="") ""
	set filepath=$TR(..GetFilePath(filepath),"\","/")
	set filepath=$P(filepath,"/",1,*-1)
	quit $S(filepath="":"",1:$$$FileNormalizeDirectory(filepath_$S($E(filepath,*)=":":"/",1:"")))
}

/// Get the file or directory name for a given file path.
/// <ul>
/// <li>filepath...the full file path.</li>
/// </ul>
/// Returns the file or directory name.
ClassMethod GetFileName(filepath As %String = "") As %String
{
	quit:(filepath="") ""
	set filepath=$TR(filepath,"\","/")
	set:($F("\/",$E(filepath,*))) filepath=$E(filepath,1,*-1)
	quit $P($TR(filepath,"\","/"),"/",*)
}

/// Check if given file path is an existing file.
/// <ul>
/// <li>filepath...the full file path.</li>
/// </ul>
/// Returns true if file path is an existing file, false otherwise.
ClassMethod IsFile(filepath As %String = "") As %Boolean
{
	quit:(filepath="") $$$NO
	set filepath=..GetFilePath(filepath)
	quit $S($$$FileDirectoryExists(filepath):$$$NO,1:$$$FileExists(filepath))
}

/// Check if given file path is an existing directory.
/// <ul>
/// <li>filepath...the full file path.</li>
/// </ul>
/// Returns true if file path is an existing directory, false otherwise.
ClassMethod IsDirectory(filepath As %String = "") As %Boolean
{
	quit:(filepath="") $$$NO
	set filepath=..GetFilePath(filepath)
	quit $$$FileDirectoryExists(filepath)
}

/// Check whether given file or directory is empty.
/// <ul>
/// <li>filepath...the full file path.</li>
/// </ul>
/// Returns true if file or directory is empty, false otherwise.
ClassMethod IsEmpty(filepath As %String = "") As %Boolean
{
	quit:(filepath="") $$$NO
	set filepath=..GetFilePath(filepath)
	
	if ($$$IsFile(filepath))
	{
		quit ($$$FileSize(filepath) <= 0)
	}
	elseif ($$$IsDirectory(filepath))
	{
		set isEmpty=$$$YES
		set file=$ZSE($$$FileNormalizeDirectory(filepath)_"*")
		while (file'="")
		{
			set filename=..GetFileName(file)
			if ((filename=".") || (filename=".."))
			{
				set file=$ZSE("")
			}
			else
			{
				set file=$ZSE(-1)
				set isEmpty=$$$NO
			}
		}
		quit isEmpty
	}
	else
	{
		quit $$$NO
	}
}

/// Delete file or directory and parent directories if they are empty.
/// <ul>
/// <li>filepath...the full file path (may contain wildcard characters).</li>
/// <li>recursive...true (default) to recursive delete empty directories, false otherwise (optional).</li>
/// </ul>
/// Returns status OK if successfully deleted file and directories (if they are empty), any other status signals failure!
ClassMethod DeleteFilePath(filepath As %String = "", recursive As %Boolean = {$$$YES}) As %Status
{
	quit:(filepath="") $$$OK
	set filepath=..GetFilePath(filepath)
	
	#dim status as %Status = $$$OK
	try
	{
		set file=$ZSE($S($F("\/",$E(filepath,*)):$E(filepath,1,*-1),1:filepath))
		while (file'="")
		{
			set filename=..GetFileName(file)
			if ((filename=".") || (filename=".."))
			{
				// do nothing
			}
			elseif ($$$IsFile(file))
			{
				$$$ThrowIf('##class(%File).Delete(file,.oscode),"cannot delete file ("_oscode_"): "_file)
			}
			elseif ($$$IsDirectory(file) && $$$IsEmpty(file))
			{
				$$$ThrowIf('##class(%File).RemoveDirectory(file,.oscode),"cannot delete directory ("_oscode_"): "_file)
			}
			set file=$ZSE("")
		}
		
		if (recursive)
		{
			set filepath=$$$Directory(filepath)
			set:($$$IsEmpty(filepath)) status=..DeleteFilePath(filepath)
		}
	}
	catch (exc)
	{
		set file=$ZSE(-1)
		set status=exc.AsStatus()
	}
	quit status
}

/// Compare file create date with given date.
/// <ul>
/// <li>filepath...the full file path.</li>
/// <li>date...the date to compare with create date (optional, default is current timestamp).</li>
/// </ul>
/// Returns amount of seconds between file create date and given date (negative number means file is older than date, positive number means file is newer than date and zero means file has same date).
ClassMethod CompareCreateDate(filepath As %String = "", date As %TimeStamp = {$H}) As %Integer
{
	quit:(filepath="") $$$MININT
	quit:(date'?1.5N1","1.5N) $$$MAXINT
	
	set filepath=..GetFilePath(filepath)
	set filedate=$$$FileDateCreated(filepath) quit:(filedate'?1.5N1","1.5N) $$$MININT
	
	quit (($P(filedate,",",1)-$P(date,",",1))*$$$DAYINSEC)+($P(filedate,",",2)-$P(date,",",2))
}

/// Compare file modification date with given date.
/// <ul>
/// <li>filepath...the full file path.</li>
/// <li>date...the date to compare with modification date (optional, default is current timestamp).</li>
/// </ul>
/// Returns amount of seconds between file modification date and given date (negative number means file is older than date, positive number means file is newer than date and zero means file has same date).
ClassMethod CompareModifiedDate(filepath As %String = "", date As %TimeStamp = {$H}) As %Integer
{
	quit:(filepath="") $$$MININT
	quit:(date'?1.5N1","1.5N) $$$MAXINT
	
	set filepath=..GetFilePath(filepath)
	set filedate=$$$FileDateModified(filepath) quit:(filedate'?1.5N1","1.5N) $$$MININT
	
	quit (($P(filedate,",",1)-$P(date,",",1))*$$$DAYINSEC)+($P(filedate,",",2)-$P(date,",",2))
}

}
