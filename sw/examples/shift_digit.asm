	.proc	P1
	
porta	=	0xff00
	
	ldl0	r0,porta
	ldl0	r3,0xa
	ldl0	r2,1
digcikl:	
	mov	r1,r2

shcikl:
	st	r1,r0
	shl	r1
	shl	r1
	shl	r1
	shl	r1
	jnz	shcikl

	inc	r2
	cmp	r3,r2,r3
	z ldl0	r2,1
	jmp	digcikl
	
