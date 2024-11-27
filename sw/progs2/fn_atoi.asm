
	;; IN : R0 address of string of decimal number
	;; OUT: R0 converted binary value
	push	lr
	push	r1
	push	r2
	push	r3
	push	r4

	mov	r4,r0		; save start of string
atoi_end_search:
	ld	r1,r0		; check chars
	sz	r1		; until we reach 0
	Z jmp	atoi_start
	add	r0,1
	jmp	atoi_end_search
atoi_start:
	cmp	r0,r4		; process backward
	EQ jmp	atoi_ready	; until begin of string
	sub	r0,1
	
	ldl0	r1,1		; value of place
	ldl0	r2,0		; number
atoi_cycle:
	ld	r3,r0		; get next digit
	sub	r3,'0'		; convert ascii to bin
	mul	r3,r1		; mul by place value
	add	r2,r3		; accumulate into the number
	cmp	r0,r4		; reached begin of string?
	EQ jmp	atoi_ready
	sub	r0,1		; go towards string begin
	mul	r1,10		; mul place value by 10
	jmp	atoi_cycle
atoi_ready:
	mov	r0,r2		; store output in R0

	pop	r4
	pop	r3
	pop	r2
	pop	r1
	pop	pc
;	ret
	
