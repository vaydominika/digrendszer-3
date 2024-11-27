	.proc	p2

	.org	1

	mvzl	sp,stack
	mvzl	r2,10
cyc:
	call	rand
	mov	r1,r4
	ces	eprintf
	.db	"%u\n"
	mvzl	r0,100
	call	rand_max
	mov	r1,r4
	ces	eprintf
	.db	"%u\n"
	dec	r2
	jnz	cyc

the_end:
	jmp	the_end
	
	ds	100
stack:
	db	0
	
