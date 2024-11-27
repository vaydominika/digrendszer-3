	PORTA	=	0xf000
	
start:
	nop

	ldi	r1,0xdeadbeef
	ldi	r2,0x01010a0a
	ldl0	r10,PORTA
cyc:	
	st	r1,r10
	add	r1,r1,r2
	jnz	cyc

end:	
	jmp	end
	
