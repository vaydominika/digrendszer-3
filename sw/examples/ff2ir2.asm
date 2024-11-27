	.proc	p2
	
	leds	equ	0xff01
	sw	equ	0xff10

	ldl	r4,0x00010000
	ldh	r4,0x00010000
	ldl0	r10,1
	st	r10,leds
cikl:
	ld	r12,sw
	and	r12,0x1
	jnz	masik
	
egyik:
	ld	r10,leds
	shl	r10
	cmp	r10,r4
	z1 ldl0	r10,1
	st	r10,leds
	jmp	cikl

masik:
	ld	r9,leds
	shr	r9
	z ldl0	r9,0x8000
	st	r9,leds
	jmp	cikl
