.386
.model flat, stdcall
.stack 4096

INCLUDE proto.inc


.data

board        BYTE 9 DUP(EMPTY)      ; 3x3 board initialized with EMPTY

; -------------------------------------
; Code Segment
; -------------------------------------
.code

; ------------------------------------
; MACROS
; ------------------------------------

ClearScreen MACRO delayTime
    local cs_loop
    ; Clear 25 lines
    mov eax, delayTime
    call Delay
    mov ecx,50
cs_loop:
    call CrLf
    loop cs_loop
ENDM

; -------------------------------------
; Main procedure
; -------------------------------------
main PROC
    mov edx, OFFSET msgTitle
    call WriteString
    call CrLf

    INVOKE InitBoard, OFFSET board

    mov edx, OFFSET msgInit
    call WriteString
    call CrLf

    call ShowMenu

    cmp gameMode, 1
    je GameLoop

    cmp gameMode, 2
    je select_ai_difficulty

    jmp exit_game

select_ai_difficulty:
    call ShowAIMenu

    cmp aiDifficulty, 1
    je GameLoopAI_Easy

    cmp aiDifficulty, 2
    je GameLoopAI_Hard

    jmp exit_game

exit_game:
    mov edx, OFFSET msgDone
    call WriteString
    call CrLf

    call ExitProcess
main ENDP



; -------------------------------------
; GameLoop - Main game loop for alternating turns
; -------------------------------------
GameLoop PROC
    mov bl, AI                ; Player 1 (X)
    mov al, AI

game_start:
    cmp al, AI
    je player1_turn
    cmp al, HUMAN
    je player2_turn

player1_turn:
    mov edx, OFFSET msgPlayer1
    call WriteString
    mov bl, AI
    call crlf
    call crlf
    INVOKE PrintBoard,OFFSET board
    INVOKE MakeMove,OFFSET board,'X'            ; bl = 'X'
    INVOKE CheckWinner,OFFSET board
    cmp eax, 1               ; Check if there's a winner
    je end_game
    INVOKE CheckDraw,OFFSET board          ; Check if it's a draw
    cmp eax, 1
    je draw
    mov al, HUMAN  
    mov bl, HUMAN; Switch to Player 2
    jmp game_start

player2_turn:
    mov edx, OFFSET msgPlayer2
    call WriteString
    mov bl, HUMAN
    call crlf
    call crlf
    INVOKE PrintBoard,OFFSET board
    INVOKE MakeMove,OFFSET board,'O'           ; bl = 'O'
    INVOKE CheckWinner,OFFSET board
    cmp eax, 1               ; Check if there's a winner
    je end_game
    INVOKE CheckDraw,OFFSET board           ; Check if it's a draw
    cmp eax, 1
    je draw
    mov al, AI     
    mov bl, AI; Switch to Player 1
    jmp game_start

draw:
    mov edx, OFFSET msgDraw
    call WriteString
    call CrLf
    ret

end_game:
    mov edx, OFFSET msgWinner
    call WriteString
    mov al, bl               ; Display the winner's symbol
    call WriteChar
    call CrLf
    ret

GameLoop ENDP

ShowMenu PROC
menu_prompt:
    call CrLf
    mov edx, OFFSET msgMenu
    call WriteString
    call ReadInt
    cmp eax, 1
    je start_p2p
    cmp eax, 2
    je start_pve
    cmp eax, 3
    je exit_game
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp menu_prompt

start_p2p:
    mov gameMode, 1
    ret

start_pve:
    mov gameMode, 2
    ret

exit_game:
    mov edx, OFFSET msgGoodbye
    call WriteString
    call ExitProcess
    ret
ShowMenu ENDP

ShowAIMenu PROC
    call CrLf
    mov edx, OFFSET msgAIMenu
    call WriteString

read_choice:
    call ReadInt
    cmp eax, 1
    je set_easy
    cmp eax, 2
    je set_hard

    ; Invalid choice
    mov edx, OFFSET msgInvalid
    call WriteString
    jmp read_choice

set_easy:
    mov aiDifficulty, 1
    ret

