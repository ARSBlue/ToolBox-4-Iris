ROUTINE arsblue.io.File [Type=INC]
/// This include extends the functionality of %occFile and contains macros for working with files and directories

/// common file class
#define File						##class(arsblue.io.File)

/// file getter macros
#def1Arg FilePath(%file)			$$$File.GetFilePath(%file)
#define Directory(%file)			$$$File.GetDirectory(%file)
#define FileName(%file)				$$$File.GetFileName(%file)

/// file checker macros
#define IsFile(%file)				$$$File.IsFile(%file)
#define IsDirectory(%file)			$$$File.IsDirectory(%file)
#define IsEmpty(%file)				$$$File.IsEmpty(%file)
