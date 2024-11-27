	.proc	P2

	DR	equ	0xff40
	CTRL	equ	0xff41
	RSTAT	equ	0xff42
	TSTAT	equ	0xff43
	CPB	equ	0xff44
	QUEUE	equ	0xff45
	IRA	equ	0xff46
	CHARCNT equ	0xff47
	FIFOCNT equ	0xff48
	FULLCNT equ	0xff49
	
	PORTA	equ	0xff00
	DSP	equ	0xff00
	PORTB	equ	0xff01
	LED	equ	0xff01
	PORTC	equ	0xff02
	PORTD	equ	0xff03
	
	sw	equ	0xff10
	btn	equ	0xff20

check_uart	=	0xf008
pes		=	0xf012
	
	org	1
	nop
	jmp	real_start
log_ptr:	dd	0
real_start:	
	ldl0	sp,stack

	ces	pes
	db	"Hello World\n"
	
	ld	r0,0
	st	r0,PORTA
	st	r0,PORTB
	st	r0,PORTC
	st	r0,PORTD
	
	;mvzl	r0,434		; 57600 baud
	;st	r0,CPB
	mvzl	r0,0x3		; enable rx, tx
	st	r0,CTRL
	
	mvzl	r0,'>'		; send prompt
	st	r0,DR
start:	

main_cyc:
	;call	check_input	; call check input
	ld	r4,RSTAT	; checkin: read RSTAT

	test	r4,0x20		; check if queue is full
	NZ call	qfull
	NZ st	r4,PORTA	; display RSTAT, if queue is full

	test	r4,1		; Z=0 Received avail
	NZ call	got_char	; avail: jump to handle
	
	;jmp	main_cyc	; main cycle

	ldl0	r0,1		; check btn[1]
	call	btn_posedge
	;; press btn[1]: BTND
	C call	0xf000		; enter monitor

	ld	r9,FULLCNT
	st	r9,PORTD
	ld	r10,FIFOCNT
	st	r10,PORTC
	
	jmp	main_cyc

;;; ;;;
	call	check_uart
	NC jmp	nochar
	call	read
	call	send
nochar:	
	ldl0	r0,2
	call	btn_posedge
	NC jmp	nopress4
	;; press btn[2]: BTNU
	call	check_input
	jz	nopress4
	ld	r0,QUEUE
	jmp	got_char
nopress4:	
	call	check_input
	NZ ld	r0,DR
	jnz	got_char
	jmp	main_cyc

	
got_char:
	push	lr
	ld	r0,DR		; avail: read UART DR

	call	half_bit_delay
	
	st	r0,IRA		; inc raddr counter in fifo

	ld	r1,PORTB
	add	r1,1
	st	r1,PORTB

	call	echo
	pop	pc
;	ret

	
echo:
	push	lr
	cmp	r0,10
	jz	echo_it
	cmp	r0,13
	jz	echo_it
not_eol:
	;mvzl	r2,0x20
	;xor	r2,0xffff
	;sew	r2
	;and	r0,r2		; covert to UPCASE
echo_it:
	call	send
	pop	pc
;	ret
	
	
end:	jmp	start

	
half_bit_delay:	
	;mvzl	r8,20		; dummy half bit time delay
	ld	r8,sw
	btst	r8,255
	sz	r8
	Z ret
fake_cyc:
	dec	r8
	jnz	fake_cyc
	ret

	
wait_tx:
wait_cyc:			; wait_tx routine
	ld	r3,TSTAT	; read TSTAT
	test	r3,1		; check TC bit
	Z jmp	wait_cyc	; wait tx cycle
	ret

send:
	;push	LR		; send routine
	;call	wait_tx		; call wait_tx
	ld	r3,TSTAT
	test	r3,1
	jnz	tx_first_ready
send_cyc:
	ld	r3,TSTAT
	test	r3,1
	jz	send_cyc
	jnz	tx_send
tx_first_ready:
	;ld	r4,PORTD
	;add	r4,1
	;st	r4,PORTD
tx_send:	
	st	r0,DR		; put R0 in uart DR
	;pop	LR
	ret
	
check_input:
	;push	lr
	ld	r4,RSTAT	; checkin: read RSTAT
	st	r4,DSP		; display RSTAT
	test	r4,1		; Z=0 Received avail
	;pop	LR
	ret
	


qfull:
	push	lr
	ld	r5,log_ptr
	mvzl	r6,0x8000
	cmp	r5,r6
	CS jmp	log_ov
	st	r4,r5,logs
	inc	r5
	st	r5,log_ptr
log_ov:
	pop	pc
;	ret
	
	
	ds	100
stack:	
	db	0
	
	org	0x1000
logs:	
