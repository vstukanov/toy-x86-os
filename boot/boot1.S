[BITS 16]
[ORG 0x0500]

sti

mov ax, es
mov ds, ax
mov ss, ax
mov fs, ax
mov gs, ax

mov sp, 0x0400
mov bp, sp

; Save disk number
mov [DiskNum], dl

cli

jmp _mian

%include 'inc/print.S'
%include 'inc/register.S'
%include 'inc/mbr.S'
%include 'inc/chs.S'
%include 'inc/math.S'
%include 'inc/ext2fs.S'
%include 'inc/strings.S'

_mian:
  ; call MbrActiveSector
  ; jc ErrNoActivePatrition
  ; mov [DiskFirstSector], eax
  ; call EX2ReadSuperblock

  mov si, StrTest1
  mov di, StrTest2

  mov cx, 3
  call StrNCmp

  jne .ne
  mov ax, 0
  call PrintInt
  jmp .exit

  .ne:
  mov ax, 1
  call PrintInt

  .exit:

  jmp $

ErrReadSuperblock:
  mov si, ErrMsgRSB
  call Print
  mov al, ah
  call PrintByte
  call PrintNL
  jmp $

ErrNoActivePatrition:
  mov si, ErrMsgNAP
  call PrintLn
  jmp $

StrTest1        db 'Staing', 0
StrTest2        db 'Sta', 0

DiskFirstSector dd 0
DiskNum         db 1
ErrMsgRSB       db 'Read superblock err ', 0
ErrMsgNAP       db 'Active patrition not found.', 0