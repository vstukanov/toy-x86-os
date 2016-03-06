[BITS 16]
[ORG 0x7C00]

cli

mov ax, cs

mov ds, ax
mov es, ax
mov ss, ax
mov fs, ax
mov gs, ax

mov bp, sp
sti

jmp _main

_main:
  mov ax, 0x1000
  mov es, ax
  mov bx, 0x500

  mov ah,0x2

  mov ch,0x0 ; Cylinder
  mov dh,0x0 ; Head
  mov cl,0x2 ; Sector

  mov al,0x3
  
  int 0x13

  jc Error

  jmp 0x1000:0x0500

  jmp $

Error:
  jmp $
  ret

TIMES 446 - ($ - $$) db 0
