	.proc	P2

btn		=	GPIO.BTN
dummy		=	12
	
	org	1
	jmp	start		;start
	db	dummy
start:	
	mvzl	r1,217
	st	r1,UART.CPB
	mvzl	r1,3		; turn on rx and tx
	st	r1,UART.CTRL

	mvzl	r13,eof_stack
	mvzl	r10,0
	jmp	real_start	 ;try_himem
	
	.segment try_himem
	dummy	=	33
try_himem:
	.export	try_himem
	mvl	r0,0x10000
	mvh	r0,0x10000
	mvzl	r2,0
cyc:
	st	r2,r2+,r0
	cmp	r2,100
	jnz	cyc
	jmp	exit
	db	dummy
exit:
;cyc:
	jmp	real_start
	.ends


	db	dummy

	.seg	main

cyc:
	db	cyc
	.ends
	
	jmp	cyc
	db	dummy
	;db	cyc_belso
real_start:
	mvzl	r0,0x1234
	st	r0,BRD_CTRL.OUT
cyc:
	call	monitor_by_uart		; enter monitor by uart
	mvzl	r0,0			; number of checked button
	call	monitor_by_button
	st	r10,GPIO.PORTA
	st	r10,GPIO.PORTB
	mov	r1,r10
	mov	r2,r10
	ces	eprintf
	db	"%x %d\n"
	add	r10,1
	jmp	cyc

	.ends			; main
	
;	.seg	try_himem
;	.ends

	ds	100
eof_stack:	
	db	0
	
