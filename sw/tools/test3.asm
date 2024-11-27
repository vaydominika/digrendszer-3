	.proc	p2

	org	1
	
	mvzl	sp,stack
	
main_cycle:
	call	rand
	mov	r0,r1
	mvzl	r1,15
	call	div
	jmp	main_cycle
	.db	text

	.seg	stack
	.ds	99
stack::	.ds	1
	.ends
	
	.seg	tseg
text	==	11
	.ends
	
	.seg	notneeded
	nop
nn:	.ds	2
	nop
	.ends
