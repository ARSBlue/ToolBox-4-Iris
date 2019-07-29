# ARSBlue IRIS IO Package

## Datei und Verzeichnis Funktionen

In der Standard IRIS Klasse `%Library.File` sind bereits viele Funktionen vorhanden. Die hier beschriebenen Funktionen kombinieren einige der Funktionen bzw. erweitern sie f�r einen verbesserten Umgang mit Dateien und Verzeichnissen. Zum einen stehen die Funktionen der Klasse `arsblue.io.File` zur Verf�gung und zum anderen gibt es das entsprechende Makro `arsblue.io.File` um die wichtigsten Funktionen der Klasse in gek�rzter Schreibweise im Quellcode verwenden zu k�nnen. Im Folgenden werden die Funktionen immer mit dem �quivalenten Makro (sofern vorhanden) beschrieben.

### Dateimakro in Quellcode einbinden

Um das Makro im eigenen Quellcode verwenden zu k�nnen, ist es notwendig es in der ersten Zeile der Klasse einzubinden.
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
Der Unterschied zwischen der Standard IRIS Dateiimplementierung und der ars-blue Implementation liegt darin, dass es m�glich ist, beliebig viele Teile des Dateinamens anzugeben und alle Teile zu einem normalisierten Dateipfad zusammengef�gt werden. Wird der erste Teil der Datei relativ angegeben, d.h. es handelt sich nicht um einen Pfadseparator oder eine Festplattenidentifizierung, wird der aktuelle Verzeichnispfad herangezogen. Auch erfordert die Standard IRIS Implementierung, dass ein Verzeichnis, falls angegeben, bereits existieren muss.
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
Zwischen der Standard IRIS Dateiimplementierung und der ars-blue Implementation besteht kaum ein Unterschied. Die ars-blue Methoden- und Makronamen sind vereinheitlicht und k�rzer zu schreiben als die Standard IRIS Methodennamen und der �bergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).GetDirectory(filepath)
C:\InterSystems\IRIS\mgr\
USER>write ##class(arsblue.io.File).GetFileName(filepath)
user
```

### Datei bzw. Verzeichnis auf Existenz �berpr�fen

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
Der Unterschied zwischen der Standard IRIS Dateiimplementierung und der ars-blue Implementation ist, dass die Dateiabfrage wirklich nur Dateien und keine Verzeichnisse ber�cksichtigt. Die ars-blue Methoden- und Makronamen sind vereinheitlicht und k�rzer zu schreiben als die Standard IRIS Methodennamen und der �bergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsDirectory(filepath)
1
USER>write ##class(arsblue.io.File).IsFile(filepath)
0
```

### Datei bzw. Verzeichnis auf Inhalt �berpr�fen

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
Der Unterschied zwischen der Standard IRIS Dateiimplementierung und der ars-blue Implementation ist, dass in IRIS nur der Inhalt einer Datei aber nicht der Inhalt eines Verzeichnisses kontrolliert werden kann. Die Funktion liefert nur f�r Verzeichnisse ohne Dateieintrag (Eigenreferenzen und �bergeordnete Verzeichnisreferenzen werden nicht ber�cksichtigt) bzw. Dateien mit einer Gr��e von null Bytes den Wert 1. Der �bergebene Dateipfad wird zuvor normalisiert.
```
USER>set filepath=##class(arsblue.io.File).GetFilePath()
USER>write filepath
C:\InterSystems\IRIS\mgr\user
USER>write ##class(arsblue.io.File).IsEmpty(filepath)
0
```

### Dateien und Verzeichnisse l�schen

**_Syntax:_**
```
 ##class(arsblue.io.File).DeleteFilePath(<Dateipfad>[,<recursive>])
```
**_Makro:_**
```
$$$File.DeleteFilePath(<Dateipfad>[,<recursive>])
```
Diese Methode l�scht Dateien und leere Verzeichnisse und deren �bergeordneten Verzeichnisse, wenn diese keine weiteren Dateien beinhalten. Es k�nnen auch Platzhalter verwendet werden (z.B. `backups/*.bak`, `logfiles/log*.*`, usw.). Der �bergebene Dateipfad wird zuvor normalisiert.
Im folgenden Beispiel werden Dateien aus einem tempor�ren Verzeichnis gel�scht um die Funktionsweise zu beschreiben. F�r die Dokumentation wurde eine Windows Installation von IRIS verwendet. Die Funktionalit�t ist nat�rlich auf jedem System vorhanden, f�r das IRIS angeboten wird.

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
Wen man eine Datei aus einem Verzeichnis l�scht, in dem noch weitere Dateien oder Verzeichnisse vorhanden sind, verh�lt es sich wie ein Standard IRIS Datei-L�sch-Befehl.

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
L�scht man nun alle Dateien im Verzeichnis, wird das Verzeichnis selbst und die �bergeordneten Verzeichnisse gel�scht, bis zu einem Verzeichnis, dass noch andere Dateien bzw. Verzeichnisse beinhaltet.

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
Durch explizites Setzen kann die Funktionalit�t, dass �bergeordnete Verzeichnisse gel�scht werden, ausgeschaltet werden.

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
Der Vorteil dieser Methode besteht darin, dass man automatisch Verzeichnisstrukturen bereinigen kann, ohne sich darum k�mmern zu m�ssen, ob sich noch andere Dateien oder Verzeichnisse darin befinden. Diese Funktionalit�t spielt vor allem beim Exportieren von Dateien oder auch beim Bereinigen von tempor�ren oder alten Daten eine Rolle.

