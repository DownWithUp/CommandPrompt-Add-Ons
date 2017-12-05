;Place in directory where cmd.exe will look to execute external commands
format PE Console ;APPTYPE CONSOLE
include 'win32a.inc' ;32bit Headers and defaults

entry start

section '.data' data readable writeable
szMessage db "Emptying Recycle Bin",0xA,0
szErrorMessageOne db "E: Unable To Empty Recycle Bin. Possibly Already Empty",0xA,0

section '.text' code readable writeable executable
error:
        invoke printf, szErrorMessageOne
        invoke ExitProcess, 0

start: ;Entry point
        invoke printf, szMessage
        invoke SHEmptyRecycleBin,0,0,0x1
        cmp eax, 0x00000000 ;S_OK
        jne error ;If the function did not execute correctly

        invoke ExitProcess, 0


section '.idata' import readable
;Used DLLs
library kernel32, 'kernel32.dll',\
        msvcrt, 'msvcrt.dll',\
        shell32, 'shell32.dll'
include 'api/kernel32.inc' ;Contains all kernel32.dll APIs
import msvcrt, printf, 'printf' ;Manual API imports
import shell32, SHEmptyRecycleBin, 'SHEmptyRecycleBinA'
