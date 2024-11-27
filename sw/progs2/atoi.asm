	cpu	p2

PortA	equ	0xff00
PortB	equ	0xff01
PortC	equ	0xff02
PortD	equ	0xff03
	
print_vhex = 	0xf011
monitor	= 	0xf001
	
	org	1
	ldl0	sp,atoi_stack
	ld	r0,0x16
	st	r0,PortD
	
	ldl0	r0,text
end_search:
	ld	r1,r0
	sz	r1
	Z jmp	go_on
	add	r0,1
	jmp	end_search
go_on:
	cmp	r0,text
	EQ jmp	atoi_end
	sub	r0,1
	st	r0,PortD
	
	ldl0	r1,1		; value of place
	ldl0	r2,0		; number
cycle:
	st	r0,PortA
	ld	r3,r0		; get next digit
	st	r3,PortB
	sub	r3,'0'
	mul	r3,r1
	add	r2,r3
	st	r2,PortC
	cmp	r0,text
	EQ jmp	display
	sub	r0,1
	mul	r1,10
	jmp	cycle
display:
	ldl0	r10,0x55aa
	st	r10,PortD
	st	r2,PortA
	mov	r0,r2
	ldl0	r1,4
	call	print_vhex
atoi_end:
	call	monitor
	jmp	atoi_end

text:	db	"5671"
	
	ds	100
atoi_stack:	
	db	0
	
