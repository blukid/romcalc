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
counter DB	?
_DATA	ENDS
_TEXT	SEGMENT WORD PUBLIC 'CODE'
	ASSUME	cs:_TEXT, ds:DGROUP, ss:DGROUP
start:							; THIS CODE CHECKS LENGTH OF ARGUMENTS AND EXITS IF 0
	mov		ax, DGROUP
	mov		ds, ax
	mov		di, OFFSET buffer
	mov		si, 82h
	mov		al, es:[80h]		; GET NUMBER OF ARGUMENT CHARACTERS
	dec		al
	cmp		al, 0
	jle		done
	mov		cl, al
siloop:
	inc		si
	dec		cl
	jnz		siloop
	mov		cl,	al
	dec		si
	mov		counter, 0
remSpace:
	mov		al, es:[si]
	cmp		al, 20h				; CHECK FOR SPACES
	je		isSpace
	mov		[di], al
	inc		di					; INCREMENT MEMORY INDEXES AND DECREMENT INPUT NUMBER
	dec		si
	inc		counter
	dec		cl
	jnz		remSpace
	;dec 	di
	mov		dx, di				; STORE DI VALUE FOR LATER COMPARISON, AND MOVE ORIGINAL VALUE BACK IN
	mov		di, OFFSET buffer
	mov		bx, 0				; INITIALIZES BX REG FOR ADDITION
	mov		cx, 0				; INITIALIZES CX REG FOR CMP
	jmp		firstChar			; IF CL = 0, NO MORE INPUT CHARACTERS
isSpace:
	dec		si
	dec		cl
	jmp		remSpace

; -------------------- END SPACE CODE -------------------- ;
firstChar:
	mov		al, ds:[di]
	cmp		al, 49h
	jz		first
	cmp		al, 56h
	jz		second
	cmp		al, 58h
	jz		third
	cmp		al, 4ch
	jz		fourth
	cmp		al, 43h
	jz		fifth
	cmp		al, 44h
	jz		sixth
	cmp		al, 4dh
	jz		seventh

first:
	mov		cx, 1
	inc		di
	jmp		convert
second:
	mov		cx, 5
	inc		di
	jmp		convert
third:
	mov		cx, 10
	inc		di
	jmp		convert
fourth:
	mov		cx, 50
	inc		di
	jmp		convert
fifth:
	mov		cx, 100
	inc		di
	jmp		convert
sixth:
	mov		cx, 500
	inc		di
	jmp		convert
seventh:
	mov		cx, 1000
	inc		di
	jmp		convert

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
	ret

plus:
	mov		var1, bx	
	mov		bx,	0
	mov		cx, 0
	ret
romI:
	cmp		cx, 1
	jl		subI
	mov		cx, 1
	add		bx, 1
	ret
romV:
	cmp		cx, 5
	jl		subV
	mov		cx, 5
	add		bx, 5
	ret
romX:
	cmp		cx, 10
	jl		subX
	mov		cx, 10
	add		bx, 10
	ret
romL:
	cmp		cx, 50
	jl		subL
	mov		cx, 50
	add		bx, 50
	ret
romC:
	cmp		cx, 100
	jl		subC
	mov		cx, 100
	add		bx, 100
	ret
romD:
	cmp		cx, 500
	jl		subD
	mov		cx, 500
	add		bx, 500
	ret
romM:
	mov		cx, 1000
	add		bx, 1000
	ret
subI:
	sub		cx, 1
	add		bx, cx
	mov		cx, 1
	ret
subV:
	sub		cx, 5
	add		bx, cx
	mov		cx, 5
	ret
subX:
	sub		cx, 10
	add		bx, cx
	mov		cx, 10
	ret
subL:
	sub		cx, 50
	add		bx, cx
	mov		cx, 50
	ret
subC:
	sub		cx, 100
	add		bx, cx
	mov		cx, 100
	ret
subD:
	sub		cx, 500
	add		bx, cx
	mov		cx, 500
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
