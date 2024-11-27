	.proc	P1
	
out	equ	0xff00		; address of GPIO output
	
	ldl0	r0,out		; use R0 as pointer to GPIO
	ldl0	r1,0		; start of counter value

cycl:	st	r1,r0		; put counter on GPIO
	inc	r1		; increment counter
	jmp	cycl		; go to start of cycle
	
