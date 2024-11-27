	.proc	P2
	
out	equ	0xff00		; address of GPIO output
	
	ldl0	r1,0		; start of counter value

cycl:	st	r1,out		; put counter on GPIO
	inc	r1		; increment counter
	jmp	cycl		; go to start of cycle
	
