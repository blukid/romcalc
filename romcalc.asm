	.DOSSEG
DGROUP	GROUP	_DATA, STACK
STACK	SEGMENT PARA STACK 'STACK'
	DB	100h DUP (?)
STACK	ENDS
_DATA	SEGMENT WORD PUBLIC 'DATA'
buffer	DB	100h DUP (0)
var1	DW	?
var2	DW	?
var3	DW	?
_DATA	ENDS
_TEXT	SEGMENT WORD PUBLIC 'CODE'
	ASSUME	cs:_TEXT, ds:DGROUP, ss:DGROUP
start:							; THIS CODE CHECKS LENGTH OF ARGUMENTS AND EXITS IF 0
	mov		ax, DGROUP
	mov		ds, ax
	mov		di, OFFSET buffer
	mov		si, 82h
	mov		al, es:[80h]		; GET NUMBER OF ARGUMENT CHARACTERS
	cmp		al, 0
	je		done
	mov		cl, al
remSpace:
	mov		al, es:[si]
	cmp		al, 20h				; CHECK FOR SPACES
	je		isSpace
	mov		[di], al
	inc		di					; INCREMENT MEMORY INDEXES AND DECREMENT INPUT NUMBER
	inc		si
	dec		cl
	jnz		remSpace
	dec 	di
	mov		dx, di				; STORE DI VALUE FOR LATER COMPARISON, AND MOVE ORIGINAL VALUE BACK IN
	mov		di, OFFSET buffer
	jmp		convert				; IF CL = 0, NO MORE INPUT CHARACTERS
isSpace:
	inc		si
	dec		cl
	jmp		remSpace

; -------------------- END SPACE CODE -------------------- ;

convert:
	mov		al, ds:[di]			; LOADS 1st GOOD CHARACTER
	call	rom2dec
	inc 	di					; INCREMENT
	cmp 	di, dx				; CMP TO SEE IF AT END
	je 		sum
	jmp 	convert

; -------------------- END CONVERT CODE -------------------- ;

rom2dec:
	cmp		al, 2bh
	jz		plus
	cmp		al, 49h
	jz		romI
	cmp		al, 56h
	jz		romV
	cmp		al, 58h
	jz		romX
	cmp		al, 4ch
	jz		romL
	cmp		al, 43h
	jz		romC
	cmp		al, 44h
	jz		romD
	cmp		al, 4dh
	jz		romM
;	jmp		??????????

plus:
	mov		var1, bx		;why is bx moving into var1? and then why is 0 moving into bx?
	mov		bx,	0
	ret
romI:
	add		bx, 1
	ret
romV:
	add		bx, 5
	ret
romX:
	add		bx, 10
	ret
romL:
	add		bx, 50
	ret
romC:
	add		bx, 100
	ret
romD:
	add		bx, 500
	ret
romM:
	add		bx, 1000
	ret
; -------------------- END CONVERT DEC CODE -------------------- ;

sum:
	mov		var2, bx
	mov		ax, var1
	add		ax, bx
	mov		var3, ax
	nop

; -------------------- END MATHS CODE -------------------- ;

dec2rom:
	nop

; -------------------- END CONVERT ROM CODE -------------------- ;

; -------------------- START END/OUT CODE -------------------- ;

next:
	mov		al, 10
	mov		[di], al
	inc		di
	mov		al, '$'
	mov		[di], al
	mov		ah, 9h
	mov		dx, OFFSET buffer
	int		21h
done:
	mov		ax, 4C00h
	int		21h
_TEXT	ENDS
	END	start
