# ARSBlue ToolBox-4-Iris -- IO Package

- [Datei und Verzeichnis Funktionen](#datei-und-verzeichnis-funktionen)
  - [Dateimakro in Quellcode einbinden](#dateimakro-in-quellcode-einbinden)
  - [Normalisierter Datei- bzw. Verzeichnispfad](#normalisierter-datei--bzw-verzeichnispfad)
  - [Dateiname bzw. Verzeichnispfad aus Dateipfad](#dateiname-bzw-verzeichnispfad-aus-dateipfad)
  - [Datei bzw. Verzeichnis auf Existenz überprüfen](#datei-bzw-verzeichnis-auf-existenz-%C3%BCberpr%C3%BCfen)
  - [Datei bzw. Verzeichnis auf Inhalt überprüfen](#datei-bzw-verzeichnis-auf-inhalt-%C3%BCberpr%C3%BCfen)
  - [Dateien und Verzeichnisse löschen](#dateien-und-verzeichnisse-l%C3%B6schen)
- [Objektinstanzen von/nach JSON serialisieren](#objektinstanzen-vonnach-json-serialisieren)
- [Temporäre Dateiobjekte für Datenströme](#tempor%C3%A4re-dateiobjekte-f%C3%BCr-datenstr%C3%B6me)

## Datei und Verzeichnis Funktionen

In der Standard InterSystems IRIS Klasse `%Library.File` sind bereits viele Funktionen vorhanden. Die hier beschriebenen Funktionen kombinieren einige dieser Funktionen bzw. erweitern sie für einen verbesserten Umgang mit Dateien und Verzeichnissen. Einerseits stehen die Funktionen der Klasse `arsblue.io.File` zur Verfügung und andererseits gibt es das entsprechende Makro `arsblue.io.File` um die wichtigsten Funktionen der Klasse in gekürzter Schreibweise im Quellcode verwenden zu können. Im Folgenden werden die Funktionen immer mit dem äquivalenten Makro (sofern vorhanden) beschrieben.

### Dateimakro in Quellcode einbinden

Um das Makro im eigenen Quellcode verwenden zu können, ist es notwendig es in der ersten Zeile der Klasse einzubinden.
```
Include (arsblue.io.File)

/// my class
Class my.Class {
  ...
}
```

### Normalisierter Datei- bzw. Verzeichnispfad

**_Syntax:_**
```
 ##class(arsblue.io.File).GetFilePath(<Dateiname1>[,<DateinameN>])
```
**_Makro:_**
```
$$$File.GetFilePath(<Dateiname1>[,<DateinameN>])
$$$FilePath(<Dateiname1>[,<DateinameN>])
```
**_Ersetzt IRIS Funktion:_**
```
 ##class(%Library.File).NormalizeDirectory(<Name>,<Verzeichnispfad>)

 ##class(%Library.File).NormalizeFilename(<Name>,<Verzeichnispfad>)
```
Der Unterschied zwischen der Standard InterSystems IRIS Dateiimplementierung und der arsblue Implementation liegt darin, dass es möglich ist, beliebig viele Teile des Dateinamens anzugeben und dass alle Teile zu einem normalisierten Dateipfad zusammengefügt werden. Wird der erste Teil der Datei relativ angegeben, d.h. es handelt sich nicht um einen Pfadseparator oder eine Festplattenidentifizierung, wird der aktuelle Verzeichnispfad herangezogen. Auch erfordert die Standard InterSystems IRIS Implementierung, dass ein Verzeichnis, falls angegeben, bereits existieren muss.
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

### Dateiname bzw. Verzeichnispfad aus Dateipfad

**_Syntax:_**
```
 ##class(arsblue.io.File).GetDirectory(<Dateipfad>)

 ##class(arsblue.io.File).GetFileName(<Dateipfad>)
```
**_Makro:_**
```
$$$File.GetDirectory(<Dateipfad>)
$$$Directory(<Dateipfad>)

$$$File.GetFileName(<Dateipfad>)
$$$FileName(<Dateipfad>)
```
**_Ersetzt IRIS Funktion:_**
```
 ##class(%Library.File).ParentDirectoryName(<Verzeichnispfad>)

 ##class(%Library.File).GetFilename(<Dateipfad>)
```
Zwischen der Standard InterSystems IRIS Dateiimplementierung und der arsblue Implementation besteht kaum ein Unterschied. Die arsblue Methoden- und Makronamen sind vereinheitlicht und kürzer zu schreiben als die Standard InterSystems IRIS Methodennamen und der übergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).GetDirectory(filepath)
C:\InterSystems\IRIS\mgr\
USER>write ##class(arsblue.io.File).GetFileName(filepath)
user
```

### Datei bzw. Verzeichnis auf Existenz überprüfen

**_Syntax:_**
```
 ##class(arsblue.io.File).IsDirectory(<Dateipfad>)

 ##class(arsblue.io.File).IsFile(<Dateipfad>)
```
**_Makro:_**
```
$$$File.IsDirectory(<Dateipfad>)
$$$IsDirectory(<Dateipfad>)

$$$File.IsFile(<Dateipfad>)
$$$IsFile(<Dateipfad>)
```
**_Ersetzt IRIS Funktion:_**
```
 ##class(%Library.File).DirectoryExists(<Verzeichnispfad>)

 ##class(%Library.File).Exists(<Dateipfad>)
```
Der Unterschied zwischen der Standard InterSystems IRIS Dateiimplementierung und der arsblue Implementation ist, dass die Dateiabfrage wirklich nur Dateien und keine Verzeichnisse berücksichtigt. Die arsblue Methoden- und Makronamen sind vereinheitlicht und kürzer zu schreiben als die Standard InterSystems IRIS Methodennamen und der übergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsDirectory(filepath)
1
USER>write ##class(arsblue.io.File).IsFile(filepath)
0
```

### Datei bzw. Verzeichnis auf Inhalt überprüfen

**_Syntax:_**
```
 ##class(arsblue.io.File).IsEmpty(<Dateipfad>)
```
**_Makro:_**
```
$$$File.IsEmpty(<Dateipfad>)
$$$IsEmpty(<Dateipfad>)
```
**_Ersetzt IRIS Funktion:_**
```
 ##class(%Library.File).SizeGet()
```
Der Unterschied zwischen der Standard InterSystems IRIS Dateiimplementierung und der arsblue Implementation ist, dass in InterSystems IRIS nur der Inhalt einer Datei aber nicht der Inhalt eines Verzeichnisses kontrolliert werden kann. Die Funktion liefert nur für Verzeichnisse ohne Dateien (Eigenreferenzen `.` und übergeordnete Verzeichnisreferenzen `..` werden nicht berücksichtigt) bzw. Dateien mit einer Größe von `0` Bytes den Wert `1`. Der übergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsEmpty(filepath)
0
```

### Dateien und Verzeichnisse löschen

**_Syntax:_**
```
 ##class(arsblue.io.File).DeleteFilePath(<Dateipfad>[,<recursive>])
```
**_Makro:_**
```
$$$File.DeleteFilePath(<Dateipfad>[,<recursive>])
```
Diese Methode löscht Dateien und leere Verzeichnisse und deren übergeordneten Verzeichnisse, wenn diese keine weiteren Dateien beinhalten. Es können auch Platzhalter verwendet werden (z.B. `backups/*.bak`, `logfiles/log*.*`, usw.). Der übergebene Dateipfad wird zuvor normalisiert.
Im folgenden Beispiel werden Dateien aus einem temporären Verzeichnis gelöscht um die Funktionsweise zu beschreiben. Für die Dokumentation wurde eine Windows Installation von InterSystems IRIS verwendet. Die Funktionalität ist natürlich auf jedem System vorhanden, für das InterSystems IRIS angeboten wird.

**_Windows Eingabeaufforderung:_**
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
Wenn man eine Datei aus einem Verzeichnis löscht, in dem noch weitere Dateien oder Verzeichnisse vorhanden sind, verhält es sich wie ein Standard InterSystems IRIS Datei-Lösch-Befehl.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/my_dir1/my_dir2/my_file1.txt"))
```
**_Windows Eingabeaufforderung:_**
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
Löscht man nun alle Dateien im Verzeichnis, wird das Verzeichnis selbst und die übergeordneten Verzeichnisse gelöscht, bis zu einem Verzeichnis, dass noch andere Dateien bzw. Verzeichnisse beinhaltet.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/my_dir1/my_dir2/*.txt"))
```
**_Windows Eingabeaufforderung:_**
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
Durch explizites Setzen des 2. Parameters der Funktion auf `0` kann die Funktionalität, dass übergeordnete Verzeichnisse gelöscht werden, ausgeschaltet werden.

**_IRIS Terminal:_**
```
USER>write $System.Status.GetErrorText(##class(arsblue.io.File).DeleteFilePath("../Temp/*.txt",0))
```
**_Windows Eingabeaufforderung:_**
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
Der Vorteil dieser Methode besteht darin, dass man automatisch Verzeichnisstrukturen bereinigen kann, ohne sich darum kümmern zu müssen, ob sich noch andere Dateien oder Verzeichnisse darin befinden. Diese Funktionalität spielt vor allem beim Exportieren von Dateien oder auch beim Bereinigen von temporären oder alten Daten eine Rolle.

## Objektinstanzen von/nach JSON serialisieren

In der Standard InterSystems IRIS Implementation ist eine Objekt Serialisierung nur im XML Format (`%XML.Adaptor`) vorgesehen. Die angebotene InterSystems IRIS JSON Implementation ist leider nur für simple Datentypen und nicht für komplexe Klassen (Sammlungen, usw.) verfügbar. Mit der impliziten arsblue JSON Serialisierung können diese Probleme gelöst werden.

Um die implizite JSON Serialisierung für ein Objekt zu aktivieren, muss dieses Objekt von der JSON Serialisierung `arsblue.io.Serializable` abgeleitet werden. Ab diesem Zeitpunkt stehen die Methoden `%FromJSON(...)` um Daten aus JSON in dieses Objekt zu importieren und `%ToJSON(...)` um Daten aus diesem Objekt nach JSON zu exportieren zur Verfügung.

Um beliebige Objekte mit JSON zu serialisieren ist es nicht zwingend erforderlich von dieser Klasse abzuleiten. Es gibt auch die Möglichkeit über die JSON Hilfsprogramme jedes IRIS Objekt nach JSON zu exportieren, das von `%Library.RegisteredObject` ableitet (siehe [JSON Hilfsprogramme](https://github.com/ARSBlue/ToolBox-4-Iris/blob/master/arsblue/util/README_DE.md#json-hilfsprogramme) oder [Datenobjekte nach JSON exportieren](https://github.com/ARSBlue/ToolBox-4-Iris/blob/master/arsblue/util/README_DE.md#datenobjekte-nach-JSON-exportieren)).

(s. [Objektinstanzen von/nach JSON serialisieren](./arsblue/util/README.md#json)).

## Temporäre Dateiobjekte für Datenströme

InterSystems IRIS bietet die Möglichkeit temporäre Dateinamen zu generieren und auch binäre Datenströme aus Dateien zu lesen. Es gibt aber keinen Datentyp, der beide Funktionen miteinander verbindet. Für diesen Fall wurden die Klassen `arsblue.io.TempFileBinary` für binäre Datenströme und `arsblue.io.TempFileCharacter` für zeichenbasierte Datenströme entwickelt. Der Vorteil dieser beiden Klassen gegenüber den InterSystems IRIS Dateidatenströmen `%Stream.FileBinary` und `%Stream.FileCharacter` ist, dass kein Dateiname übergeben werden muss, d.h. automatisch ein temporärer Dateiname erzeugt wird (also eine Datei im Standard temporären Verzeichnis) und diese Datei automatisch gelöscht wird, wenn das Klassenobjekt aus dem Speicher entfernt wird. Dadurch kann es nicht passieren, dass das temporäre Verzeichnis sich unkontrolliert mit Dateien befüllt für die sich kein Programm mehr verantwortlich fühlt (z.B. %ZEN Reports, InterSystems IRIS Management Portal Import/Export, usw.). Es kann natürlich auch ein eigener temporärer Dateiname im Konstruktor übergeben werden.

Im folgenden Beispiel wird ein neuer temporärer zeichenbasierter Datenstrom erzeugt, beschrieben und automatisch gelöscht. Für die Dokumentation wurde eine Windows Installation von InterSystems IRIS verwendet. Die Funktionalität ist natürlich auf jedem System vorhanden, für das InterSystems IRIS angeboten wird.

**_Windows Eingabeaufforderung:_**
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
Ab dem Moment, in dem der Datenstrom nicht mehr leer ist, wird die entsprechende Datei im temporären Verzeichnis angelegt, wenngleich auch noch keine Daten in die Datei geschrieben wurden (siehe entsprechende Speicher- bzw. Flush-Methoden).

**_Windows Eingabeaufforderung:_**
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
Die weitere Handhabung entspricht der Klassendokumentation der Standard InterSystems IRIS Klassen.

**_Iris Terminal:_**
```
USER>kill tempfile
```
In dem Moment, wo das Klassenobjekt im Speicher nicht mehr existiert, wird auch die Datei im temporären Verzeichnis entfernt.

**_Windows Eingabeaufforderung:_**
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
Die beiden Klassen funktionieren auf dieselbe Weise, der Unterschied ist wie bei den Standard InterSystems IRIS Klassen, dass der temporäre zeichenbasierte Datenstrom mit dem entsprechenden Zeichensatz kodiert wird, während der temporäre binäre Datenstrom die Daten unverändert schreibt.
