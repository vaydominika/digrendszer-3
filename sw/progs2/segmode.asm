	cpu	p2

	org	1

	mvzl	sp,stack

	mvzl	r0,0
	st	r0,GPIOC.ODR
	st	r0,GPIOD.ODR
	mvzl	r0,0xa1
	st	r0,BRD_CTRL.OUT

	mvzl	r0,'e'
	call	_pm_ascii2seg
prompt:	
	ces	eprintf
	db	"Press a key:"
cyc:
	call	input_avail
	NC jmp	chkbtn
	call	getchar
	mov	r0,r4
	call	_pm_ascii2seg
	mov	r1,r0
	mov	r2,r4
	ces	eprintf
	db	" %c 0x%x\n"
	ld	r0,GPIOC.ODR
	ld	r1,GPIOD.ODR
	mvzl	r2,8
shcyc:
	shr	r1
	ror	r0
	dec	r2
	jnz	shcyc
	putb	r1,r4,3
	st	r0,GPIOC.ODR
	st	r1,GPIOD.ODR
	jmp	prompt
chkbtn:	
	mvzl	r0,0
	call	monitor_by_button
	jmp	cyc
	
	ds	100
stack:
	ds	1
	
