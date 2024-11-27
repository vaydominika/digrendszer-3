	.proc	p2

	;;
	;; F.C=  btn_posedge    (R0:btn)
	;; F.C=  btn_negedge    (R0:btn)
	;; F.C=  btn_get        (R0:btn)
	;; F.C=  sw_posedge     (R0:sw)
	;; F.C=  sw_negedge     (R0:sw)
	;; F.C=  sw_get         (R0:sw)
	;;       btn_restart    ()
	;;       sw_restart     ()
	;;       led_on         (R0:led)
	;;       led_off        (R0:led)
	;;       led_toggle     (R0:led)
	;;       led_set        (R0:led, R1:val)
	;; F.C=  led_get        (R0:led)
	;; 

	
	.seg	_lib_segment_nr_to_mask
	
	;; Convert btn/sw number into bitmask
	;; In : R0 number
	;; Out: R0 mask
_nr_to_mask::
	push	r1
	btst	r0,0x1f		; max nr is 31
	mvzl	r1,1		; mask for nr==0
nr_to_mask_cyc:	
	sz	r0		; is nr zero?
	jz	nr_to_mask_ret	; if yes, go out
	shl	r1		; shift mask up
	dec	r0		; decrement nr
	jmp	nr_to_mask_cyc	; check for zero
nr_to_mask_ret:
	mov	r0,r1		; return mask in R0
	pop	r1
	ret

	.ends


	.seg	_lib_segment_led

	;; In : R0 number of LED (0-24)
	;; Out: -
led_on::
	push	lr
	push	r1
	call	_nr_to_mask
	ld	r1,GPIO.LED
	or	r1,r0
	st	r1,GPIO.LED
	pop	r1
	pop	pc

	;; In : R0 number of LED (0-24)
	;; Out: -
led_off::
	push	lr
	push	r1
	call	_nr_to_mask
	not	r0
	ld	r1,GPIO.LED
	and	r1,r0
	st	r1,GPIO.LED
	pop	r1
	pop	pc

	;; In : R0 number of LED (0-24)
	;; Out: -
led_toggle::
	push	lr
	push	r1
	call	_nr_to_mask
	ld	r1,GPIO.LED
	xor	r1,r0
	st	r1,GPIO.LED
	pop	r1
	pop	pc

	;; In : R0 number of LED (0-24)
	;;      R1 value (bool)
	;; Out: -
led_set::
	push	lr
	push	r1
	push	r2
	call	_nr_to_mask
	sz	r1
	NZ mov	r1,r0
	not	r0
	ld	r2,GPIO.LED
	and	r2,r0
	or	r2,r1
	st	r2,GPIO.LED
	pop	r2
	pop	r1
	pop	pc

	;; In : R0 number of LED (0-24)
	;; Out: F.C LED value
led_get::
	push	lr
	push	r1
	call	_nr_to_mask
	ld	r1,GPIO.LED
	btst	r1,r0
	Z clc
	NZ sec
	pop	r1
	pop	pc
	
	.ends

	
	.seg	_lib_segment_edge

last_btn:
	ds	1
last_sw:
	ds	1
last_btn_down:
	ds	1
last_sw_down:
	ds	1
last_btn_inited:
	db	0
last_sw_inited:	
	db	0

	
		;; Check button/sw press
	;; ----------------------------------------------------------------
	;; Input: R0= bit mask of examined BTN/SW
	;;        R1= 0=check for press 1=check for release
	;;        C=0 check BTN
	;;        C=1 check SW
	;; Output: C=0 if not pressed, C=1 if pressed
_lib_edge_detect::
	push	lr
	push	r1
	push	r2
	push	r3
	push	r4
	push	r5

	mov	r5,r1		; what edge to check
	C jmp	init_sw
init_btn:	
	ld	r1,last_btn_inited
	sz	r1
	jnz	pressed_inited
	mvzl	r1,1
	st	r1,last_btn_inited
	ld	r1,GPIO.BTN
	st	r1,last_btn
	st	r1,last_btn_down
	jmp	pressed_false
