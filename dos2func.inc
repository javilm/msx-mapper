; C: CP/M compatible
; 1: MSX-DOS(1) compatible
; E: Does error management

_TERM0		equ	000h	; Terminate program			C1
_CONIN		equ	001h	; Console input				C1E
_CONOUT		equ	002h	; Console output			C1E
_AUXIN		equ	003h	; AUX input				C1E
_AUXOUT		equ	004h	; AUX output				C1E
_LSTOUT		equ	005h	; Printer output			C1E
_DIRIO		equ	006h	; Direct console I/O			C1E
_DIRIN		equ	007h	; Direct console input			 1E
_INNOE		equ	008h	; Console input without echo		 1E
_STROUT		equ	009h	; String output				C1E
_BUFIN		equ	00ah	; Buffered input			C1E
_CONST		equ	00bh	; Console status			C1E
_CPMVER		equ	00ch	; CP/M version				C1E
_DSKRST		equ	00dh	; Disk reset				C1
_SELDSK		equ	00eh	; Disk select				C1
_FOPEN		equ	00fh	; Open file (FCB)			C1
_FCLOSE		equ	010h	; Close file (FCB)			C1
_SFIRST		equ	011h	; Find first entry (FCB)		C1
_SNEXT		equ	012h	; Find next entry (FCB)			C1
_FDEL		equ	013h	; Delete file (FCB)			C1
_RDSEQ		equ	014h	; Sequential read (FCB)			C1
_WRSEQ		equ	015h	; Sequential write (FCB)		C1
_FMAKE		equ	016h	; Create file (FCB)			C1
_FREN		equ	017h	; Rename file (FCB)			C1
_LOGIN		equ	018h	; Get login vector			C1E
_CURDRV		equ	019h	; Get current drive			C1E
_SETDTA		equ	01ah	; Set disk transfer address		C1
_ALLOC		equ	01bh	; Get allocation information		 1
; 01ch to 020h undefined
_RDRND		equ	021h	; Random read (FCB)			C1
_WRRND		equ	022h	; Random write (FCB)			C1
_FSIZE		equ	023h	; Get file size (FCB)			C1
_SETRND		equ	024h	; Set random record (FCB)		C1
; 025h undefined
_WRBLK		equ	026h	; Write random block (FCB)		 1
_RDBLK		equ	027h	; Read random block (FCB)		 1
_WRZER		equ	028h	; Write random block w/zero fill (FCB)	C1
; 029h undefined
_GDATE		equ	02ah	; Get date				 1E
_SDATE		equ	02bh	; Set date				 1E
_GTIME		equ	02ch	; Get time				 1E
_STIME		equ	02dh	; Set time				 1E
_VERIFY		equ	02eh	; Set/reset the verify flag		 1E
_RDABS		equ	02fh	; Read absolute sector			 1E
_WRABS		equ	030h	; Write absolute sector			 1E
_DPARM		equ	031h	; Get disk parameters			  E
; 032h to 03fh undefined
_FFIRST		equ	040h	; Find first entry
_FNEXT		equ	041h	; Find next entry
_FNEW		equ	042h	; Find new entry
_OPEN		equ	043h	; Open file handle
_CREATE		equ	044h	; Create file handle
_CLOSE		equ	045h	; Close file handle
_ENSURE		equ	046h	; Ensure file handle
_DUP		equ	047h	; Duplicate file handle
_READ		equ	048h	; Read from file handle
_WRITE		equ	049h	; Write to file handle
_SEEK		equ	04ah	; Move file handle pointer
_IOCTL		equ	04bh	; I/O device control
_HTEST		equ	04ch	; Test file handle
_DELETE		equ	04dh	; Delete file or subdirectory
_RENAME		equ	04eh	; Rename file or subdirectory
_MOVE		equ	04fh	; Move file or subdirectory
_ATTR		equ	050h	; Get/set file attributes
_FTIME		equ	051h	; Get/set file date and time
_HDELETE	equ	052h	; Delete file handle
_HRENAME	equ	053h	; Rename file handle
_HMOVE		equ	054h	; Move file handle
_HATTR		equ	055h	; Get/set file handle attributes
_HFTIME		equ	056h	; Get/set file handle date and time
_GETDTA		equ	057h	; Get disk transfer address		  E
_GETVFY		equ	058h	; Get verify flag status		  E
_GETCD		equ	059h	; Get the current directory
_CHDIR		equ	05ah	; Change the current directory
_PARSE		equ	05bh	; Parse path name
_PFILE		equ	05ch	; Parse file name
_CHKCHR		equ	05dh	; Check character			  E
_WPATH		equ	05eh	; Get full path
_FLUSH		equ	05fh	; Flush disk buffer
_FORK		equ	060h	; Launch child process
_JOIN		equ	061h	; Return to parent process
_TERM		equ	062h	; Terminate with error code
_DEFAB		equ	063h	; Define abort routine
_DEFER		equ	064h	; Define error handling routine
_ERROR		equ	065h	; Get previous error code		  E
_EXPLAIN	equ	066h	; Explain error code			  E
_FORMAT		equ	067h	; Format disk
_RAMD		equ	068h	; Create or destroy RAM disk
_BUFFER		equ	069h	; Allocate sector buffer
_ASSIGN		equ	06ah	; Assign logical drive			  E
_GENV		equ	06bh	; Get environment variable		  E
_SENV		equ	06ch	; Set environment variable		  E
_FENV		equ	06dh	; Find environment variable		  E
_DSKCHK		equ	06eh	; Get/set disk check status		  E
_DOSVER		equ	06fh	; Get MSX-DOS version number		  E
_REDIR		equ	070h	; Get/set redirection status		  E

