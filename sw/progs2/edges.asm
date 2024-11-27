	cpu	p2

	org	1

	mvzl	r0,stack
	mvzl	r0,0
	st	r0,posedge
	st	r0,negedge
cycle:
	mvzl	r0,0
	call	btn_posedge
	jnc	no1

	ld	r0,posedge
	add	r0,1
	st	r0,posedge
no1:
	mvzl	r0,0
	call	btn_negedge
	jnc	no0

	ld	r0,negedge
	add	r0,1
	st	r0,negedge
no0:
	ld	r0,posedge
	ld	r1,negedge
	putb	r0,r1,2
	getb	r1,r1,1
	putb	r0,r1,3
	st	r0,GPIO.7SEG

	mvzl	r0,0
	call	btn_get
	C mvzl	r0,1
	NC mvzl	r0,0
	st	r0,GPIO.LED
	
	jmp	cycle

posedge:
	ds	1
negedge:
	ds	1
	
	ds	100
stack:	ds	1
	
