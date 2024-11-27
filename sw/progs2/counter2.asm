	.proc	P2
	
out	equ	0xff00

	org	0

	mvzl	r13,eof_stack
	mvzl	r0,out
	mvzl	r1,0

cyc:
	;call	0xf001		; enter monitor by uart
	st	r1,r0
	add	r1,1
	jmp	cyc

	ds	100
eof_stack:	
	db	0
	
