	.proc	P1
	
;;; egy 10 elemu tomb adatinak osszegzese

adat_db	=	10		; az adatok szama
porta	equ	0xff00		; kijelzo port cime

	nop
	
	ldl0	sp,verem	; stack pointer kezdoertek
	call	szum		; szubrutin a muvelethez
	ldl0	r1,eredmeny	; az eredmeny vizsgalata
	ld	r0,r1		; betoltes
	ldl0	r1,porta
	st	r0,r1		; kiiras a kijelzon
	nop	;r0,r1		;
vege:	jmp	vege		; itt leall a program

szum:
	push	lr		; visszateresi cim mentese
	inc	sp

	ldl0	r1,adatok	; mutato az adatokra
	ldl0	r2,adat_db	; ciklus valtozo (adatok szama)
	ldl0	r3,0		; resz osszeg

cikl:	ld	r4,r1		; adat beolvasasa
	add	r3,r3,r4	; hozzaadas a reszosszeghez
	inc	r1		; mutato a kovetkezo adatra
	dec	r2		; ciklusvaltozo csokkentese
	jnz	cikl		; ugras vissza, ha meg nincs kesz

	ldl0	r1,eredmeny	; az eredmeny tarolasi helye
	st	r4,r1		; az eredmeny tarolasa

	dec	sp
	pop	lr		; visszateresi cim betoltese
	ret

eredmeny:
	ds	1		; hely az eredmenynek
	
adatok:	dd	123		; adatok
	dd	545
	dd	-1431
	dd	0x2344
	dd	-21554
	dd	123
	dd	687
	dd	0x86
	dd	3456
	dd	-23
	
verem:	nop
	
