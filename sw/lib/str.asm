	cpu	p2

	;;
	;; F.C,R4=              dtoi        (R0:str)
	;; F.C,R4=              htoi        (R0:str)
	;; F.C,R4:addr,R5:idx=  str_chr     (R0:str, R1:chr)
	;; F.C=                 str_eq      (R0:str1, R1:str2)
	;; F.C=                 str_ieq     (R0:str1, R1:str2)
	;; R4=                  str_len     (R0:str)
	;; R4=                  str_size    (R0:str)
	;; R4=                  str_getchar (R0:str, R1:idx)
	;;                      str_setchar (R0:str, R1:idx, R2:char)
	;; F.C=                 str_packed  (R0:str)
	;; 
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_dtoi
	;; In : R0 address of string/packed
	;; Out: R4 numeric value of string
	;;      F.C=1 conversion success
	;;      F.C=0 conversion error
dtoi::
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3
	push	r5
	
	mvzl	r4,0		; return value
	mov	r2,r0		; address in r2
	mvzl	r3,0		; word index
	sz	r2		; check pointer
	jz	dtoi_false	; for NULL value
dtoi_cyc:
	mvzl	r5,0		; byte index
	ld	r1,r3+,r2	; pick a char
	sz	r1		; end of string?
	jz	dtoi_true	; normal exit
dtoi_byte:
	getbz	r0,r1,r5
	sz	r0
	jz	dtoi_cyc
	call	isdigit		; check ascii char
	jnc	dtoi_false	; exit if not a number
	sub	r0,'0'		; convert char to number
	mul	r4,10		; shift tmp
	add	r4,r0		; add actual number
	inc	r5
	cmp	r5,4
	jz	dtoi_cyc
	jmp	dtoi_byte
	
dtoi_true:
	sec
	jmp	dtoi_ret
dtoi_false:
	clc
dtoi_ret:
	pop	r5
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	pc

	.ends
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_htoi
htoi::
	sz	r0		; check NULL pointer
	Z mvzl	r4,0
	Z clc
	Z ret
	push	lr
	push	r1
	call	_pm_htoi
	mov	r4,r1
	pop	r1
	pop	pc

	.ends
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_chr
str_chr::
	sz	r0		; check NULL pointer
	Z clc
	Z ret
	zeb	r1		; prepare character
	push	lr
	push	r1
	push	r2
	mov	r4,r0
	mov	r0,r1
	mov	r1,r4
	call	_pm_strchr
	mov	r4,r1
	mov	r5,r2
	pop	r2
	pop	r1
	pop	pc
	
	.ends
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_eq
str_eq::
	clc			; return false if
	sz	r0		; any pointer is NULL
	Z ret
	sz	r1
	Z ret	
	jmp	_pm_streq

	.ends


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_ieq
str_ieq::
	clc			; return false if
	sz	r0		; any pointer is NULL
	Z ret
	sz	r1
	Z ret	
	jmp	_pm_strieq

	.ends
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_len
	;; INPUT  R0= address of string/packed
	;; OUTPUT R4= nuof chars in string
str_len::
	push	r0
	push	r1
	push	r2
	push	r3
	mov	r1,r0
	mvzl	r2,0
	mvzl	r4,0
	sz	r0		; check NULL pointer
	jz	p2_end
p2_next:
	ld	r3,r1
	sz	r3
	jz	p2_end
p2_cyc:	
	getbz	r0,r3,r2
	sz	r0
	NZ inc	r4
	inc	r2
	test	r2,3
	Z plus	r1,1
	Z jmp	p2_next
	jmp	p2_cyc
p2_end:
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	ret

	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_size
	;; INPUT  R0= address of string/packed
	;; OUTPUT R4= nuof words in memory occupied by string
	;;            (including closing null)
str_size::
	push	r0
	push	r1
	push	r2
	push	r3
	mov	r1,r0
	mvzl	r2,0
	mvzl	r4,0
	sz	r0		; check NULL pointer
	jz	p2_end
p2_next:
	ld	r3,r1
	plus	r4,1
	sz	r3
	jz	p2_end
p2_cyc:	
	getbz	r0,r3,r2
	inc	r2
	test	r2,3
	Z plus	r1,1
	Z jmp	p2_next
	jmp	p2_cyc
p2_end:
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	ret
	
	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_getchar
	;; In : R0 address of string/packed
	;;      R1 char index
	;; Out: R4 char at index, or 0
str_getchar::
	sz	r0		; check NULL pointer
	Z mvzl	r4,0
	Z ret
	push	r1
	push	r2
	push	r3
	push	r5

	mvzl	r3,0		; word index
	inc	r1
gchar_cyc:
	mvzl	r5,0		; start byte index in word
	ld	r4,r3+,r0	; pick a word
	sz	r4		; EOS?
	jz	gchar_ret_eos
gchar_byte:
	getbz	r2,r4,r5	; pick byte from word
	sz	r2		; is it 0?
	jz	gchar_cyc	; if yes, get next word
gchar_nonz:
	dec	r1		; count
	jz	gchar_ret_act	; repeat if index is not reached

	inc	r5		; next byte index
	cmp	r5,4		; is it overflowed?
	jz	gchar_cyc
	jmp	gchar_byte
	
gchar_ret_act:
	mov	r4,r2
	jmp	gchar_ret
gchar_ret_eos:
	mvzl	r4,0
gchar_ret:	
	pop	r5
	pop	r3
	pop	r2
	pop	r1
	ret
	
	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_setchar
	;; In : R0 address of string/packed
	;;      R1 char index
	;;      R2 new character
	;; Out: -
str_setchar::
	sz	r0		; check NULL pointer
	Z ret	
	push	r1
	push	r3
	push	r5
	push	r6
	
	mvzl	r3,0		; word index
	inc	r1
schar_cyc:
	mvzl	r5,0		; start byte index in word
	ld	r4,r3,r0	; pick a word
	sz	r4		; EOS?
	jz	schar_ret
schar_byte:
	getbz	r6,r4,r5	; pick byte from word
	sz	r6		; is it 0?
	Z plus	r3,1		; if yes, get next word
	jz	schar_cyc
schar_nonz:
	dec	r1		; count
	jz	schar_set	; repeat if index is not reached

	inc	r5		; next byte index
	cmp	r5,4		; is it overflowed?
	Z plus	r3,1
	jz	schar_cyc
	jmp	schar_byte
	
schar_set:
	putb	r4,r2,r5	; replace char in orig word
	st	r4,r3,r0	; store in memory
schar_ret:
	pop	r6
	pop	r5
	pop	r3
	pop	r1
	ret
	
	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_str_packed
	;; In : R0 string address
	;; Out: F.C=1 if string is packed
str_packed::
	sz	r0		; check NULL pointer
	Z clc
	Z ret
	push	r1
	push	r2
	mvzl	r2,0		; index
sp_cyc:
	ld	r1,r2+,r0	; pick word
	sz	r1
	jz	sp_false
	and	r1,0xff00	; check upper bytes
	jz	sp_cyc
sp_true:
	sec
	jmp	sp_ret
sp_false:	
	clc
sp_ret:	
	pop	r3
	pop	r2
	ret
	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
