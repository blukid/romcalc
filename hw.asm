	.DOSSEG
DGROUP	GROUP	_DATA, STACK
STACK	SEGMENT	PARA STACK 'STACK'
	DB	100 DUP (?)
STACK	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
msg	DB	"Hello World!", 13, 10, "$"
_DATA	ENDS
_TEXT	SEGMENT	WORD PUBLIC 'CODE'
	ASSUME	cs:_TEXT, ds:DGROUP, ss:DGROUP
start:
	mov	ax, DGROUP
	mov	ds, ax
	mov	ah, 9h
	mov	dx, OFFSET msg
	int	21h
	mov	ax, 4C00h
	int	21h
_TEXT	ENDS
	END	start
;ahhhhh i'm a code person i feel like I should be in the matrix and look at code or shit this is so exciting but not professional so I will erase this shorlty and this is a run on sentence.
