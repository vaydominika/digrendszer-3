	.cpu	p2
	
	org	0
	.req	RA,r1
	ld	r0,RA+,r2
	
	mvzl	sp,stack
	mvzl	r1,217
	st	r1,UART.CPB
	mvzl	r1,3		; turn on rx and tx
	st	r1,UART.CTRL

	.include	a.asm
	
	mvzl	r0,'A'
	call	putchar
	mvzl	r0,'0'
	call	putchar

	rds	r1,Sver
	st	r1,GPIOA.ODR
	getb	r0,r1,2
	add	r0,'0'
	call	putchar
	mvzl	r0,'.'
	call	putchar
	getb	r0,r1,1
	add	r0,'0'
	call	putchar
	mvzl	r0,'.'
	call	putchar
	getb	r0,r1,0
	add	r0,'0'
	call	putchar

	mov	r0,r1
	getbz	r1,r0,2
	getbz	r2,r0,1
	getbz	r3,r0,0
	ces	eprintf
	db	"\nVer %d.%d.%d\n"
	
end:	jmp	end
	
s1:	db	"Hello %d %x\n"
null_str:	db	"(null)"

	ds	100
stack:
	db	0
	
