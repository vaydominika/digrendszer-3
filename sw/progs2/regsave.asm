	.proc	P2

	org	1
	mvzl	r14,0x1234
	mvh	r14,0xabcd0000
	st	r14,place
	ld	r13,place
	nop
end:	jmp	end
place:	db	0
	
