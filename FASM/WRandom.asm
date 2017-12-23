format PE Console
include 'win32a.inc' ;For some macros like invoke
entry start ;Entry point for code

section '.data' data readable
;All values displayed are UNSIGNED!
szMsgBoolTrue db 'Random Boolean: True',0xA,0
szMsgBoolFalse db 'Random Boolean: False',0xA,0
szMsgByte db 'Random Byte Value (0-255): %u',0xA,0
szMsg16 db 'Random 16-bit Value (0-65535): %u',0xA,0
szMsg32 db 'Random 32-bit Value (0-4294967295): %u',0 ;Last line, so no newline needed
szContainer db 'MyContainer',0

section '.bss' data readable writable
phProv dd ? ;Provider
buff dd 0

section '.text' code readable writable executable
start:
        invoke CryptAcquireContext, phProv, szContainer, NULL, 1, 8 ;1 = PROV_RSA_FULL, 8 = CRYPT_NEWKEYSET
        invoke GetLastError
        cmp eax, 0x8009000F ;Container already exsists
        jne skipNext
        invoke CryptAcquireContext, phProv, szContainer, NULL, 1, 0 ;1 = PROV_RSA_FULL
        skipNext:
        ;Gen Values
        invoke CryptGenRandom, [phProv], 1, buff
        mov eax, DWORD[buff]
        xor edx, edx ;Zero out edx
        mov ebx, 2
        div ebx
        ;edx is mod
        cmp edx, 1
        jne false
        true:
                invoke printf, szMsgBoolTrue
                jmp genNums
        false:
                invoke printf, szMsgBoolFalse
        genNums:
        invoke CryptGenRandom, [phProv], 1, buff ;1 Byte
        invoke printf, szMsgByte, DWORD [buff]
        invoke CryptGenRandom, [phProv], 2, buff ;2 Bytes (16 bit)
        invoke printf, szMsg16, DWORD [buff]
        invoke CryptGenRandom, [phProv], 4, buff ;4 Bytes (32 bit)
        invoke printf, szMsg32, DWORD [buff]
        exit:
                invoke ExitProcess, 0 ;Exit Program

section '.idata' import readable writable
library kernel32, 'kernel32.dll',\
        advapi32, 'Advapi32.dll',\
        msvcrt, 'msvcrt.dll'

include 'api/kernel32.inc'
include 'api/advapi32.inc'
import msvcrt, printf, 'printf' ;Manual API imports
