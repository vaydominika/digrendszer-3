	cpu	p2

	org	1

	mvzl	sp,stack
	mvzl	r0,25000
	st	r0,CLOCK.PRE
main:
	mvzl	r0,100
	st	r0,CLOCK.BCNT2
	mvzl	r0,0
	st	r0,nr
	st	r0,GPIO.LED
	call	led_on
cyc1:
	ld	r0,CLOCK.BCNT2
	sz	r0
	jnz	cyc1

	mvzl	r0,100
	st	r0,CLOCK.BCNT2

	ld	r0,nr
	inc	r0
	cmp	r0,0x10
	jz	out1
	st	r0,nr
ton:	call	led_on
	jmp	cyc1
out1:	
	mvzl	r0,0
	st	r0,nr
	call	led_off
cyc2:
	ld	r0,CLOCK.BCNT2
	sz	r0
	jnz	cyc2

	mvzl	r0,100
	st	r0,CLOCK.BCNT2

	ld	r0,nr
	inc	r0
	cmp	r0,0x10
	jz	out2
	st	r0,nr
toff:	call	led_off
	jmp	cyc2
out2:

end:	jmp	main
	
nr:	ds	1
	
	ds	100
stack:
	db	0
	
