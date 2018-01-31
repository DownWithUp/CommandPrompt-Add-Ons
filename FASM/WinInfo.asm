;Based off: https://github.com/unix121/sysinfo-minimal
Format PE Console
include 'win32a.inc' ;Marcos, Consts, ect...
entry start

section '.data' data readable writable
;ASCII Windows 10 logo (poorly designed), by me :)
szW1 db '+----+----+', 0xA, 0
szW2 db '|    |    |', 9, 0  ;9 = Tab
szW3 db '|    |    |', 9, 0
szW4 db '+----|----+', 9, 0
szW5 db '|    |    |', 9, 0
szW6 db '|    |    |', 9, 0
szW7 db '+----+----+', 0
;End logo
szUserName db 'User: %s', 0xA, 0
szPCName db 'Computer: %s', 0xA, 0
szArchTrue db 'Is Windows x64: True', 0xA, 0
szArchFalse db 'Is Windows x64: False', 0xA, 0
szTick db 'Tick Count: %u', 0xA, 0
szGetCMDId db "This CMD Prompt's PID: %u", 0xA, 0
nSizeOfUserName dd 256
nSizeOfPCName dd 256

section '.bss' readable writeable
lpUserName rb 256
lpPCName rb 256
pbIs64 dd ?

section '.text' code readable writable executable
archFalse:
        invoke printf, szArchFalse
        invoke printf, szW5 ; Log line 5
        jmp continue
start:
        invoke printf, szW1
        invoke printf, szW2 ;Logo line 2

        invoke GetUserName, lpUserName, nSizeOfUserName
        invoke printf, szUserName, lpUserName
        invoke printf, szW3 ;Logo line 3
        invoke GetComputerName, lpPCName, nSizeOfPCName
        invoke printf, szPCName, lpPCName
        invoke printf, szW4 ;Logo line 4
        invoke GetCurrentProcess ;Need Handle for Wow64 API
        invoke IsWow64Process, eax, pbIs64
        cmp [pbIs64], FALSE ;#define FALSE 0
        je archFalse
        invoke printf, szArchTrue
        invoke printf, szW5 ;Logo line 5
        continue:
                invoke GetTickCount
                invoke printf, szTick, eax
                invoke printf, szW6 ;Logo line 6
                nop
                invoke RtlGetConsoleSessionForegroundProcessId ;Awesome API, but rarely used.
                invoke printf, szGetCMDId, eax
                invoke printf, szW7
                ;invoke Sleep, 10000 ;DEBUG ONLY
                invoke ExitProcess, 0

section '.idata' import readable writable
library kernel32, 'kernel32.dll',\
        advapi32, 'advapi32.dll',\
        msvcrt, 'msvcrt.dll',\
        ntdll, 'ntdll.dll'
include 'api/advapi32.inc'
include 'api/kernel32.inc'
import msvcrt,\
       printf,'printf'
import ntdll,\
       RtlGetConsoleSessionForegroundProcessId, 'RtlGetConsoleSessionForegroundProcessId'
