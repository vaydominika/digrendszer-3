	.proc	p2

	;;
	;;          putchar     (R0:char)
	;;          prints      (R0:str)
	;;          printsnl    (R0:str)
	;;          printh      (R0:val,R1:sep_len)
	;;          printd      (R0:val)
	;;          eprints     ()
	;;          printf      (R0:format,R1:param,...)
	;;          eprintf     (R1:param,...)
	;;
	;; F.C=     input_avail ()
	;; F.C,R4=  getchar     ()
	;; R4=      read        ()
	;;          le_init     (R0:buffer, R1:size)
	;;          le_start    ()
	;; F.C=     le_read     ()
	;;

	
	.seg	_lib_segment_putchar
putchar::
	jmp	_pm_putchar
	.ends

	
	.seg	_lib_segment_prints
prints::
	jmp	_pm_prints
	.ends
	

	.seg	_lib_segment_printsnl	
printsnl::
	jmp	_pm_printsnl
	.ends


	.seg	_lib_segment_printh
printh::
	jmp	_pm_print_vhex
	.ends


	.seg	_lib_segment_printd
printd::
	jmp	_pm_printd
	.ends


	.seg	_lib_segment_eprints
eprints::
	jmp	_pm_pes
	.ends
	

	.seg	_lib_segment_printf
printf::
	jmp	_pm_printf
	.ends


	.seg	_lib_segment_eprintf
eprintf::
	jmp	_pm_pesf
	.ends


	.seg	_lib_segment_input_avail
input_avail::
	jmp	_pm_check_uart
	.ends


	.seg	_lib_segment_getchar
getchar::
	push	lr
gc_wait:	
	call	_pm_check_uart
	jnc	gc_wait
	ld	r4,UART.DR
	pop	pc
	.ends


	.seg	_lib_segment_read
read::
	ld	r4,UART.DR
	ret
	.ends

	
	
	.seg	_lib_segment_line_editor
	;; IN : R0 buffer address, R1 buffer length
	;; OUT: -
le_init::
le_setbuf::
	push	lr
	sz	r0
	Z mvzl	r1,0
	st	r0,le_buf_addr	; store buffer info
	st	r1,le_buf_len	; in local vars
	call	le_start	; set buffer empty
	pop	pc
;	ret

	;; IN: -
	;; OUT: -
le_start::
	push	lr
	push	r1
	push	r2
	mvzl	r2,0		; set cursor post to 0
	st	r2,le_cursor_pos
	ld	r1,le_buf_addr	; buf[0]= 0
	sz	r1
	NZ st	r2,r1
	mvzl	r1,le_ptr	; ptr= 0
	st	r2,r1
	pop	r2
	pop	r1
	pop	pc
;	ret

	;; IN: -
	;; OUT: F.C: 1=done (Enter pressed)
le_read::
tu_fgets::
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3
	push	r4
	
	call	input_avail	; if there is no char
	NC jmp	ler_ret		; return with false
ler_got_char:	
	call	read		; read one char
	mov	r0,r4
	cmp	r0,13		; check CR and LF
	jz	ler_true	; both accepted as ENTER
	cmp	r0,10
	jz	ler_true
	;; not ENTER
	cmp	r0,8		; is it backspace?
	jz	ler_bs
	cmp	r0,0x7f
	jz	ler_del
	jmp	ler_nobs
	
ler_bs:
ler_del:	
	;; process Backspace/DEL
	ld	r2,le_ptr	; already emtpy?
	sz	r2
	jz	ler_false
	dec	r2		; ptr= pre-1
	st	r2,le_ptr
	ld	r1,le_buf_addr	; buf[ptr]=0
	mvzl	r0,0
	sz	r1
	NZ st	r0,r1,r2
	ces	eprintf
	db	"\e[1D \e[1D"
	jmp	ler_false
	
ler_nobs:	
	cmp	r0,32		; skip ctrl chars
	ULT jmp	ler_false
	cmp	r0,128		; skip graphic chars
	UGE jmp	ler_false
	;; process accpeted char
	ld	r1,le_buf_addr
	sz	r1
	jz	ler_false
	ld	r1,le_buf_len
	ld	r2,le_ptr
	mov	r3,r2
	inc	r3
	cmp	r3,r1
	UGE jmp	ler_noroom
	ld	r1,le_buf_addr
	st	r0,r1,r2
	call	putchar
	mvzl	r0,0
	st	r0,r1,r3
	st	r3,le_ptr
	jmp	ler_false
	
ler_noroom:
	jmp	ler_false
ler_false:
	clc
	jmp	ler_ret
ler_true:
	sec
	jmp	ler_ret
ler_ret:
	pop	r4
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	pc
;	ret

le_buf_len:
	db	0
le_buf_addr:
	db	0
le_cursor_pos:
	db	0
le_ptr:
	db	0
	.ends
	
