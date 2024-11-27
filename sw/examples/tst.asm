start:	jmp	start
	
;; 05341 szam megadasa a memoriaban:
bemenet:
	dd	0x30		; '0'
	dd	0x35		; '5'
	dd	0x33		; '3'
	dd	0x34		; '4'
	dd	0x31		; '1'
	dd	0

	;; Normal szoveg: Hello!
normal:
	dd	0x48		; H
	dd	0x65		; e
	dd	0x6c		; l
	dd	0x6c		; l
	dd	0x6f		; o
	dd	0

tomoritett:
	dd	0x6c6c6548	; l l e H
	dd	0x0000006f	; 0 0 0 o
	
