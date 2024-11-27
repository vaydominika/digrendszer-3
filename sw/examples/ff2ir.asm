	.proc	P1
	
	leds	equ	0xff01
	sw	equ	0xff10 ;0xd000
	
	ldl0	r0,sw
	ldl0	r1,leds
	ldl0	r3,1
	ldl	r4,0x10000
	ldh	r4,0x10000
	ldl0	r10,1
	st	r10,r1
cikl:
	ld	r12,r0
	and	r12,r12,r3
	jnz	masik
	
egyik:
	ld	r10,r1
	shl	r10,r10
	cmp	r10,r10,r4
	z ldl0	r10,1
	st	r10,r1
	jmp	cikl

masik:
	ld	r9,r1
	shr	r9,r9
	z ldl0	r9,0x8000
	st	r9,r1
	jmp	cikl
	
	
