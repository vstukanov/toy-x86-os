
; EAX   - Secotrs offset 
;  CX   - Count to read
; ES:BX - Destination buffer 
EX2ReadSectors:
  ; Head
  mov byte[AddrPack + 0], 0x10
  mov byte[AddrPack + 1], 0x0

  ; Count to read
  mov [AddrPack + 2], cx

  ; Buffer
  mov [AddrPack + 4], bx
  mov [AddrPack + 6], es

  ; Sectors offset
  mov [AddrPack + 8], eax
  mov dword [AddrPack + 12], 0x0

  mov dl, [DiskNum]  ; Retrive disk num
  mov ah, 0x42       ; ExtRead command
  mov si, AddrPack

  int 0x13
  ret

; EAX - block number
; ES:BX - buffer
EX2ReadBlock:
  ; First translate Block ID to Sector offset
  mov cl, [EXT2.SectorShift]
  .lp:
    or cl, cl
    jz .fin
    shl eax, 1
    dec cl
    jmp .lp
  .fin:

  ; call PrintAllGR

  ; Calc volume offset + block offset
  add eax, dword [DiskFirstSector]
  mov cx, [EXT2.SectorsPerBlock]

  call PrintAllGR

  call EX2ReadSectors
  ret

EXT2ClearBlockBuffer:
  push di
  push ds

  ; Goto readed data segment 
  mov ax, [EXT2.ReadedDataSegment]
  mov ds, ax

  ; Fill with zro
  xor eax, eax

  ; Set destination buffer
  mov di, [EXT2.OffsetCurrentBlock]

  ; 1024b = (256 * 4b)
  mov cx, 0x100

  rep stosd

  pop ds
  pop di
  ret

; ES:BX - Read buffer
EX2ListDirectory:
  push ds
  push si
  push bx

  mov ax, es
  mov ds, ax

  .read_entry:

  mov si, bx

  ; Read inode
  lodsd

  ; Exit if inode equal zero
  or eax, eax
  jz .exit

  ; call PrintInt

  ; mov al, ' '
  ; call PrintChr

  ; Read and remember record length
  lodsw
  push ax

  ; Read name length
  lodsb
  mov cl, al

  inc si

  .lp:
  lodsb
  call PrintChr
  dec cl

  or cl, cl
  jnz .lp

  call PrintNL

  pop ax
  add bx, ax

  jmp .read_entry

  .exit:
  
  pop bx
  pop si
  pop ds
  ret

; SI - Pointer to path
EXT2ResolvePath:
  push bp
  mov bp, sp
  push si
  push di

  ; 256 byte buffer for name
  sub sp, 0x100

  .skip_trailing:
  mov al, [si]
  cmp al, '/'
  jne .next_folder
  inc si
  jmp .skip_trailing

  .next_folder:

  ; Set di to buffer begining
  lea ax, [bp - 0x100]
  mov di, ax

  mov al, [si]
  cmp al, '/'
  je .load_inode

  movsb

  .load_inode:

  pop di
  pop si
  mov sp, bp
  pop bp
  ret

EX2ReadSuperblock:

  ; Dest buffer [0x2000:0x0]
  mov ax, [EXT2.ReadedDataSegment]
  mov es, ax
  xor bx, bx

  ; Volume offset + 1024b gap
  xor eax, eax
  mov ax, [DiskFirstSector]
  add eax, 2

  ; Read 1024kb
  mov cx, 0x2

  call EX2ReadSectors

  jc ErrReadSuperblock

  ; Read constants

  ; Ext2 Version
  mov eax, [es:76]
  mov [EXT2.MajorVersion], eax

  ; Major 1 specific 
  or eax, eax
  jz .notVersionOne

  mov ax, [es:88]
  mov [EXT2.InodeStructSize], ax

  .notVersionOne:

  ; Block size = 1024 << [field]
  mov cx, [es:24]
  sal dword [EXT2.BlockSize], cl

  ; Bit to shift [block -> sector]
  inc cl ; We need to add 1 because base block size 1024 but sector size 512
  mov [EXT2.SectorShift], cl

  ; Calculate sectors per block ((block_size) / 512)
  xor dx, dx
  mov eax, [EXT2.BlockSize]
  mov cx, 0x200
  div cx
  mov [EXT2.SectorsPerBlock], ax

  ; Total inodes
  mov eax, [es:0x0]
  mov [EXT2.TotalInodes], eax

  ; Total blocks
  mov eax, [es:0x4]
  mov [EXT2.TotalBlocks], eax

  ; Block per group
  mov eax, [es:0x0020]
  mov [EXT2.BlocksInGroup], eax

  ; Inodes per group
  mov eax, [es:0x0028]
  mov [EXT2.InodesInGroup], eax

  ; Calc group count
  mov eax, [EXT2.TotalInodes]
  xor edx, edx
  div dword [EXT2.InodesInGroup]

  or edx, edx
  jz .nincI
  inc eax
  .nincI:

  mov [EXT2.GroupCount], eax

  ; By default block index 1
  mov eax, 1

  ; If block size > 1024 block index 2
  mov  cl, [EXT2.SectorShift]
  dec cl

  or cl, cl
  jnz .cnt
  inc eax
  .cnt:

  ; Right after the superblock (offset 1024b)
  mov bx, [EXT2.OffsetGroupDescTable]
  call EX2ReadBlock
  jc ErrReadSuperblock

  ; Get The Inode Table First Block ID
  mov bx, [EXT2.OffsetGroupDescTable]
  mov eax, [es:bx + 8]

  ; Next read Inode Table 
  mov bx, [EXT2.OffsetInodeTable]
  call EX2ReadBlock
  jc ErrReadSuperblock

  mov bx, [EXT2.OffsetInodeTable]
  add bx, [EXT2.InodeStructSize]

  mov eax, [es:bx + 40]
  mov bx, [EXT2.OffsetCurrentBlock]

  call EX2ReadBlock
  call EX2ListDirectory
  
  jmp $

  ret

EXT2:
  .MajorVersion         dd 0
  .ReadedDataSegment    dw 0x2000

  .OffsetSuperblock     dw 0x0000
  .OffsetGroupDescTable dw 0x0400
  .OffsetInodeTable     dw 0x0800
  .OffsetCurrentBlock   dw 0x0A00

  .TotalBlocks          dd 0
  .BlocksInGroup        dd 0

  .TotalInodes          dd 0
  .InodesInGroup        dd 0
  .InodeStructSize      dw 0x80

  .GroupCount           dd 0

  .SectorShift          db 0
  .BlockSize            dd 0x0400
  .SectorsPerBlock      dw 0x0

AddrPack        : times 0x10 db 0 