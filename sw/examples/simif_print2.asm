	.proc	p2

porta	equ	0xff00
simif	equ	0xffff

	mvzl	sp,topof_stack

	mvzl	r1,'_'
	st	r1,simif
	ld	r1,simif
	st	r1,porta
	
	mvzl	r1,Hello
	call	print
vege:	jmp	vege

	org	0x20
local_putchar:
	push	lr
	mvzl	r10,simif
	mvzl	r12,'p'
	st	r12,r10
	st	r0,r10
	pop	pc
;	ret

	org	0x30
	;; print 0 terminated string at R1
print:
	push	lr
print_cikl:
	ld	r0,r1
	cmp	r0,0
	jz	print_exit
	call	local_putchar
	add	r1,1
	jmp	print_cikl
print_exit:
	pop	pc
;	ret
	
Hello:	db	"Hello World!\n"
	

	ds	0xff
topof_stack:
	db	0
	
