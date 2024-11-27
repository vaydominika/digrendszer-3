	cpu	p2

	N	=	84273568
	D	=	1000
	org	1

div_begin:	mvzl	sp,div_stack
	mvl	r0,N
	mvh	r0,N
	mvzl	r1,D
	call	div
div_end:
	jmp	div_end

	ds	256
div_stack:
	db	0
	
