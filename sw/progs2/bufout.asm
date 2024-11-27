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

	org	1

	mvzl	sp,eof_stack
	mvzl	r0,0
	st	r0,obuf_ff
	st	r0,obuf_lu
main:
	mvzl	r0,s1
	call	bprint
main_cyc:	
	call	do_obuf
	jmp	main_cyc

s1:	db	"Hello world!\n"
	
do_obuf:
	push	r0
	ld	r0,TSTAT
	test	r0,1		; TC bit
	Z pop	r0
	Z ret
	;; TC==1
do_obuf_uart_free:
	push	r1
	push	r2
	ld	r1,obuf_ff
	ld	r2,obuf_lu
	cmp	r1,r2
	jz	do_obuf_ret
	;; not empty
do_obuf_buf_nempty:
	ld	r0,r2,obuf	; got oldest char
	st	r0,DR
	inc	r2		; inc lu ptr
	btst	r2,obuf_mask
	st	r2,obuf_lu
do_obuf_ret:
	pop	r2
	pop	r1
	pop	r0
	ret

bputchar:
	push	lr
	push	r1
	push	r2
	ld	r1,obuf_ff
	inc	r1
	btst	r1,obuf_mask
bcp_wait:	
	ld	r2,obuf_lu
	cmp	r1,r2
	jnz	bcp_put
	call	do_obuf
	jmp	bcp_wait
bcp_put:
	ld	r1,obuf_ff
	st	r0,r1,obuf
	inc	r1
	btst	r1,obuf_mask
	st	r1,obuf_ff
bcp_ret:
	pop	r2
	pop	r1
	pop	lr
	ret
	
bprint:
	push	lr
	push	r1
	push	r2
	sz	r0
	jz	bp_ret
	mvzl	r2,0
	mov	r1,r0
bp_cyc:
	ld	r0,r1+,r2
	sz	r0
	jz	bp_ret
	call	bputchar
	jmp	bp_cyc
bp_ret:
	pop	r2
	pop	r1
	pop	lr
	ret
	
obuf_size =	128
obuf_mask =	0x7f
obuf:
	ds	128
obuf_ff:
	dd	0
obuf_lu:
	dd	0
	
stack:
	ds	200
eof_stack:	
	db	0
	
