	.DOSSEG
DGROUP	GROUP	_DATA, STACK
STACK	SEGMENT PARA STACK 'STACK'
	DB	100h DUP (?)
STACK	ENDS
_DATA	SEGMENT WORD PUBLIC 'DATA'
buffer	DB	100h DUP (0)
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
	jmp		convert			; IF CL = 0, NO MORE INPUT CHARACTERS
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
	
	ret
romI:
	mov		ax, 1
	ret
romV:
	mov		ax, 5
	ret
romX:
	mov		ax, 10
	ret
romL:
	mov		ax, 50
	ret
romC:
	mov		ax, 100
	ret
romD:
	mov		ax, 500
	ret
romM:
	mov		ax, 1000
	ret
; -------------------- END CONVERT DEC CODE -------------------- ;

sum:
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
