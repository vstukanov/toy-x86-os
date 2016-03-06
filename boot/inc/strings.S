
; SI:DI - two pointers to strings
StrCmp:
  push si
  push di

  cld

  .lp:
  cmpsb
  jne .exit

  lahf

  mov al, [si - 1]
  or al, al
  jnz .lp

  sahf

  .exit:

  pop di
  pop si
  ret

; CX    - characters to compare
; SI:DI - two pointers to strings
StrNCmp:
  repe cmpsb 
  ret