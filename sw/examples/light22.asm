	.proc	p2
	
porta	equ	0xff00		; address of GPIO output

start:	ldl0	r0,patterns	; start of table
	
cycl:	ld	r2,r0		; get one item
	sz	r2		; check for 0
	jz	start		; restart on zero item
	st	r2,porta	; put item on display
	inc	r0		; step ptr to next item
	jmp	cycl		; go to get it
	
patterns:
	dd	0x00000008	; D0 d/3
	dd	0x00000040	; D0 g/6
	dd	0x00000001	; D0 a/1

	dd	0x00000100	; D1 a/1
	dd	0x00004000	; D1 g/6
	dd	0x00000800	; D1 d/3

	dd	0x00080000	; D2 d/3
	dd	0x00400000	; D2 g/6
	dd	0x00010000	; D2 a/1

	dd	0x01000000	; D3 a/1
	dd	0x40000000	; D3 g/6
	dd	0x08000000	; D3 d/3

	dd	0x00080000	; D2 d/3
	dd	0x00000800	; D1 d/3

	dd	0		; end of table sign
	
