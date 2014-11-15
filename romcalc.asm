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
start:						; THIS CODE CHECKS LENGTH OF ARGUMENTS AND EXITS IF 0
	mov	ax, DGROUP
	mov	ds, ax
	mov	di, OFFSET buffer
	mov	si, 82h
	mov	al, es:[80h]		; GET NUMBER OF ARGUMENT CHARACTERS
	cmp	al, 0
	je	done
	mov	cl, al
	;mov	dl, al
loop1:
	mov	al, es:[si]
	cmp	al, 20h				; CHECK FOR SPACES
	je	isSpace
	mov	[di], al
	inc	di					; INCREMENT MEMORY INDEXES AND DECREMENT INPUT NUMBER
	inc	si
	dec	cl
	jnz	loop1
	dec di
	mov dx, di
	mov di, OFFSET buffer
	jmp	findPlus			; IF CL = 0, NO MORE INPUT CHARACTERS
isSpace:
	inc	si
	dec	cl
	jmp	loop1
findPlus:	
	mov al, ds:[di]
	cmp al, 2bh
	je isPlus
	;mov [ds], al
	;inc ds
	;dec dl
	inc di
	cmp di, dx
	je rom2dec
	jmp findPlus
isPlus:
	mov cx, di
	inc di
	jmp findPlus
rom2dec:
	jmp next
next:
	mov	al, 10
	mov	[di], al
	inc	di
	mov	al, '$'
	mov	[di], al
	mov	ah, 9h
	mov	dx, OFFSET buffer
	int	21h
done:
	mov	ax, 4C00h
	int	21h
_TEXT	ENDS
	END	start
