	.proc	p2
	
out	equ	0xff00		; address of GPIO output
over	=	0x00080000	; overflowed display value

	ldl	r2,over		; constant to compare with
	ldh	r2,over		;
	
first:	ldl0	r1,8		; first displayed pattern

cycl:	st	r1,out		; put pattern on GPIO
	shl	r1		; calc next pattern
	shl	r1		; by shifting it up
	shl	r1		; by one digit of the display
	shl	r1
	cmp	r1,r2		; check for overflow
	jnz	cycl		; continue if not
	jmp	first		; restart to first otherwise
	
