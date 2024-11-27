	.proc	p2

	pesf	=	0xf015
	
	org	1

	mvzl	sp,stack
	mvzl	r0,str
	call	dtoi
	mov	r2,r4
	ces	pesf
	db	"val=%d %x\n"
end:
	jmp	end

str:	db	"4294967295"
	
	ds	100
stack:
	db	0
	
