INCLUDE proto.inc

.code

; -------------------------------------
; CheckWinner - Checks if a player has won
; In eax return winning status "1"
; and in ebx the winning symbol "X" or "O"
; -------------------------------------
CheckWinner PROC, boardPtr:ptr BYTE
    ; Check rows
    mov ecx, 0
    mov edi,boardPtr
check_rows:
    cmp ecx, 3
    jge check_columns
    mov esi, ecx            ; Store row index in esi
    imul esi, 3             ; Calculate starting index of the row (row * 3)
    
    movzx eax, BYTE PTR [edi + esi]   ; Load the first cell of the row
    cmp eax, EMPTY
    je next_row
    movzx ebx, BYTE PTR [edi + esi + 1] ; Load the second cell of the row
    cmp eax, ebx
    jne next_row
    movzx ebx, BYTE PTR [edi + esi + 2] ; Load the third cell of the row
    cmp eax, ebx
    jne next_row
    mov ebx,eax
    mov eax,1
    ret                     ; Winner found, return the winning status in eax
next_row:
    inc ecx
    jmp check_rows

check_columns:
    mov ecx, 0
check_cols_loop:
    cmp ecx, 3
    jge check_diagonals
    movzx eax, BYTE PTR [edi + ecx]   ; Load the first cell of the column
    cmp eax, EMPTY
    je next_col
    movzx ebx, BYTE PTR [edi + ecx + 3] ; Load the second cell of the column
    cmp eax, ebx
    jne next_col
    movzx ebx, BYTE PTR [edi + ecx + 6] ; Load the third cell of the column
    cmp eax, ebx
    jne next_col
    mov ebx,eax
    mov eax,1
    ret                     ; Winner found, return the winning status in eax
next_col:
    inc ecx
    jmp check_cols_loop

check_diagonals:
    ; Main diagonal
    movzx eax, BYTE PTR [edi + 0]
    cmp eax, EMPTY
    je check_other_diag
    movzx ebx, BYTE PTR [edi + 4]
    cmp eax, ebx
    jne check_other_diag
    movzx ebx, BYTE PTR [edi + 8]

    cmp eax, ebx
    jne check_other_diag
    mov ebx,eax
    mov eax,1
    ret                     ; Winner found, return the winning status in eax

check_other_diag:
    movzx eax, BYTE PTR [edi + 2]
    cmp eax, EMPTY
    je no_winner
    movzx ebx, BYTE PTR [edi + 4]
    cmp eax, ebx
    jne no_winner
    movzx ebx, BYTE PTR [edi + 6]
    cmp eax, ebx
    jne no_winner
    mov ebx,eax
    mov eax,1
    ret                     ; Winner found, return the winning status in eax

no_winner:
    xor eax, eax            ; No winner
    ret
CheckWinner ENDP

; -------------------------------------
; CheckDraw - Checks if the board is full and there's no winner
; -------------------------------------
CheckDraw PROC, boardPtr:ptr BYTE
    ; Check if there's a winner
    push boardPtr
    call CheckWinner
    cmp eax, 0              ; If there's a winner, it's not a draw
    jne not_full

    ; Check if the board is full
    mov ecx, 9
    mov esi, boardPtr
check_full:
    mov al, BYTE PTR [esi]
    cmp al, EMPTY
    je not_full
    inc esi
    loop check_full
    mov eax, 1              ; Board is full and no winner, it's a draw
    ret
not_full:
    xor eax, eax            ; Not a draw
    ret
CheckDraw ENDP
MakeMove PROC, boardPtr:ptr BYTE, playerSymbol:BYTE
    push esi                 ; Preserve esi
    mov esi, boardPtr        ; Load board pointer into esi

askInputMM:
    ; Prompt for move
    call CrLf
    mov edx, OFFSET promptMove
    call WriteString

    call ReadInt             ; Read user input into eax
    cmp eax, 0
    jl invalidMM             ; If input < 0, go to invalidMM
    cmp eax, 8
    jg invalidMM             ; If input > 8, go to invalidMM

    movzx ecx, Byte PTR [esi + eax] ; Access board cell at index eax
    cmp ecx, EMPTY           ; Check if the cell is empty
    jne occupiedMM           ; If not empty, go to occupiedMM
    mov edx,esi
    add edx,eax
    mov al,playerSymbol
    mov  Byte PTR [edx],al  ; Update the board with the player's symbol
    pop esi                  ; Restore esi
    ret

invalidMM:
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp askInputMM           ; Retry input

occupiedMM:
    mov edx, OFFSET msgOccupied
    call WriteString
    jmp askInputMM           ; Retry input

MakeMove ENDP




END