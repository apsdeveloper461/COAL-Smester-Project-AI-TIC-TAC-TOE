
; Constants
; -------------------------------------
.const
HUMAN   EQU 'X'
AI      EQU 'O'
EMPTY   EQU ' '

; -------------------------------------
; Data Segment
; -------------------------------------
.data
msgTitle     BYTE "Tic-Tac-Toe (Assembly Version)", 0
msgInit      BYTE "Board initialized with EMPTY cells.", 0
msgDone      BYTE "Exiting program...", 0
promptMove   BYTE "Enter your move (0-8): ", 0
msgInvalid   BYTE "Invalid move! Try again.", 0
msgOccupied  BYTE "Cell already occupied! Try again.", 0
msgPlayer1   BYTE "Player 1 (X) turn.", 0
msgPlayer2   BYTE "Player 2 (O) turn.", 0
msgPlayerHuman BYTE "Your Turn (O): ", 0
msgPlayerAIHard BYTE "AI (Hard) Turn (X):", 0
msgEnterMove BYTE "Enter move (0-8): ", 0
msgHumanWin BYTE "You win!", 0
msgAIWin BYTE "AI wins!", 0
msgDraw BYTE "It's a draw!", 0

msgWinner    BYTE "Player ", 0
msgGameOver  BYTE "Game Over!", 0
msgGoodbye   BYTE 0Dh, 0Ah, "Thanks for playing!", 0Dh, 0Ah, 0

sep          BYTE " | ", 0
rowSep       BYTE " +---+---+---+ ", 0

msgMenu      BYTE "Choose Game Mode:", 0Dh, 0Ah
             BYTE "1. Player vs Player (P2P)", 0Dh, 0Ah
             BYTE "2. Player vs AI (PVE)", 0Dh, 0Ah
             BYTE "3. Exit", 0Dh, 0Ah
             BYTE "Enter your choice: ", 0

msgAIMenu    BYTE "Select AI Difficulty:", 0Dh, 0Ah
             BYTE "1. Easy", 0Dh, 0Ah
             BYTE "2. Hard", 0Dh, 0Ah
             BYTE "Enter choice (1 or 2): ", 0

gameMode     DWORD ?
aiDifficulty BYTE 0
minimaxBestMove DWORD 0
minimaxBestScore DWORD -1000
bestMoveIndex DWORD ?
; Temporary variables for Minimax
tempBestScore DWORD ?
tempMoveIndex DWORD ?
tempScore DWORD ?

MAX_SCORE      =  1000
MIN_SCORE      = -1000
