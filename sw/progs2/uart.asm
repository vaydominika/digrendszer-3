	.proc	P2

	DR	equ	0xff40
	CTRL	equ	0xff41
	RSTAT	equ	0xff42
	TSTAT	equ	0xff43
	CPB	equ	0xff44
	QUEUE	equ	0xff45
	
	org	1
	mvl	SP,0x1ffff
	mvh	SP,0x1ffff
	
	mvzl	r1,0x3		; enable rx, tx
	mvzl	r2,CTRL
	st	r1,r2
	
	mvzl	r1,0x55		; send 0x55
	mvzl	r2,DR
	st	r1,r2
;	call	wait_cyc	;
start:	
	mvzl	r0,'A'
main_cyc:
	call	send
	add	r0,1
	mvzl	r2,'Z'
	add	r2,1
	cmp	r0,r2
	jnz	main_cyc
	
end:	jmp	start

	
wait_tx:
	push	LR
	mvzl	r2,TSTAT
wait_cyc:
	ld	r3,r2
	btst	r3,1
	jz	wait_cyc
	pop	PC
;	ret

send:
	push	LR
	call	wait_tx
	mvzl	r2,DR
	st	r0,r2
	pop	PC
;	ret
	
