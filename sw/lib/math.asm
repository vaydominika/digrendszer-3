	cpu	p2

	;;
	;; R4:quotient,R5:reminder= div      (R0:number,R1:divisor)
	;;                          srand    (R0:seed)
	;; R4=                      rand     ()
	;; R4=                      rand_max (R0:max)
	;; 
	
	.seg	_lib_segment_div

	;; INPUT  R0= N, R1= D
	;; OUTPUT R4= Q, R3= R
div::
	push	lr
	push	r6
	
	sz	r1
	NZ jmp	div_dok
	mov	r4,r0		; div by zero
	mvzl	r5,0x0
	jmp	div_ret
div_dok:
div_dummy:
	mvzl	r4,0		; Q= 0
	mvzl	r5,0		; R= 0
	mvh	r6,0x80000000	; m= 1<<31
	mvl	r6,0x80000000
div_cyc:
	sz	r6
	Z jmp	div_ret
	shl	r5		; r<<= 1
	test	r0,r6		; if (n&m)
	NZ or	r5,1		; r|= 1
	cmp	r5,r1		; if (r>=d)
	LO jmp	div_cyc_next
	sub	r5,r1		; r-= d
	or	r4,r6		; q|= m
	jmp	div_cyc_next
	jmp	div_cyc
div_cyc_next:
	shr	r6		; m>>= 1
	jmp	div_cyc
div_ret:
	pop	r6
	pop	pc
;	ret
	
	.ends
	

	;; Implementation of 32 bit xorshift algorithm by George Marsaglia
	;; https://www.jstatsoft.org/article/view/v008i14
	;; DOI: 10.18637/jss.v008.i14
	
	.seg	_lib_segment_rand

seed:	.db	2127401289

	
	;; Set actual value
	;; Input : R0 seed
	;; Output: -
srand::
	st	r0,seed
	ret

	;; Calculate next value, results 32 bit unsigned integer
	;; Input : -
	;; Output: R4 next random number in 0..2^32-1 range
rand::
	push	lr
	push	r0
	push	r2
	
	ld	r0,seed
	mov	r4,r0
	mvzl	r2,13
c1:	shl	r4
	dec	r2
	jnz	c1
	xor	r0,r4
	mov	r4,r0
	mvzl	r2,17
c2:	shr	r4
	dec	r2
	jnz	c2
	xor	r0,r4
	mov	r4,r0
	mvzl	r2,5
c3:	shl	r4
	dec	r2
	jnz	c3
	xor	r0,r4
	st	r0,seed

	mov	r4,r0
	
	pop	r2
	pop	r0
	pop	pc
;	ret
	.ends
	
	.seg	_lib_segment_rand_max
	;; Calculate next value converted to range 0..R0
	;; Input : R0 max value
	;; Output: R4 next random value in 0..R0 range
rand_max::
	push	lr
	push	r0
	push	r2
	push	r5
	
	mov	r2,r0
	inc	r2
	call	rand
	mov	r0,r4
	mov	r1,r2
	call	div
	mov	r4,r5
	
	pop	r5
	pop	r2
	pop	r0
	pop	pc
;	ret
	
	.ends
	
