Format PE64 Console
include 'win64a.inc'
entry start

section '.data' readable writeable
; Some Constants
CRYPT_VERIFYCONTEXT equ 0xF0000000
PROV_RSA_AES        equ 24
CALG_SHA_256        equ 0x800C
HP_HASHVAL          equ 0x2

dwBytesRead dd ?
szErrorMsg  db "[!] Usage: SHA256.exe [FILE]", 0xA, 0
bReadFile   rb 0x512
szFormat    db "%X", 0
hProv       dq ?
hHash       dq ?
hFile       dq ?
pArgc       dq ?
pArgv       dq ?
sInfo       STARTUPINFO
pEnv        dq ?
bSHA        rb 32d

section '.text' readable writable executable
start:
        sub rsp, 8 ; Align stack
        cinvoke __getmainargs, pArgc, pArgv, pEnv, 0, sInfo
        mov rcx, [pArgc]
        cmp rcx, 2d ; Need ONLY 2 arguments
        jne badExit
        mov rcx, [pArgv]
        mov r10, [rcx] ; R10 points to fist argument in pArgc.
        cinvoke strlen, r10
        inc rax ; Add 1 byte for null (0x00) at the end of the first string
        add r10, rax ; RAX now points to second argument
        ; ! No function error checking !
        invoke CreateFileA, r10, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0
        mov [hFile], rax
        ;lea rax, [hProv]
        invoke CryptAcquireContextA, hProv, 0, 0, PROV_RSA_AES, CRYPT_VERIFYCONTEXT
        invoke CryptCreateHash, [hProv], CALG_SHA_256, 0, 0, hHash
        @@:
        invoke ReadFile, [hFile], bReadFile, 0x512, dwBytesRead, 0
        cmp DWORD [dwBytesRead], 0
        je @f ; Break the loop
        invoke CryptHashData, [hHash], bReadFile, [dwBytesRead], 0
        jmp @b
        @@:
        mov [dwBytesRead], 64d ; Repurpose variable
        invoke CryptGetHashParam, [hHash], HP_HASHVAL, bSHA, dwBytesRead, 0
        mov rsi, 0 ; rsi will be our index into bSHA
        @@:
        mov edi, DWORD [bSHA + rsi]
        bswap edi
        cinvoke printf, szFormat, edi
        cmp rsi, 32d ; Size of a SHA256 hash
        je @f
        add rsi, 4d
        jmp @b
        @@:
        invoke CryptReleaseContext, [hProv], 0
        invoke CryptDestroyHash, [hHash]
        invoke CloseHandle, [hFile]
        invoke ExitProcess, 0

        badExit:
        cinvoke printf, szErrorMsg
        invoke ExitProcess, -1

section '.idata' import readable writable
library kernel32, 'kernel32.dll',\
        advapi32, 'advapi32.dll',\
        msvcrt,   'msvcrt.dll'

include 'API\Kernel32.inc'
import advapi32,\
       CryptAcquireContextA, 'CryptAcquireContextA',\
       CryptCreateHash, 'CryptCreateHash',\
       CryptGetHashParam, 'CryptGetHashParam',\
       CryptHashData, 'CryptHashData',\
       CryptReleaseContext, 'CryptReleaseContext',\
       CryptDestroyHash, 'CryptDestroyHash'
import msvcrt,\
       printf, 'printf',\
       strlen, 'strlen',\
       __getmainargs, '__getmainargs'
