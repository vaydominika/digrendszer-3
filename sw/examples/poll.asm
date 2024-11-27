	.proc	P1
	
	;; GPIO port addresses
display	equ	0xff00		; address of 7seg display
led	equ	0xff01		; address of LEDs
btn	equ	0xff20 ;0xe000	; address of BTNs
sw	equ	0xff10 ;0xd000	; address of SWs

	ldl0	r0,btn		; load addresses to pointers
	ldl0	r1,led
	ldl0	r2,prev
	ldl0	r3,cnt
	ldl0	r4,display
	ldl0	r5,0x4		; bit mask for BTN2

	ldl0	r8,0		; clear LEDs
	st	r8,r1
	st	r8,r3		; clear counter
init:	
	ld	r8,r0		; get actual BTN values
	and	r8,r8,r5	; clear non-needed switches
	st	r8,r2		; store actual BTN2 in prev
	
cycl:	ld	r8,r0		; get buttons
	and	r8,r8,r5	; clear buttons but BTN2
	ld	r9,r2		; load prev
	cmp	r9,r9,r8	; compare actual and prev
	jz	nochange
changed:
	ldl0	r10,0		; check if actual is zero
	cmp	r8,r8,r10	; we do not care H->L
	jz	init
l_h:	
	ld	r8,r1		; load actual LED values
	ldl0	r9,0xff		; mask for negation
	xor	r8,r8,r9	; negate all LEDs
	st	r8,r1		; put new values on LEDs
	jmp	init		; go to refresh prev
	
nochange:
	ld	r9,r3		; load counter variable
	inc	r9		; increment by 1
	st	r9,r3		; store back into variable
	st	r9,r4		; put on 7seg display too
	jmp	cycl

prev:	db	0		; variable to hold prev value
cnt:	db	0		; free running counter
	