set_hard:
    mov aiDifficulty, 2
    ret
ShowAIMenu ENDP

AILogic PROC
    ; Simple AI: place move in the first empty cell (0 to 8)
    mov ecx, 0              ; Start index
find_empty_cell:
    cmp ecx, 9
    jge no_move_found       ; Fail-safe: no empty cell

    movzx eax, board[ecx]
    cmp eax, EMPTY
    je place_ai_move

    inc ecx
    jmp find_empty_cell

place_ai_move:
    mov board[ecx], AI      ; Place AI’s mark (e.g., 'O')
    ret

no_move_found:
    ; Should never reach here if CheckDraw works properly
    ret
AILogic ENDP

GameLoopAI_Easy PROC
    mov al, HUMAN             ; Player goes first
    mov bl, HUMAN
ai_game_start:
    cmp al, HUMAN
    je player_turn
    cmp al, AI
    je ai_turn

player_turn:
    mov edx, OFFSET msgPlayer1
    call WriteString
    INVOKE MakeMove,OFFSET board,'X' ; Player 1 (X)
    call crlf
    call crlf
    INVOKE PrintBoard,OFFSET board
    call crlf
    INVOKE CheckWinner,OFFSET board
    cmp eax, 1
    je ai_game_end
    INVOKE CheckDraw,OFFSET board
    cmp eax, 1
    je ai_game_draw
    mov al, AI
    mov bl, AI
    jmp ai_game_start

ai_turn:
    mov edx, OFFSET msgPlayer2
    call WriteString
    call AILogic      
    call crlf
    call crlf
    INVOKE PrintBoard,OFFSET board
    call crlf
    INVOKE CheckWinner,OFFSET board    
    cmp eax, 1
    je ai_game_end
    INVOKE CheckDraw,OFFSET board
    cmp eax, 1
    je ai_game_draw
    mov al, HUMAN
    mov bl, HUMAN
    jmp ai_game_start

ai_game_end:
    call CrLf
    mov edx, OFFSET msgGameOver
    call WriteString
    call CrLf
    ret

ai_game_draw:
    call CrLf
    mov edx, OFFSET msgDraw
    call WriteString
    call CrLf
    ret

GameLoopAI_Easy ENDP

GameLoopAI_Hard PROC
    mov al, HUMAN      ; Human starts first
    ClearScreen 0

ai_game_start:
    cmp al, HUMAN
    je human_turn
    cmp al, AI
    je ai_turn

human_turn:
    call PrintBoard
    mov edx, OFFSET msgPlayerHuman
    call WriteString
    INVOKE MakeMove_Human,OFFSET board
    INVOKE PrintBoard,OFFSET board

    INVOKE CheckWinner,OFFSET board
    cmp eax, 1            ; Check if HUMAN (X) won
    je ai_human_win

    INVOKE CheckDraw,OFFSET board
    cmp eax, 1
    je ai_draw

    mov al, AI            ; Switch to AI turn (REMOVE REDUNDANT 'mov bl')
    jmp ai_game_start

ai_turn:
    INVOKE PrintBoard,OFFSET board
    mov edx, OFFSET msgPlayerAIHard
    call WriteString
    call CrLf
    push eax
    mov eax, 500
    call Delay
    pop eax

    INVOKE HardAI,OFFSET board
    INVOKE  PrintBoard,OFFSET board

    INVOKE CheckWinner,OFFSET board
    cmp eax, 2            ; FIX: Check if AI (O) won (was cmp eax,1)
    je ai_ai_win

    INVOKE CheckDraw,OFFSET board
    cmp eax, 1
    je ai_draw

    mov al, HUMAN         ; Switch back to HUMAN (REMOVE REDUNDANT 'mov bl')
    jmp ai_game_start

ai_human_win:
    mov edx, OFFSET msgHumanWin
    call WriteString
    call CrLf
    ret

ai_ai_win:
    mov edx, OFFSET msgAIWin
    call WriteString
    call CrLf
    ret

ai_draw:
    mov edx, OFFSET msgDraw
    call WriteString
    call CrLf
    ret
GameLoopAI_Hard ENDP



END main
