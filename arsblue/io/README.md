# ARSBlue ToolBox-4-Iris -- IO Package

**_Documentation_**: The documentation is available in English [README.md](./README.md) as well as in German [README_DE.md](./README_DE.md).

- [File and Directory Functions](#file-and-directory-functions)
  - [Include File Macro in Source Code](#include-file-macro-in-source-code)
  - [Normalized File or Directory Path](#normalized-file-or-directory-path)
  - [Filename or Directory Path from File Path](#filename-or-directory-path-from-file-path)
  - [Check File or Directory for Existence](#check-file-or-directory-for-existence)
  - [Check File or Directory for Content](#check-file-or-directory-for-content)
  - [Delete Files and Directories](#delete-files-and-directories)
- [Serialize Object Instances from/to JSON](#serialize-object-instances-fromto-json)
- [Temporary File Objects for Data Streams](#temporary-file-objects-for-data-streams)

## File and Directory Functions

Many functions already exist in the standard InterSystems IRIS class `%Library.File`. The functions described here combine some of these functions or extend them for improved handling of files and directories. On the one hand the functions of the class `arsblue.io.File` are available and on the other hand there is the corresponding macro` arsblue.io.File` in order to be able to use the most important functions of the class in abbreviated spelling in the source code. In the following, the functions are always described with the equivalent macro (if any).

### Include File Macro in Source Code

To be able to use the macro in your own source code, it is necessary to include it in the first line of the class.
```
Include (arsblue.io.File)

/// my class
Class my.Class {
  ...
}
```

### Normalized File or Directory Path

**_Syntax:_**
```
 ##class(arsblue.io.File).GetFilePath(<Dateiname1>[,<DateinameN>])
```
**_Macro:_**
```
$$$File.GetFilePath(<Dateiname1>[,<DateinameN>])
$$$FilePath(<Dateiname1>[,<DateinameN>])
```
**_Replaces IRIS Function:_**
```
 ##class(%Library.File).NormalizeDirectory(<Name>,<Verzeichnispfad>)

 ##class(%Library.File).NormalizeFilename(<Name>,<Verzeichnispfad>)
```
The difference between the standard InterSystems IRIS file implementation and the arsblue implementation is that it is possible to specify any number of parts of the file name and that all parts are merged into a normalized file path. If the first part of the file is specified relative, i.e. it is not a path separator or disk identifier, the current directory path is used. Also, the standard InterSystems IRIS implementation requires that a directory, if specified, already exist.

```
USER>write ##class(arsblue.io.File).GetFilePath()
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).GetFilePath("mydir", "myfile")
C:\InterSystems\IRIS\mgr\user\mydir\myfile
USER>write ##class(arsblue.io.File).GetFilePath("/mydir", "myfile")
C:\mydir\myfile
USER>write ##class(arsblue.io.File).GetFilePath("mydir", "mysubdir", "..", "myfile")
C:\InterSystems\IRIS\mgr\user\mydir\myfile
```

### Filename or Directory Path from File Path

**_Syntax:_**
```
 ##class(arsblue.io.File).GetDirectory(<Dateipfad>)

 ##class(arsblue.io.File).GetFileName(<Dateipfad>)
```
**_Macro:_**
```
$$$File.GetDirectory(<Dateipfad>)
$$$Directory(<Dateipfad>)

$$$File.GetFileName(<Dateipfad>)
$$$FileName(<Dateipfad>)
```
**_Replaces IRIS Function:_**
```
 ##class(%Library.File).ParentDirectoryName(<Verzeichnispfad>)

 ##class(%Library.File).GetFilename(<Dateipfad>)
```
There is little difference between the standard InterSystems IRIS file implementation and the arsblue implementation. The arsblue method and macro names are unified and shorter to write than the standard InterSystems IRIS method names, and the passed file path is normalized beforehand.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).GetDirectory(filepath)
C:\InterSystems\IRIS\mgr\
USER>write ##class(arsblue.io.File).GetFileName(filepath)
user
```

### Check File or Directory for Existence

**_Syntax:_**
```
 ##class(arsblue.io.File).IsDirectory(<Dateipfad>)

 ##class(arsblue.io.File).IsFile(<Dateipfad>)
```
**_Macro:_**
```
$$$File.IsDirectory(<Dateipfad>)
$$$IsDirectory(<Dateipfad>)

$$$File.IsFile(<Dateipfad>)
$$$IsFile(<Dateipfad>)
```
**_Replaces IRIS Function:_**
```
 ##class(%Library.File).DirectoryExists(<Verzeichnispfad>)

 ##class(%Library.File).Exists(<Dateipfad>)
```
The difference between the standard InterSystems IRIS file implementation and the arsblue implementation is that the file query really only considers files, not directories. The arsblue method and macro names are unified and shorter to write than the standard InterSystems IRIS method names, and the passed file path is normalized beforehand.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsDirectory(filepath)
1
USER>write ##class(arsblue.io.File).IsFile(filepath)
0
```

### Check File or Directory for Content

**_Syntax:_**
```
 ##class(arsblue.io.File).IsEmpty(<Dateipfad>)
```
**_Macro:_**
```
$$$File.IsEmpty(<Dateipfad>)
$$$IsEmpty(<Dateipfad>)
```
**_Replaces IRIS Function:_**
```
 ##class(%Library.File).SizeGet()
```
The difference between the standard InterSystems IRIS file implementation and the arsblue implementation is that in InterSystems IRIS only the contents of a file but not the contents of a directory can be controlled. The function provides only for directories without files (own references `.` and higher directory references `..` are not considered) or files with a size of `0` bytes the value` 1`. The passed file path is normalized before.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsEmpty(filepath)
0
```

### Delete Files and Directories

**_Syntax:_**
```
 ##class(arsblue.io.File).DeleteFilePath(<Dateipfad>[,<recursive>])
```
**_Macro:_**
```
$$$File.DeleteFilePath(<Dateipfad>[,<recursive>])
```
This method deletes files and empty directories and their parent directories if they do not contain any other files. Wildcards can also be used (for example, `backups/*.bak`,`logfiles/log*.*`, etc.). The passed file path is normalized before.
The following example deletes files from a temporary directory to describe how it works. A Windows installation of InterSystems IRIS was used for the documentation. The functionality is naturally present on every system for which InterSystems IRIS is offered.

**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir /S
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

02.04.2019  07:41    <DIR>          .
02.04.2019  07:41    <DIR>          ..
02.04.2019  07:41    <DIR>          my_dir1
02.04.2019  07:41                 0 my_file.txt
               1 Datei(en),              0 Bytes

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp\my_dir1

02.04.2019  07:41    <DIR>          .
02.04.2019  07:41    <DIR>          ..
02.04.2019  07:42    <DIR>          my_dir2
               0 Datei(en),              0 Bytes

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp\my_dir1\my_dir2

02.04.2019  07:42    <DIR>          .
02.04.2019  07:42    <DIR>          ..
02.04.2019  07:42                 0 my_file1.txt
02.04.2019  07:42                 0 my_file2.txt
               2 Datei(en),              0 Bytes

     Anzahl der angezeigten Dateien:
               3 Datei(en),              0 Bytes
               8 Verzeichnis(se), 101 846 745 088 Bytes frei
```
Deleting a file from a directory that contains other files or directories behaves like a standard InterSystems IRIS file deletion command.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/my_dir1/my_dir2/my_file1.txt"))
```
**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir /S
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

02.04.2019  07:41    <DIR>          .
02.04.2019  07:41    <DIR>          ..
02.04.2019  07:41    <DIR>          my_dir1
02.04.2019  07:41                 0 my_file.txt
               1 Datei(en),              0 Bytes

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp\my_dir1

02.04.2019  07:41    <DIR>          .
02.04.2019  07:41    <DIR>          ..
03.04.2019  11:08    <DIR>          my_dir2
               0 Datei(en),              0 Bytes

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp\my_dir1\my_dir2

03.04.2019  11:08    <DIR>          .
03.04.2019  11:08    <DIR>          ..
02.04.2019  07:42                 0 my_file2.txt
               1 Datei(en),              0 Bytes

     Anzahl der angezeigten Dateien:
               2 Datei(en),              0 Bytes
               8 Verzeichnis(se), 101 843 353 600 Bytes frei
```
If you now delete all files in the directory, the directory itself and the parent directories will be deleted, up to a directory that contains other files or directories.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/my_dir1/my_dir2/*.txt"))
```
**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir /S
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

03.04.2019  11:32    <DIR>          .
03.04.2019  11:32    <DIR>          ..
02.04.2019  07:41                 0 my_file.txt
               1 Datei(en),              0 Bytes

     Anzahl der angezeigten Dateien:
               1 Datei(en),              0 Bytes
               2 Verzeichnis(se), 101 840 396 288 Bytes frei
```
By explicitly setting the 2nd parameter of the function to `0`, the functionality of deleting higher-level directories can be switched off.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/*.txt",0))
```
**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir /S
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

03.04.2019  11:45    <DIR>          .
03.04.2019  11:45    <DIR>          ..
               0 Datei(en),              0 Bytes

     Anzahl der angezeigten Dateien:
               0 Datei(en),              0 Bytes
               2 Verzeichnis(se), 101 845 786 624 Bytes frei
```
The advantage of this method is that you can automatically clean up directory structures without having to worry about having other files or directories in them. This functionality is particularly important when exporting files or when cleaning up temporary or old data.

## Serialize Object Instances from/to JSON

In the standard InterSystems IRIS implementation, object serialization is only provided in XML format (`%XML.Adaptor`). Unfortunately, the offered InterSystems IRIS JSON implementation is only available for simple data types and not for complex classes (collections, etc.). The implicit arsblue JSON serialization can solve these problems.

To enable implicit JSON serialization on an object, this object must be derived from the JSON serialization `arsblue.io.Serializable`. From this point, the methods `%FromJSON (...)` are used to import data from JSON into this object and `%ToJSON (...)` to export data from this object to JSON.

To serialize arbitrary objects with JSON, it is not mandatory to derive from this class. There is also the possibility of exporting any IRIS object to JSON via the JSON utilities, which derives from `%Library.RegisteredObject` (see [JSON Utilities](https://github.com/ARSBlue/ToolBox-4-Iris/blob/master/arsblue/util/README.md#json-utilities) or [Export Data Objects to JSON](https://github.com/ARSBlue/ToolBox-4-Iris/blob/master/arsblue/util/README.md#export-data-objects-to-JSON)).

## Temporary File Objects for Data Streams

InterSystems IRIS offers the possibility to generate temporary file names and also to read binary data streams from files. But there is no data type that combines both functions. In this case, the classes `arsblue.io.TempFileBinary` for binary data streams and `arsblue.io.TempFileCharacter` for character-based data streams have been developed. The advantage of these two classes over the InterSystems IRIS file streams `%Stream.FileBinary` and`%Stream.FileCharacter` is that no file name needs to be passed, i.e. automatically creates a temporary filename (i.e. a file in the default temporary directory) and automatically deletes that file when the class object is removed from memory. Thus, it can not happen that the temporary directory fills up uncontrollably with files for which no program feels responsible (e.g. %ZEN Reports, InterSystems IRIS Management Portal Import/Export, etc.). Of course, you can also pass your own temporary file name in the constructor.

The following example creates, describes and automatically deletes a new temporary character-based stream. A Windows installation of InterSystems IRIS was used for the documentation. The functionality is naturally present on every system for which InterSystems IRIS is offered.

**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

27.03.2019  15:32    <DIR>          .
27.03.2019  15:32    <DIR>          ..
               0 Datei(en),              0 Bytes
               2 Verzeichnis(se), 105 316 712 448 Bytes frei
```
**_IRIS Terminal:_**
```
USER>set tempfile=##class(arsblue.datatypes.TempFileCharacter).%New()
 
USER>write $System.Status.GetErrorText(tempfile.WriteLine("Das ist ein temporärer Datenstrom"))
```
From the moment that the data stream is no longer empty, the corresponding file is created in the temporary directory, even though no data has been written to the file (see corresponding memory or flush methods).

**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

27.03.2019  15:55    <DIR>          .
27.03.2019  15:55    <DIR>          ..
27.03.2019  15:55                 0 6vtxdJaPG7AXPw.tmp
               1 Datei(en),              0 Bytes
               2 Verzeichnis(se), 105 098 268 672 Bytes frei
```
The further handling corresponds to the class documentation of the standard InterSystems IRIS classes.

**_Iris Terminal:_**
```
USER>kill tempfile
```
The moment the class object in memory no longer exists, the file in the temporary directory is also removed.

**_Windows Command Prompt:_**
```
C:\InterSystems\IRIS\mgr\Temp>dir
 Volume in Laufwerk C: hat keine Bezeichnung.
 Volumeseriennummer: F0D2-A330

 Verzeichnis von C:\InterSystems\IRIS\mgr\Temp

27.03.2019  16:03    <DIR>          .
27.03.2019  16:03    <DIR>          ..
               0 Datei(en),              0 Bytes
               2 Verzeichnis(se), 105 097 224 192 Bytes frei
```
The two classes work in the same way, the difference being that the temporary character-based stream is encoded with the appropriate character set, as in the standard InterSystems IRIS classes, while the temporary binary stream writes the data unchanged.
