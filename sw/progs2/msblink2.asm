	proc		p2
	
	PRE	= 0xff51
	CLK	= 0xff50
	BCNT2	= 0xff52
	
	PA	= 0xff00	; seg7= now
	PB	= 0xff01	; led= blink
	
	org	1

	ldl0	sp,stack
	
	ldl0	r0,25000	; 25 MHz -> 1ms
	st	r0,PRE		; start
	ldl0	r0,0		; turn OFF all LEDs
	st	r0,PB
	ld	r0,period2	; Setup back counter #2
	st	r0,BCNT2
cyc:
	call	0xf001		; Check UART to return monitor
	ld	r0,CLK		; r0=now
	st	r0,PA		; display on seg7
	ld	r1,last		; r1=last
	mov	r2,r0		; backup copy of now
	sub	r2,r1		; r2= now-last
	ld	r3,period	; compare to period
	cmp	r2,r3		; now-last > period
	HI jmp	elapsed0

	ld	r0,BCNT2	; check back counter expiration
	sz	r0
	jz	elapsed2
	
	jmp	cyc

elapsed0:
	st	r0,last		; last= now
	ld	r1,PB		; blink LED0
	xor	r1,1
	st	r1,PB
	jmp	cyc

elapsed2:
	ld	r1,PB		; blink LED1
	xor	r1,2
	st	r1,PB
	ld	r1,period2
	st	r1,BCNT2
	jmp	cyc
	
last:	dd	0
period:	dd	500
period2: dd	200
	
	ds	100
stack:	
	db	0
	
