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
answer	DB	100h DUP (0)
errmsg	DB	'Error, total value may not exceed 3999$'
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
;	mov		counter, 0
remSpace:
	mov		al, es:[si]
	cmp		al, 20h				; CHECK FOR SPACES
	je		isSpace
	mov		[di], al
	inc		di					; INCREMENT MEMORY INDEXES AND DECREMENT INPUT NUMBER
	dec		si
;	inc		counter
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
	mov		bx, 1
	inc		di
	jmp		convert
second:
	mov		cx, 5
	mov		bx, 5
	inc		di
	jmp		convert
third:
	mov		cx, 10
	mov		bx, 10
	inc		di
	jmp		convert
fourth:
	mov		cx, 50
	mov		bx, 50
	inc		di
	jmp		convert
fifth:
	mov		cx, 100
	mov		bx, 100
	inc		di
	jmp		convert
sixth:
	mov		cx, 500
	mov		bx, 500
	inc		di
	jmp		convert
seventh:
	mov		cx, 1000
	mov		bx, 1000
	inc		di
	jmp		convert

convert:
	cmp 	di, dx				; CMP TO SEE IF AT END
	je 		sum
	mov		al, ds:[di]			; LOADS 1st GOOD CHARACTER
	cmp		al, 2bh
	jz		plus
	call	rom2dec
	inc 	di					; INCREMENT
	jmp 	convert

plus:
	mov		var1, bx	
	mov		bx,	0
	mov		cx, 0
	inc		di
	jmp		firstChar
; -------------------- END CONVERT CODE -------------------- ;

rom2dec:
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

romI:
	mov		ax, 1
	cmp		ax, cx
	jl		subI
	mov		cx, 1
	add		bx, 1
	ret
romV:
	mov		ax, 5
	cmp		ax, cx
	jl		subV
	mov		cx, 5
	add		bx, 5
	ret
romX:
	mov		ax, 10
	cmp		ax, cx
	jl		subX
	mov		cx, 10
	add		bx, 10
	ret
romL:
	mov		ax, 50
	cmp		ax, cx
	jl		subL
	mov		cx, 50
	add		bx, 50
	ret
romC:
	mov		ax, 100
	cmp		ax, cx
	jl		subC
	mov		cx, 100
	add		bx, 100
	ret
romD:
	mov		ax, 500
	cmp		ax, cx
	jl		subD
	mov		cx, 500
	add		bx, 500
	ret
romM:
	mov		cx, 1000
	add		bx, 1000
	ret
subI:
	;sub		cx, 1
	sub		bx, 1
	mov		cx, 1
	ret
subV:
	;sub		cx, 5
	sub		bx, 5
	mov		cx, 5
	ret
subX:
	;sub		cx, 10
	sub		bx, 10
	mov		cx, 10
	ret
subL:
	;sub		cx, 50
	sub		bx, 50
	mov		cx, 50
	ret
subC:
	;sub		cx, 100
	sub		bx, 100
	mov		cx, 100
	ret
subD:
	;sub		cx, 500
	sub		bx, 500
	mov		cx, 500
	ret
; -------------------- END CONVERT DEC CODE -------------------- ;

sum:
	mov		var2, bx
	mov		ax, var1
	add		ax, bx
	cmp		ax, 3999
	jg		err
	mov		var3, ax
	nop

; -------------------- END MATHS CODE -------------------- ;

dec2rom:
	jmp 	next

err:
	mov		dx, OFFSET errmsg
	mov		ah, 9
	int 	21h
	;mov		dl, 10
	;int 	21h
	jmp 	done
; -------------------- END CONVERT ROM CODE -------------------- ;

; -------------------- START END/OUT CODE -------------------- ;

next:
	mov		di, OFFSET answer
	mov		ax, var3
	mov 	[di], ax
	inc		di
	mov		al, 10
	mov		[di], al
	inc		di
	mov		al, '$'
	mov		[di], al
	inc		di
	mov		ah, 9h
	mov		dx, OFFSET answer
	int		21h
done:
	mov		ax, 4C00h
	int		21h
_TEXT	ENDS
	END	start