init_sw:
	ld	r1,last_sw_inited
	sz	r1
	jnz	pressed_inited
	mvzl	r1,1
	st	r1,last_sw_inited
	ld	r1,GPIO.SW
	st	r1,last_sw
	st	r1,last_sw_down
	jmp	pressed_false
pressed_inited:
	;; R1 address of last
	;; R2 address of port
	NC mvzl	r2,GPIO.BTN
	C mvzl	r2,GPIO.SW
	jc	ch_sw
ch_btn:
	sz	r5
	Z mvzl	r1,last_btn
	NZ mvzl	r1,last_btn_down
ch_sw:
	sz	r5
	Z mvzl	r1,last_sw
	NZ mvzl	r1,last_sw_down
	
	;; R3 value of last
	;; r4 value of port
	ld	r3,r1
	ld	r4,r2
	
	and	r3,r0		; masked last
	and	r4,r0		; masked port
	cmp	r3,r4
	EQ jmp	pressed_false
	not	r0		; negated mask
	ld	r3,r1		; original last
	and	r3,r0		; clear checked bit
	or	r3,r4		; or with masked port
	st	r3,r1		; store new last value
	sz	r5
	jnz	check_release
check_push:
	sz	r4		; check new port value
	jz	pressed_false
	jnz	pressed_true
check_release:
	sz	r4
	jnz	pressed_false
;	jz	pressed_true
pressed_true:	
	sec
	jmp	pressed_end
pressed_false:
	clc
pressed_end:
	pop	r5
	pop	r4
	pop	r3
	pop	r2
	pop	r1
	pop	pc
;	ret


btn_restart::
	push	r1
	ld	r1,GPIO.BTN
	st	r1,last_btn
	pop	r1
	ret

	
sw_restart::
	push	r1
	ld	r1,GPIO.SW
	st	r1,last_sw
	pop	r1
	ret

	.ends


	.seg	_lib_segment_btn
		
	;; Check button press
	;; Input : R0= number of examined BTN (0-15)
	;; Output: C=0 not pressed
	;;         C=1 pressed
;pressed::
btn_posedge::
	push	lr
	call	_nr_to_mask
	push	r1
	mvzl	r1,0
	clc
	call	_lib_edge_detect
	pop	r1
	pop	pc
;	ret

	
	;; Check button release
	;; Input : R0= number of examined BTN (0-15)
	;; Output: C=0 not released
	;;         C=1 released
btn_negedge::
	push	lr
	call	_nr_to_mask
	push	r1
	mvzl	r1,1
	clc
	call	_lib_edge_detect
	pop	r1
	pop	pc
;	ret

	
	;; Read actual state of a button
	;; Input : R0= number of button (0-15)
	;; Output: C=1 if btn is ON
	;;         C=0 if btn is OFF
btn_get::
	push	lr
	push	r1
	call	_nr_to_mask
	ld	r1,GPIO.BTN
	and	r1,r0
	Z clc
	NZ sec
	pop	r1
	pop	pc

	.ends


	.seg	_lib_segment_sw
	
	;; Check pos edge on a switch
	;; Input : R0= number of examined SW (0-15)
	;; Output: C=0 not switched
	;;         C=1 switched off->on
sw_posedge::
	push	lr
	call	_nr_to_mask
	push	r1
	mvzl	r1,0
	sec
	call	_lib_edge_detect
	pop	r1
	pop	pc
;	ret

	
	;; Check switch release
	;; Input : R0= number of examined BTN (0-15)
	;; Output: C=0 not released
	;;         C=1 released
sw_negedge::
	push	lr
	call	_nr_to_mask
	push	r1
	mvzl	r1,1
	sec
	call	_lib_edge_detect
	pop	r1
	pop	pc
;	ret

	
	;; Read actual state of a switch
	;; Input : R0= number of switch (0-15)
	;; Output: C=1 if btn is ON
	;;         C=0 if btn is OFF
sw_get::
	push	lr
	push	r1
	call	_nr_to_mask
	ld	r1,GPIO.SW
	and	r1,r0
	Z clc
	NZ sec
	pop	r1
	pop	pc

	.ends
	
