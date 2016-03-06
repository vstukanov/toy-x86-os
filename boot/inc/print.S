Print4bit:
  cmp al, 0x9

  jle .digit
  jmp .char

  .digit:
  add al, 0x30
  jmp .finish

  .char:
  add al, 0x37

  .finish:

  call PrintChr
  ret

PrintByte:
  mov dl, al

  sar al, 0x4
  and al, 0x0F

  call Print4bit

  mov al, dl
  and al, 0x0F

  call Print4bit
  ret

PrintWord:
  mov dl, al
  mov al, ah

  push dx
  call PrintByte
  pop dx

  mov al, dl
  call PrintByte
  ret

PrintBuffer:
  push bp
  mov bp, sp
  sub sp, 2
  push si

  ; init counter
  mov word [bp - 2], 0

  .lp:
  ; end off loop ?
  or cx, cx
  jz .elp

  dec cx
  inc word [bp - 2]

  lodsb
  call PrintByte

  mov al, ' '
  call PrintChr

  mov al, [bp - 2]
  and al, 0x0F
  or al, al
  jnz .skipNL

  call PrintNL
  jmp .lp
  
  .skipNL:

  mov al, [bp - 2]
  and al, 0x3
  or al, al
  jnz .lp

  mov al, '|'
  call PrintChr

  mov al, ' '
  call PrintChr

  jmp .lp

  .elp:

  mov al, [bp - 2]
  and al, 0x0F
  or al, al
  jz .fin

  call PrintNL

  .fin:

  pop si
  mov sp, bp
  pop bp
  ret

PrintChr:
  push bx
  mov ah, 0x0e
  mov bh, 0x00
  mov bl, 0x07
  pop bx
  int 0x10
  ret

Print:
  cld
  .nextc:
  lodsb
  or al, al

  JZ .exit

  call PrintChr
  jmp .nextc

  .exit:
  ret

PrintNL:
  mov al, 10
  call PrintChr

  mov al, 13
  call PrintChr
  ret

PrintLn:
  call Print
  call PrintNL
  ret

PrintInt:
  push dx
  push bx

  xor dx, dx

  mov bx, 10
  xor cl, cl

  .next:
  div bx
  push dx
  xor dx, dx
  inc cl

  or ax, ax
  jz .print
  jmp .next

  .print:
  dec cl
  pop dx
  mov al, dl
  add al, byte '0'
  call PrintChr
  or cl, cl
  jnz .print

  pop bx
  pop dx
  ret