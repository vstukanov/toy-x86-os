
; RET
; EAX - Volume offset
MbrActiveSector:
  push ds
  push si

  xor cl, cl
  xor ax, ax

  mov ds, ax
  mov dx, 0x7DBE
  cld

  .read:
  mov si, dx
  lodsb
  cmp al, 0x80
  jne .skip

  add si, 7

  lodsd
  
  jmp .exit

  .skip:
  inc cl
  cmp cl, 0x4
  je .exitCary
  add dx, 0x10
  jmp .read

  .exitCary:
  stc
  .exit:
  pop si
  pop ds
  ret