; BigSub:
;   push bp
;   mov bp, sp
;   sub sp, 4

;   push ax

;   lodsw
;   mov [bp - 2], ax
;   lodsw
;   mov [bp - 4], ax

;   pop ax

;   clc
;   sub ax, [bp - 2]
;   sbb dx, [bp - 4]

;   mov sp, bp
;   pop bp
;   ret

; BigCmp:
;   push bp
;   mov bp, sp

;   sub sp, 4

;   push ax

;   lodsw
;   mov [bp - 2], ax
;   lodsw
;   mov [bp - 4], ax

;   cmp dx, [bp - 4]

;   jne .exit

;   pop ax
;   cmp ax, [bp - 2]

;   .exit:
  
;   mov sp, bp
;   pop bp
;   ret

; ; DX:AX
; ; SI - source of 
; BigDiv:
;   push bp
;   mov bp, sp
;   sub sp, 12

;   ; Keep input
;   push si
;   mov [bp - 2], ax
;   mov [bp - 4], dx
;   lodsw
;   mov [bp - 6], ax
;   lodsw
;   mov [bp - 8], ax
;   pop si

;   ; Higher word is 0, we can use DIV instr
;   or ax, ax
;   jnz .nsimple

;   mov ax, [bp - 2]
;   mov dx, [bp - 4]

;   div word [bp - 6]

;   jmp .fin

;   .nsimple:

;   mov ax, [bp - 4]
;   xor dx, dx

;   div word [bp - 8]

;   ; remember aprox
;   mov [bp - 10], ax

;   ; mul highr word
;   mov ax, [bp - 8]
;   mul word [bp - 10]
;   ; remember mul higher word
;   mov [bp - 12], ax

;   ; mul lower word
;   mov ax, [bp - 6]
;   mul word [bp - 10]

;   ; Add higher result to lower
;   add dx, [bp - 12]

;   mov [bp - 6], ax
;   mov [bp - 8], dx

;   mov ax, [bp - 2]
;   mov dx, [bp - 4]
;   lea si, [bp - 6]

;   call BigCmp

;   je .eq
;   jl .less

;   .eq:
;   mov ax, [bp - 10]
;   xor dx, dx
;   jmp .fin

;   .less:

;   .more:

;   push dx

;   call PrintWord
;   call PrintNL

;   pop dx
;   mov ax, dx

;   call PrintWord

;   jmp $

;   .fin:

;   mov sp, bp
;   pop bp
;   ret