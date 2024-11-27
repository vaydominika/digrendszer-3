	.proc	p2

	.org	1

main:
	;; setup clock (1ms)
	mvzl	sp,stack
	mvzl	r0,24999
	st	r0,CLOCK.PRE
	;; calc initial period time
	call	fr2pt
	ld	r0,ptime
	st	r0,CLOCK.BCNT2
	;; init line editor
	mvzl	r0,buffer
	mvzl	r1,40
	call	le_init
	;;
	call	prompt
	
	;; main cycle
cycle:
	call	blink		; handle clock events
	call	user_input	; handle user input
	call	btn_press	; handle press of BTN[1]
	jmp	cycle

	
	;; variables
frequ:	.db	5		; frequency [Hz]
ptime:	.db	0		; period time [ms]
buffer:	.ds	40		; user input buffer

	
	;; Calculate period time for given frequency
	;; In : frequ variable in [Hz]
	;; Out: ptime variable in [ms]
	;; ptime= 1000/frequ
fr2pt:
	push	lr
	mvzl	r0,1000
	ld	r1,frequ
	call	div
	st	r4,ptime
	pop	pc
;	ret

	
	;; Blink LED when timer expires
blink:
	push	lr
	;; check clock
	ld	r0,CLOCK.BCNT2	; get back counter
	sz	r0		; check if zero
	NZ jmp	blink_ret	; if not, go out
do_blink:	
	;; expired: blink on LED[0]
	ld	r0,GPIO.LED	; read all LEDs
	xor	r0,1		; negate [0]
	st	r0,GPIO.LED	; show it
	;; restart clock
	ld	r0,ptime	; use calculated period time
	st	r0,CLOCK.BCNT2	; restart back counter
blink_ret:	
	pop	pc
;	ret


	;; Check for user input and handle it
cmd_quit:
	.db	"quit"		; special command to return to monitor

user_input:
	push	lr
	call	le_read		; read line
	NC jmp	ui_ret		; if not ready, go out
process_input:	
	mvzl	r0,10		; echo ENTER
	call	putchar
	mvzl	r0,buffer	; check for word "quit"
	mvzl	r1,cmd_quit
	call	_pm_strieq	; case insensitive compare
	C call	monitor		; if eq, go out to monitor
	C jmp	ui_done		; normal exit when continued
	;; it was not QUIT command,
	;; suppose it is a decimal number
	mvzl	r0,buffer	; convert entered decimal number
	call	dtoi		; to integer value
	cmp	r4,1		; check low limit
	ULT jmp	ui_wrong
	cmp	r4,20		; check high limit
	UGT jmp	ui_wrong
	;; value can be accepted
ui_good:	
	st	r4,frequ	; store as frequ
	call	fr2pt		; calculate new period time
	mvzl	r0,0		; force blink event by expiring counter
	st	r0,CLOCK.BCNT2	; to pick up new value
	jmp	ui_done
ui_wrong:
	mov	r1,r4
	call	_pm_pesf	; print error message
	.db	"%d not in range 1-20\n"
ui_done:	
	call	prompt		; print prompt
	call	le_start	; restart input reader
ui_ret:	
	pop	pc
;	ret


	;; Print prompt
prompt:
	push	lr
	call	_pm_pes
	.db	"Enter fr in Hz (quit to monitor): "
	pop	pc
;	ret


	;; Check for button press and handle it
btn_press:
	push	lr
	mvzl	r0,1		; nr of BTN[1]
	call	btn_posedge	; if pressed
	C call	monitor		; then go out to monitor
	call	btn_restart
	mvzl	r0,0		; nr of SW[0]
	call	sw_posedge
	C call	monitor
	call	sw_restart
	pop	pc
;	ret


	;; STACK
	.ds	99
stack:	.ds	1

