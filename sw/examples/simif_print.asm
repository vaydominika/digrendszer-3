	.proc	P1
	
simif	equ	0xffff
	ldl0	sp,stack

	ldl0	r1,Hello
	call	print
vege:	jmp	vege
	
start:	
	ldl0	r0,'A' ;65		; 'A'
cikl:	
	call	local_putchar
	inc	r0
	ldl0	r10,'Z' ;91		; 'Z'
	inc	r10
	cmp	r10,r0,r10
	jnz	cikl
	jmp	start
	
	;; print char in R0
local_putchar:
	push	r14
	inc	sp
	ldl0	r12,'p' ;112		; 'p'
	ldl0	r10,simif
	st	r12,r10
	st	r0,r10
	dec	sp
	pop	r14
	ret

	;; print 0 terminated string at R1
print:
	push	r14
	inc	sp
print_cikl:	
	ld	r0,r1
	or	r0,r0,r0
	jz	print_exit
	call	local_putchar
	inc	r1
	jmp	print_cikl
print_exit:
	dec	sp
	pop	r14
	ret

Hello:
	db	'H'	;72
	db	'e'
	db	'l'
	db	'l'
	db	'o'
	db	32
	db	'W'
	db	'o'
	db	'r'
	db	'l'
	db	'd'
	db	'!'
	db	10
	db	0
	
stack:
	
