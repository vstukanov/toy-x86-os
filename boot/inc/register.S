PrintR:
  push si
  push ax

  ; Print name
  call Print

  mov si, REGS.Equal
  call Print

  pop ax
  call PrintWord
  call PrintNL

  pop si
  ret

PrintRG:
  push si
  push ax
  push ax

  ; Print name
  call Print

  mov si, REGS.Equal
  call Print

  pop ax
  call PrintWord

  mov al, '['
  call PrintChr

  pop ax
  call PrintInt
  mov al, ']'
  call PrintChr

  call PrintNL

  pop si
  ret

PrintAllSR:
  push si
  push ax

  mov si, REGS.SegName
  call PrintLn

  ; Rigster SS
  mov si, REGS.SS
  mov ax, ss
  call PrintR
  ; End

  ; Rigster CS
  mov si, REGS.CS
  mov ax, cs
  call PrintR
  ; End

  ; Rigster DS
  mov si, REGS.DS
  mov ax, ds
  call PrintR
  ; End

  ; Rigster ES
  mov si, REGS.ES
  mov ax, es
  call PrintR
  ; End

  ; Rigster FS
  mov si, REGS.FS
  mov ax, fs
  call PrintR
  ; End

  ; Rigster GS
  mov si, REGS.GS
  mov ax, gs
  call PrintR
  ; End

  call PrintNL

  pop ax
  pop si
  ret

PrintAllGR:
  push si

  push ax
  push bx
  push cx
  push dx
  
  push dx
  push cx
  push bx
  push ax

  mov si, REGS.GenName
  call PrintLn

  ; Rigster AX
  mov si, REGS.AX
  pop ax
  call PrintRG
  ; End

  ; Rigster BX
  mov si, REGS.BX
  pop bx
  mov ax, bx
  call PrintRG
  ; End
  
  ; Rigster CX
  mov si, REGS.CX
  pop cx
  mov ax, cx
  call PrintRG
  ; End

  ; Rigster DX
  mov si, REGS.DX
  pop dx
  mov ax, dx
  call PrintRG
  ; End

  call PrintNL

  pop dx
  pop cx
  pop bx
  pop ax

  pop si
  ret


REGS:
  .SegName db 'Segment Registers:', 0
  .GenName db 'General Registers:', 0

  .Equal db ' = 0x', 0

  .SS db 'SS', 0
  .CS db 'CS', 0
  .DS db 'DS', 0
  .ES db 'ES', 0
  .FS db 'FS', 0
  .GS db 'GS', 0

  .AX db 'AX', 0
  .BX db 'BX', 0
  .CX db 'CX', 0
  .DX db 'DX', 0

  .SI db 'FS', 0
  .DI db 'GS', 0