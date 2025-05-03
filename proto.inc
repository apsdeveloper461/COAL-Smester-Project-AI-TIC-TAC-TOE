.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc
INCLUDE data.inc


InitBoard PROTO,boardPtr:ptr BYTE
PrintBoard PROTO,boardPtr:ptr BYTE
CheckDraw PROTO, boardPtr:ptr BYTE
CheckWinner PROTO, boardPtr:ptr BYTE
Minimax PROTO, boardPtr:ptr BYTE
MakeMove_Human PROTO, boardPtr:ptr BYTE
HardAI PROTO, boardPtr:ptr BYTE
MakeMove PROTO,boardPtr:ptr BYTE,playerSymbol:BYTE