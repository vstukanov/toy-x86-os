CHSMove:
  mov ah, cl

  ; Lower 6 bit
  and ah, 0x3F
  add ah, al

  cmp ah, 0x3F
  jle .fin

  sub ah, 0x3F
  add dh, 1
  adc ch, 0

  jnc .fin

  mov al, cl
  sar al, 6
  and al, 0x3
  inc al
  sal al, 6
  mov cl, al

  .fin:

  ; Keep higher two bits
  and cl, 0xC0
  add cl, ah
  ret

CHSPrint:
  push bp
  mov  bp, sp
  sub sp, 6

  push cx
  push dx

  mov [bp - 2], ch
  mov [bp - 4], dh
  mov [bp - 6], cl

  mov si, CHSMsg
  call Print

  xor ax, ax
  mov al, [bp - 6]
  and al, 0xC0
  sal ax, 2
  mov al, [bp - 2]
  call PrintInt

  mov al, ','
  call PrintChr

  xor ax, ax
  add al, [bp - 4]
  call PrintInt

  mov al, ','
  call PrintChr

  xor ax, ax
  add al, [bp - 6]
  and al, 0x3F
  call PrintInt

  mov al, ')'
  call PrintChr
  call PrintNL

  pop dx
  pop cx

  mov sp, bp
  pop bp
  ret

CHSMsg db 'CHS = (', 0