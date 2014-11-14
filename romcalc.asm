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
start:										; THIS CODE CHECKS LENGTH OF ARGUMENTS AND EXITS IF 0
	mov	ax, DGROUP
	mov	ds, ax
	mov	di, OFFSET buffer
	mov	si, 82h
	mov	al, es:[80h]
	cmp	al, 0
	je	done								; END ARGUMENT CHECK
	mov	cl, al
loop1:
	mov	al, es:[si]
	cmp	al, 20h
	je	space
	cmp al, 2bh
	je	addNum
	mov	[di], al
	inc	di
	inc	si
	dec	cl
	jnz	loop1
	jmp	separate
space:
	inc	si
	dec	cl
	jmp	loop1
separate:
	jmp addNum
addNum:
	jmp convert
convert:
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
