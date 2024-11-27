	cpu	p2
	
	org	1
	
	ldl0	sp,verem

	ldl0	r0,25000
	st	r0,CLOCK.PRE
	ldl0	r0,100
	st	r0,CLOCK.BCNT2
	ldl0	r0,1
	st	r0,GPIO.LED
		
ciklus:
	call	monitor_by_uart
		
	ld	r0,CLOCK.BCNT2
	sz	r0
	Z call	ff_leptetes
		
	ldl0	r0,1
	call	btn_posedge
	NC jmp 	tovabb
; BTN1 megnyomodott
; run= !run
	ld	r0,run
	sz	r0
	Z ldl0	r0,1
	NZ ldl0	r0,0
	st	r0,run
		
tovabb:
	jmp	ciklus

ido_tabla:
	dd	10
	dd	20
	dd	50
	dd	100
	dd	200
	dd	500
	dd	750
	dd	1000
		
ff_leptetes:
	push	lr
	ld	r0,run
	sz	r0
	Z jmp	nem_leptet
	ld	r0,GPIO.SW
	btst	r0,7
	ld	r0,r0,ido_tabla
	st	r0,CLOCK.BCNT2
	call	itobcd
	st	r4,GPIO.7SEG
	
	ld	r0,GPIO.LED
	test	r0,0x8000
	NZ ldl0	r0,1
	Z shl	r0
	st	r0,GPIO.LED
nem_leptet:
	pop	pc

run:
	db	1
		
	ds	100
verem:
	db	0
