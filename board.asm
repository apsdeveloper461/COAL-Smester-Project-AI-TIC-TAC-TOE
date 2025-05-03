INCLUDE proto.inc

.code
; -------------------------------------
; InitBoard - Fills board with EMPTY
; -------------------------------------
InitBoard PROC,boardPtr:ptr BYTE
    mov ecx, 9          ; number of cells
    mov edi, boardPtr

fill_loop:
    mov BYTE PTR [edi], EMPTY
    inc edi
    loop fill_loop
    ret
InitBoard ENDP

; -------------------------------------
; PrintBoard - Displays the 3x3 board
; -------------------------------------
PrintBoard PROC,boardPtr:ptr BYTE
push eax
    ; Ensure the board is displayed correctly
    mov esi,boardPtr
    mov ecx, 3          ; 3 rows

    ; Print row separator
    mov edx, OFFSET rowSep
    call WriteString
    call CrLf

row_loop:
    mov edx, OFFSET sep
    call WriteString

    ; Print 3 columns
    movzx eax, BYTE PTR [esi]
    call WriteChar       ; Display the correct symbol
    mov edx, OFFSET sep
    call WriteString

    movzx eax, BYTE PTR [esi+1]
    call WriteChar       ; Display the correct symbol
    mov edx, OFFSET sep
    call WriteString

    movzx eax, BYTE PTR [esi+2]
    call WriteChar       ; Display the correct symbol
    mov edx, OFFSET sep
    call WriteString
    call CrLf

    ; Print row separator
    mov edx, OFFSET rowSep
    call WriteString
    call CrLf

    add esi, 3
    loop row_loop
    pop eax
    ret
PrintBoard ENDP
END