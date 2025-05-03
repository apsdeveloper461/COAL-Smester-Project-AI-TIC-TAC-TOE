INCLUDE proto.inc
.data

.code

Minimax PROC, boardPtr:ptr BYTE
    push ebp
    mov ebp, esp
    sub esp, 12           ; Allocate space for 3 local variables: tempBestScore (4), tempScore (4), returnValue (4)
    pushad

    ; Check if game is over
    push boardPtr
    call CheckWinner
    add esp, 4            ; Clean up stack (1 argument)
    cmp eax, 1            ; 'X' wins
    jne CheckOWin
    mov eax, 1
    jmp StoreResult

CheckOWin:
    cmp eax, 2            ; 'O' wins
    jne CheckDrawMM
    mov eax, -1
    jmp StoreResult

CheckDrawMM:
    cmp eax, 3            ; Draw
    jne ContinueMinimax
    mov eax, 0
    jmp StoreResult

ContinueMinimax:
    mov ecx, 0
    mov esi, [ebp+8]      ; isMaximizing

    cmp esi, 1
    jne MinimizeBranch

    ; Maximizing for 'X'
    mov dword ptr [ebp - 4], -2  ; tempBestScore = -2
    jmp MinimaxLoop

MinimizeBranch:
    ; Minimizing for 'O'
    mov dword ptr [ebp - 4], 2   ; tempBestScore = 2

MinimaxLoop:
    cmp ecx, 9
    jge EndMinimaxLoop

    ; Check if cell is empty
    mov al, BYTE PTR [boardPtr + ecx]
    cmp al, ' '
    jne SkipMiniCell

    ; Play move
    cmp esi, 1
    jne PlayO
    mov BYTE PTR [boardPtr + ecx], 'X'
    jmp MinimaxCall

PlayO:
    mov BYTE PTR [boardPtr + ecx], 'O'

MinimaxCall:
    ; Toggle isMaximizing and call Minimax
    xor esi, 1
    push esi
    push boardPtr
    call Minimax
    add esp, 8               ; Clean up stack (2 arguments)
    mov [ebp - 8], eax       ; tempScore = result
    xor esi, 1               ; restore esi

    ; Undo move
    mov BYTE PTR [boardPtr + ecx], ' '

    ; Update best score
    cmp esi, 1
    jne MinCheck

    ; Maximizing: if tempScore > tempBestScore
    mov eax, [ebp - 8]
    cmp eax, [ebp - 4]
    jle SkipMiniCell
    mov [ebp - 4], eax
    jmp SkipMiniCell

MinCheck:
    ; Minimizing: if tempScore < tempBestScore
    mov eax, [ebp - 8]
    cmp eax, [ebp - 4]
    jge SkipMiniCell
    mov [ebp - 4], eax

SkipMiniCell:
    inc ecx
    jmp MinimaxLoop

EndMinimaxLoop:
    mov eax, [ebp - 4]       ; eax = tempBestScore

StoreResult:
    mov [ebp - 12], eax      ; Store return value in local variable

MinimaxEnd:
    popad                    ; Restore all registers (including EAX)
    mov eax, [ebp - 12]      ; Retrieve return value
    mov esp, ebp
    pop ebp
    ret 8                    ; Clean up 2 arguments (boardPtr and isMaximizing)
Minimax ENDP


MakeMove_Human PROC, boardPtr:ptr BYTE
@retry:
    mov edx, OFFSET msgEnterMove
    call WriteString
    call ReadInt            ; Read index 0-8
    cmp eax, 0
    jl @retry               ; Retry if input is less than 0
    cmp eax, 8
    jg @retry               ; Retry if input is greater than 8

    mov ecx, eax
    movzx edx, BYTE PTR [boardPtr + ecx] ; Access the board cell at index ecx
    cmp edx, EMPTY
    jne @retry              ; Retry if the cell is not empty

    mov BYTE PTR [boardPtr + ecx], HUMAN ; Place the human's move on the board
    ret
MakeMove_Human ENDP



HardAI PROC, boardPtr:ptr BYTE
    pushad
    mov esi, boardPtr        ; Load board pointer into esi
    mov tempBestScore, 2     ; Initialize to worst case for minimizer
    mov tempMoveIndex, -1    ; Default invalid index
    mov ecx, 0               ; Start with the first cell

FindBestMove:
    cmp ecx, 9               ; Check if all cells have been evaluated
    jge DoneFindingBestMove

    ; Check if cell is empty
    mov al, BYTE PTR [esi + ecx] ; Access board cell at index ecx
    cmp al, ' '              ; Compare with empty cell character
    jne SkipCell

    ; Simulate 'O' move
    mov BYTE PTR [esi + ecx], 'O'

    ; Call Minimax for next player (X is maximizing)
    push 1                   ; Push isMaximizing = 1
    push esi                 ; Push boardPtr
    call Minimax
    add esp, 8               ; Clean up stack (2 arguments)
    mov tempScore, eax       ; Store Minimax result in tempScore

    ; Undo move
    mov BYTE PTR [esi + ecx], ' '

    ; Update best move if score is lower (better for minimizer)
    mov eax, tempScore
    cmp eax, tempBestScore
    jge SkipCell             ; Skip if current score is not better

    ; Update best score and index
    mov tempBestScore, eax
    mov tempMoveIndex, ecx

SkipCell:
    inc ecx                  ; Move to the next cell
    jmp FindBestMove

DoneFindingBestMove:
    ; Place 'O' in the best cell (if valid)
    cmp tempMoveIndex, -1    ; Check if a valid move was found
    je NoMove
    mov eax, tempMoveIndex
    mov BYTE PTR [esi + eax], 'O'

NoMove:
    popad
    ret
HardAI ENDP


END