## Objektinstanzen von/nach JSON serialisieren

In der Standard IRIS Implementation ist eine Objekt Serialisierung nur im XML Format (`%XML.Adaptor`) vorgesehen. Die angebotene IRIS JSON Implementation ist leider nur f�r simple Datentypen und nicht f�r komplexe Klassen (Sammlungen, usw.) verf�gbar. Mit der impliziten ars-blue JSON Serialisierung k�nnen diese Probleme gel�st werden.

Um die implizite JSON Serialisierung f�r ein Objekt zu aktivieren, muss dieses Objekt von der JSON Serialisierung `arsblue.io.Serializable` abgeleitet werden. Ab diesem Zeitpunkt stehen die Methoden `%FromJSON` um Daten aus JSON in dieses Objekt zu importieren und `%ToJSON` um Daten aus diesem Objekt nach JSON zu exportieren zur Verf�gung.

Um beliebige Objekte mit JSON zu serialisieren ist es nicht zwingend erforderlich von dieser Klasse abzuleiten. Es gibt auch die M�glichkeit �ber die JSON Hilfsprogramme jedes IRIS Objekt nach JSON zu exportieren, das von `%Library.RegisteredObject` ableitet (s. [N�tzliche Hilfsprogramme](./arsblue/util/README.md#json)).

## Tempor�re Dateiobjekte f�r Datenstr�me

IRIS bietet die M�glichkeit tempor�re Dateinamen zu generieren und auch bin�re Datenstr�me aus Dateien zu lesen, es gibt aber keinen Datentyp, der beide Funktionen miteinander verbindet. F�r diesen Fall wurden die Klassen `arsblue.io.TempFileBinary` f�r bin�re Datenstr�me und `arsblue.io.TempFileCharacter` f�r zeichenbasierte Datenstr�me entwickelt. Der Vorteil dieser beiden Klassen gegen�ber den IRIS Dateidatenstr�men `%Stream.FileBinary` und `%Stream.FileCharacter` ist, dass kein Dateiname �bergeben werden muss, d.h. automatisch ein tempor�rer Dateiname erzeugt wird (also eine Datei im Standard tempor�ren Verzeichnis) und diese Datei automatisch gel�scht wird, wenn das Klassenobjekt aus dem Speicher entfernt wird. Dadurch kann es nicht passieren, dass das tempor�re Verzeichnis sich unkontrolliert mit Dateien bef�llt, f�r die sich kein Programm mehr verantwortlich f�hlt (z.B. %ZEN Reports, IRIS Management Portal Import/Export, usw.). Es kann nat�rlich auch ein eigener tempor�rer Dateiname im Konstruktor �bergeben werden.

Im folgenden Beispiel wird ein neuer tempor�rer zeichenbasierter Datenstrom erzeugt, beschrieben und automatisch gel�scht. F�r die Dokumentation wurde eine Windows Installation von IRIS verwendet. Die Funktionalit�t ist nat�rlich auf jedem System vorhanden, f�r das IRIS angeboten wird.

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
 
USER>write $System.Status.GetErrorText(tempfile.WriteLine("Das ist ein tempor�rer Datenstrom"))
```
Ab dem Moment, in dem der Datenstrom nicht mehr leer ist, wird die entsprechende Datei im tempor�ren Verzeichnis angelegt, wenngleich auch noch keine Daten in die Datei geschrieben wurden (siehe entsprechende Speicher- bzw. Flush-Methoden).

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
Die weitere Handhabung entspricht der Klassendokumentation der Standard IRIS Klassen.

**_Iris Terminal:_**
```
USER>kill tempfile
```
In dem Moment, wo das Klassenobjekt im Speicher nicht mehr existiert, wird auch die Datei im tempor�ren Verzeichnis entfernt.

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
Die beiden Datentypen funktionieren auf dieselbe Weise, der Unterschied ist wie bei den Standard IRIS Klassen, dass der tempor�re zeichenbasierte Datenstrom mit dem entsprechenden Zeichensatz kodiert wird, w�hrend der tempor�re bin�re Datenstrom die Daten unver�ndert schreibt.
