	.proc	p2

	org	1
	UN mvzl	r1,0xabcd
	mvzl	r13,0xefff
	mvzl	r0,3
	st	r0,0xff41
	
	ces	eprintf
	db	"HelloWorld!\n"

	ces	eprintf
	db	"B"

stop:	jmp	stop
	
	mvzl	r0,1
	st	r0,CLOCK.PRE
	
	mvl	r0,0xffffffff
	mvh	r0,0xffffffff
	call	0xf013
	mvzl	r0,10
	call	0xf00e

	mvzl	r0,s
	mvzl	r1,12345
	mvl	r2,0xdeadbeef
	mvh	r2,0xdeadbeef
	mvzl	r3,s2
	mvzl	r4,'A'
	call	printf

	mvzl	r1,65535
	ces	0xf015
	db	"d=%x\n"
	mvzl	r0,'B'
	call	0xf00e
	
	jmp	0xf000
	
s:	db	"dec=%d\nhex=%x\nstr=%s\nchar=%c\n"
s2:	db	"this is a string"
	
	org	0x1000

	mov	r0,r4
	st	aa,r14
aa:
	jmp	aa
	
	db	"ABCDEFGH"

	
	leds	equ	0xff01
	sw	equ	0xff10 ;0xd000
	
	ldl0	r0,sw
	ldl0	r1,leds
	ldl0	r3,1
	ldl	r4,0x00010000
	ldh	r4,0x00010000
	ldl0	r10,1
	st	r10,r1
cikl:
	ld	r12,r0
	and	r12,r3
	jnz	masik
	
egyik:
	ld	r10,r1
	shl	r10
	cmp	r10,r4
	z1 ldl0	r10,1
	st	r10,r1
	jmp	cikl

masik:
	ld	r9,r1
	shr	r9
	z ldl0	r9,0x8000
	st	r9,r1
	jmp	cikl
