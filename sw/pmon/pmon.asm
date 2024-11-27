	cpu	P2

	version_main	=	1
	version_sub	=	2
	
	IO_BEGIN	=	0xff00
	UART_DR		=	0xff40
	UART_CTRL	=	0xff41
	UART_RSTAT	=	0xff42
	UART_TSTAT	=	0xff43
	UART_CPB	=	0xff44
	UART_QUEUE	=	0xff45
	UART_IRA	=	0xff46
	GPIO_PORTA	=	0xff00
	GPIO_PORTI	=	0xff20
	IO_END		=	0xffff
	
	SIMIF		=	0xffff
	LF		=	10
	CR		=	13
	MAX_WORDS	=	5
	
	org	0
	jmp	cold_start

	org	0xf000
the_begin:
	
_f000:	jmp	callin
_f001:	jmp	enter_by_uart
_f002:	jmp	getchar
_f003:	jmp	version
_f004:	jmp	itobcd
_f005:	jmp	cold_start
_f006:	jmp	strchr
_f007:	jmp	streq
_f008:	jmp	check_uart
_f009:	jmp	hexchar2value
_f00a:	jmp	value2hexchar
_f00b:	jmp	htoi
_f00c:	jmp	strieq
_f00d:	jmp	read
_f00e:	jmp	putchar
_f00f:	jmp	prints
_f010:	jmp	printsnl
_f011:	jmp	print_vhex
_f012:	jmp	pes
_f013:	jmp	printd
_f014:	jmp	printf
_f015:	jmp	pesf
_f016:	jmp	ascii2seg
	
enter_by_uart:
	push	r0
	getf	r0
	push	r0
	ld	r0,UART_RSTAT
	test	r0,1
	jnz	ebu_callin
ebu_return:
	pop	r0
	setf	r0
	pop	r0
	ret
ebu_callin:
	ld	r0,UART_DR
	pop	r0
	setf	r0
	pop	r0
	jmp	callin
	
callin:
	st	r0,reg0
	st	r1,reg1
	st	r2,reg2
	st	r3,reg3
	st	r4,reg4
	st	r5,reg5
	st	r6,reg6
	st	r7,reg7
	st	r8,reg8
	st	r9,reg9
	st	r10,reg10
	st	r11,reg11
	st	r12,reg12
	st	r13,reg13
	st	r14,reg14
	st	r14,reg15
	getf	r0
	st	r0,regf
	mvzl	r0,1
	st	r0,called
	jmp	common_start
hot_start:
	jmp	common_start
def_zero:
	jmp	cold_start
cold_start:
	mvzl	r0,0
	st	r0,called
	mvzl	r0,def_zero	; restore jmp to monitor at zero
	ld	r0,r0
	st	r0,0
	mvzl	r0,0		; def values of some regs
	st	r0,regf		; FALGS= 0
	mvzl	r0,0xf7ff	; R13= 0xf7ff
	st	r0,reg13
	jmp	common_start	
common_start:
	;; Setup STACK, flags
	mvzl	sp,stack_end
	mvzl	r0,1
	st	r0,echo
	mvzl	r0,0
	setf	r0
	
	;; Setup UART
	;mvzl	r1,217
	;st	r1,UART_CPB
	ld	r1,UART_CTRL	; check if transmit is enabled
	test	r1,2
	jz	tr_is_off
wait_uart_tr:
	ld	r1,UART_TSTAT	; if transmit is ongoing
	test	r1,1		; wait it to finish
	jz	wait_uart_tr
tr_is_off:	
	mvzl	r1,3		; turn on rx and tx
	st	r1,UART_CTRL

	;; Print welcome message
	mvzl	r0,LF
	call	putchar
	rds	r0,sver
	mvzl	r1,version_main
	mvzl	r2,version_sub
	getbz	r3,r0,2
	getbz	r4,r0,1
	getbz	r5,r0,0
	mvzl	r0,msg_start
	call	printf
	;; Print addr if called from
	ld	r0,called
	sz	r0
	jz	no_called_from
	mvzl	r0,LF
	call	putchar
	mvzl	r0,msg_stopat
	call	prints
	ld	r0,reg14
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,LF
	call	putchar
no_called_from:	

	;; Setup variables
	call	setup_line
	
	;; Ready to work
;end:	jmp	end
	jmp	main

	
	;; Setup line buffer
	;; -----------------
setup_line:
	push	lr
	mvzl	r1,0		; lptr= 0
	st	r1,line_ptr
	st	r1,line		; line[0]= 0
	mvzl	r1,0		; at_eol= 0
	st	r1,at_eol
	;; print prompt
	mvzl	r0,prompt
	call	prints
	pop	pc
;	ret

	
	;; MAIN cycle
	;; ==========
main:
	call	check_uart
	C0 jmp	no_input
	;; input avail
	call	read
	call	proc_input
	C0 jmp	no_line
	;; line is ready
line_ready:
	call	proc_line
	call	setup_line
no_line:	
no_input:	
	jmp	main


	;; IN: R0 character 
	;; OUT: line, Flag.C=1 line is ready
proc_input:
	push	lr
	cmp	r0,LF
	EQ jmp	got_eol
	cmp	r0,CR
	EQ jmp	got_eol
	cmp	r0,8
	jz	got_BS
	cmp	r0,127
	jz	got_DEL
	jmp	got_char
got_BS:
got_DEL:
	ld	r0,line_ptr
	sz	r0
	jz	got_done
	sub	r0,1
	st	r0,line_ptr
	mvzl	r1,line
	mvzl	r2,0
	st	r2,r1,r0
	mvzl	r0,msg_BS
	call	prints
got_done:
	clc
	jmp	proc_input_ret
got_char:
	cmp	r0,31		; refuse control chars
	LS jmp	proc_input_ret
	cmp	r0,126		; refuse graph chars
	HI jmp	proc_input_ret
	mvzl	r2,0		; at_aol= 0
	st	r2,at_eol
	mvzl	r1,line_ptr	; line[line_ptr]= char
	ld	r3,r1
	mvzl	r2,line
	st	r0,r2,r3
	;; TODO: check line_ptr for overlow
	plus	r3,1		; line_ptr++
	st	r3,r1
	mvzl	r4,0
	st	r4,r3+,r2	; line[line_ptr]= 0
	st	r4,r3,r2	; double 0 at end, needed by tokenizer
	mvzl	r4,echo		; check if echo is turned on
	ld	r4,r4
	sz	r4
	NZ call	putchar		; echo
	clc
	jmp	proc_input_ret
got_eol:	
	mvzl	r1,at_eol
	ld	r1,r1
	sz	r1		; Z=0 at eol -> skip, not ready
	Z0 clc
	Z1 sec
proc_input_ret:	
	pop	pc
;	ret


	;; Process content of line buffer
	;; ------------------------------
	;; IN: -
	;; OUT: -
proc_line:
	push	lr
	;; eol is not echoed, so start with print NL
	mvzl	r0,LF
	call	putchar
	;; check empty line
	ld	r0,line
	sz	r0
	jz	proc_line_ret
	
	;; Simple echo
;	mvzl	r0,sdummy1
;	call	prints
;	mvzl	r0,line
;	call	printsnl

	call	tokenize
	;; DEBUG: print words
;	mvzl	r4,0
;aa1:	mvzl	r5,words
;	ld	r0,r4+,r5
;	push	r4
;	call	printsnl
;	pop	r4
;	cmp	r4,MAX_WORDS
;	NE jmp	aa1

	call	find_cmd
	C0 jmp	cmd_not_found

cmd_found:
	call	r0,0
	
	jmp	proc_line_ret
cmd_not_found:
	mvzl	r0,snotfound
	call	printsnl

proc_line_ret:	
	mvzl	r1,1		; at_eol= 1
	st	r1,at_eol
	pop	pc
;	ret
sdummy1:	db	"Got:"
snotfound:	db	"Unknown command"
	

	;; Check if a character is a delimiter
	;; -----------------------------------
	;; IN: R0 character
	;; OUT: Flag.C=1 if true
is_delimiter:
	push	lr
	mvzl	r1,delimiters
	call	strchr
	pop	pc
;	ret


	;; Tokenize line
	;; -------------
	;; IN: line
	;; OUT: words table
tokenize:
	push	lr
	mvzl	r4,words	; array of result
	mvzl	r5,line		; address of next char
	mvzl	r6,0		; nuof words found
	mvzl	r7,0		; bool in_word
tok_cycle:	
	ld	r0,r5		; pick a char
	sz	r0		; check end
	jz	tok_delimiter	; found end, pretend delim
tok_neol:	
	call	is_delimiter
	C1 jmp	tok_delimiter
tok_char:			; found a non-delimiter
	sz	r7
	jnz	tok_next	; still inside word
	;; delim->word, start of word
	mvzl	r7,1		; in_word=true
	st	r5,r6+,r4	; record word address
	cmp	r6,MAX_WORDS	; If no more space
	EQ jmp	tok_ret		; then return
	jmp	tok_next
tok_delimiter:			; found a non-delimiter
	sz	r7
	jz	tok_next	; still between words
	;; word->delim, end of word
	mvzl	r7,0		; in_word=false
	mvzl	r1,0		; put a 0 at the end of word
	st	r1,r5,r1
tok_next:
	sz	r0		; check EOL
	jz	tok_ret		; jump out if char==0
	add	r5,1
	jmp	tok_cycle
tok_ret:
	mvzl	r1,0
	cmp	r6,MAX_WORDS
	jz	tok_end
	st	r1,r6+,r4
	jmp	tok_ret
tok_end:	
	pop	pc
;	ret

	
	;; Look up command table
	;; IN: first words in tokenized list
	;; OUT: Flag.C=1 if command found
	;;      R0 address of command function, or NULL
find_cmd:
	push	lr
	push	r1
	push	r2
	push	r3
	push	r10
	ld	r0,words	; R0= 1st word of command
	sz	r0
	jz	find_cmd_false

	;; check for RXX first
	ld	r1,r0		; 1st char of word1
	ld	r2,r0,1		; 2nd char
	ld	r3,r0,2		; 3rd char
	and	r1,0xffdf	; upcase 1st char
	cmp	r1,'R'
	jnz	find_not_rx
	cmp	r2,'/'		; '0'-1
	LS jmp	find_not_rx
	cmp	r2,'9'
	HI jmp	find_not_rx
	sz	r3
	jz	find_rx_09
find_rx_1015:	
	cmp	r2,'1'		; first char must be '1'
	jnz	find_not_rx
	cmp	r3,'/'		; '0'-1
	LS jmp	find_not_rx
	cmp	r3,'5'
	HI jmp	find_not_rx
	sub	r3,'0'
	add	r3,10
	st	r3,nuof_reg
	jmp	find_rx
find_rx_09:
	sub	r2,'0'
	st	r2,nuof_reg
find_rx:
	mvzl	r0,cmd_rx
	sec
	jmp	find_cmd_ret
	
find_not_rx:	
	mvzl	r10,commands
find_cmd_cyc:	
	ld	r2,r10		; R2= cmd addr
	sz	r2
	jz	find_cmd_false
	add	r10,1
	mov	r1,r10		; R1= cmd string
	;; step R10 forward to next command in cmd table
find_cmd_fw:
	add	r10,1
	ld	r3,r10
	sz	r3
	jnz	find_cmd_fw
	add	r10,1
	;; now compare word[0] and cmd table item
	call	streq
	C0 jmp	find_cmd_cyc
find_cmd_true:
	mov	r0,r2
	sec
	jmp	find_cmd_ret
c_cmd_name:	db	"//C"
find_cmd_false:
	add	r0,1		; check second word
	ld	r1,r0		; for //C command
	sz	r1
	jz	find_cmd_very_false
	mvzl	r0,c_cmd_name
	call	streq
	jnz	find_cmd_very_false
	mvzl	r2,cmd_c
	jmp	find_cmd_true
find_cmd_very_false:	
	clc
	mvzl	r0,0
find_cmd_ret:
	pop	r10
	pop	r3
	pop	r2
	pop	r1
	pop	pc
;	ret

;;; M ADDR [VALUE]
cmd_m:
	push	lr
	mvzl	r2,words
	mvzl	r0,0
	;ld	r3,r0+,r2	; "m"
	ld	r4,r2,1		; addr
	ld	r5,r2,2		; value
	sz 	r4
	jz	m_ret
	
	mov	r0,r4
	call	htoi
	mov	r4,r1
	C1 jmp	m_addr_ok
	mvzl	r0,m_err_addr
	call	printsnl
	jmp	m_ret
m_addr_ok:
	sz	r5
	jz	m_read
m_write:
	mvzl	r3,the_begin
	cmp	r3,r4
	HI jmp	m_addrv_ok
	mvzl	r3,the_end
	cmp	r3,r4
	HI jmp	m_addrv_nok
	jmp	m_addrv_ok
;	mvzl	r3,IO_BEGIN
;	cmp	r3,r4
;	HI jmp	m_addrv_ok
;	mvzl	r3,IO_END
;	cmp	r4,r3
;	HI jmp	m_addrv_ok
m_addrv_nok:	
	mvzl	r0,m_err_addrv
	call	printsnl
	jmp	m_ret
m_addrv_ok:
	mov	r0,r5
	call	htoi
	mov	r5,r1
	C1 jmp	m_value_ok
	mvzl	r0,m_err_value
	call	printsnl
	jmp	m_ret
m_value_ok:
	st	r5,r4
	;jmp	m_ret
m_read:
	mov	r0,r4
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,0x20
	call	putchar
	ld	r0,r4
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,LF
	call	putchar
m_ret:
	pop	pc
;	ret
m_err_addr:	db	"Address error"
m_err_addrv:	db	"Monitor's address"
m_err_value:	db	"Value error"

	
;;; SM ADDR VALUE
cmd_sm:
	push	lr
	mvzl	r2,words
	mvzl	r0,0
	;ld	r3,r0+,r2	; "m"
	ld	r4,r2,1		; addr
	ld	r5,r2,2		; value
	sz 	r4
	jz	m_ret
	
	mov	r0,r4
	call	htoi
	mov	r4,r1
	C1 jmp	sm_addr_ok
	mvzl	r0,m_err_addr
	call	printsnl
	jmp	sm_ret
sm_addr_ok:
	sz	r5
	jz	sm_ret
sm_write:
	mvzl	r3,the_begin
	cmp	r3,r4
	HI jmp	sm_addrv_ok
	mvzl	r3,the_end
	cmp	r3,r4
	HI jmp	sm_addrv_nok
	jmp	sm_addrv_ok
sm_addrv_nok:	
	mvzl	r0,m_err_addrv
	call	printsnl
	jmp	sm_ret
sm_addrv_ok:
	mov	r0,r5
	call	htoi
	mov	r5,r1
	C1 jmp	sm_value_ok
	mvzl	r0,m_err_value
	call	printsnl
	jmp	sm_ret
sm_value_ok:
	st	r5,r4
	;jmp	m_ret
sm_ret:
	pop	pc
;	ret


;;; D start end
cmd_d:
	push	lr
	mvzl	r2,words
	ld	r0,r2,1		; start address
	call	htoi
	mov	r3,r1
	ld	r0,r2,2		; end address
	sz	r0
	jnz	d_end_ok
	mov	r4,r3
	add	r4,0x10
	jmp	d_chk_end
d_end_ok:
	call	htoi
	mov	r4,r1
d_chk_end:	
	cmp	r3,r4		; check if start>end
	HI jmp d_bad
;	mov	r2,r4		; check end-start
;	sub	r2,r3
;	cmp	r2,100		; max 100 line...
;	LS jmp	d_cyc
;	mov	r4,r3
;	add	r4,100
d_cyc:
	mov	r0,r3		; print address
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,0x20		; print one space
	call	putchar
	ld	r0,r3		; load data
	mvzl	r1,4		; print data
	call	print_vhex
	mvzl	r0,LF		; print new line
	call	putchar
	cmp	r3,r4
	jz	d_ret
	add	r3,1
	jmp	d_cyc
d_bad:
	mvzl	r0,d_err_bad
	call	printsnl
d_ret:	
	pop	pc
;	ret
d_err_bad:	db	"Wrong end address"

	
;;; VALUE //C ADDR
cmd_c:
	ret

	
;;; L load command with own cycle
cmd_l:
	push	lr
	mvzl	r10,0		; state (nr of words)
	mvzl	r8,0		; value
	mvzl	r6,'?'		; Record type
	mvzl	r12,0		; Checksum
l_cyc:
	call	check_uart
	C0 jmp	l_cyc
	call	read
l_start:	
	mov	r11,r0		; Copy of char in R11
	cmp	r0,10		; check EOL chars
	jz	l_eol
	cmp	r0,13
	jz	l_eol
	
	cmp	r10,0
	jnz	l_no0
l_state_0:
	call	hexchar2value
	C0 jmp	l_eof_0
	shl	r8		; shift val(char) into value
	shl	r8
	shl	r8
	shl	r8
	btst	r0,0xf
	or	r8,r0
	jmp	l_cyc
l_eof_0:
	mvzl	r10,1		; state0 -> state1
	mvzl	r6,'?'		; No //C yet
	cmp	r11,'/'		; is it start of //
	z1 mvzl	r7,1		; Yes, first / found
	z0 mvzl	r7,0		; No '/' yet
	jmp	l_cyc

l_no0:
	cmp	r10,1
	jnz	l_no1
l_state_1:
	sz	r7
	jnz	l_s1_2nd
l_s1_1st:	
	cmp	r0,'/'
	jnz	l_cyc
	mvzl	r7,1
	jmp	l_cyc
l_s1_2nd:
	cmp	r0,'/'
	jz	l_cyc
	cmp	r0,'C'
	jz	l_s1_C
	cmp	r0,'I'
	jnz	l_s1_noC
l_s1_C:
;	mvzl	r6,'C'
	mov	r6,r0		; record type is in r0, store in r6
	;; state1 -> state2
	mvzl	r10,2
	mvzl	r9,0		; address= 0
	mvzl	r5,0		; where we are in word: before
	jmp	l_cyc
l_s1_noC:	
	cmp	r0,'E'
	jnz	l_s1_noE
l_s1_E:
	mvzl	r6,'E'
	;; state1 -> state3
	mvzl	r10,3
	jmp	l_cyc
l_s1_noE:
	;; we found a record that can be skipped
				;
	call	putchar		; print record type
	mvzl	r10,0xf		; special state: skip everything
	jmp	l_cyc

l_no1:
	cmp	r10,2
	jnz	l_no2
l_state_2:
	cmp	r5,0
	jnz	l_s2_no0
l_s2_0:	
	call	hexchar2value
	C0 jmp	l_cyc
	mvzl	r5,1
l_s2_got:
	shl	r9
	shl	r9
	shl	r9
	shl	r9
	btst	r0,0xf
	or	r9,r0
l_s2_eos:	
	jmp	l_cyc
l_s2_no0:
	cmp	r5,1
	jnz	l_s2_no1
l_s2_1:
	call	hexchar2value
	C1 jmp	l_s2_got
	mvzl	r5,2
	jmp	l_cyc
l_s2_no1:
	jmp	l_cyc
l_no2:
	cmp	r10,3
	jnz	l_no3
l_state_3:
	jmp	l_cyc		; do nothing, just wait EOL
	
l_no3:
	cmp	r10,0xf
	jmp	l_nof
	jmp	l_cyc		; just skip
	
l_nof:
	jmp	l_cyc
	jmp	l_ret

	;; Process eol
l_eol:
	cmp	r10,0		; in state0
	jz	l_back_to_0	; just restart
	cmp	r10,1		; in state1
	jz	l_back_to_0 	;l_cyc ;l_bad ; garbage
	cmp	r10,2		; in state2
	jz	l_proc		; process record
	cmp	r10,3		; in state3
	jz	l_ret		; eol in end record: finish
	cmp	r10,0xf		; in state skip
	jz	l_back_to_0	; reset state for new line
	jmp	l_cyc
l_bad:
	jmp	l_ret
l_proc:
	cmp	r6,'C'		; is it a C or I record?
	z st	r8,r9		; then store
	z add	r12,r8		; and add to checksum
	cmp	r6,'I'
	z st	r8,r9
	z add	r12,r8
	mov	r0,r6		; echo record type
	call	putchar
l_back_to_0:	
	;; back to state0
	;mvzl	r0,'.'
	;call	putchar
	mvzl	r10,0
	mvzl	r8,0
	mvzl	r6,'?'
	jmp	l_cyc
l_ret:
	mvzl	r0,LF
	call	putchar
	;; print out checksum
	mov	r0,r12
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,LF
	call	putchar
	pop	pc
;	ret


;;; G [ADDRESS]
cmd_g:
	push	lr
	mvzl	r2,words
	ld	r0,r2,1		; address
	sz	r0
	jz	g_no_addr
	call	htoi
	mov	r11,r1
g_go11:	
	mvzl	r0,d_msg_run
	call	prints
	mov	r0,r11
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,LF
	call	putchar
	st	r11,reg15
g_go:	
	mvzl	r2,UART_TSTAT
g_wait_tc:
	ld	r9,r2
	test	r9,1
	jz	g_wait_tc

	ld	r0,0
	st	r0,called
	
	ld	r0,regf
	setf	r0
	ld	r0,reg0
	ld	r1,reg1
	ld	r2,reg2
	ld	r3,reg3
	ld	r4,reg4
	ld	r5,reg5
	ld	r6,reg6
	ld	r7,reg7
	ld	r8,reg8
	ld	r9,reg9
	ld	r10,reg10
	ld	r11,reg11
	ld	r12,reg12
	ld	r13,reg13
	ld	r14,reg14

	ld	r15,reg15
	
g_no_addr:
	ld	r0,called
	sz	r0
	jz	g_err
	ld	r11,reg15
	jmp	g_go11
g_err:	
	mvzl	r0,g_err_addr
	call	printsnl
g_ret:	
	pop	pc
;	ret
g_err_addr:	db	"No address"
d_msg_run:	db	"Run "
	

;;; H(elp)
cmd_h:
	push	lr
	mvzl	r2,helps
	mvzl	r3,0
h_cyc:
	ld	r0,r3+,r2	; pick a char
	sz	r0		; is it eos?
	jnz	h_print
h_eos:
	;add	r3,1		; at eos: go to next string
	ld	r0,r3+,r2	; get first char of next string
	sz	r0
	jz	h_eof
h_print:
	call	putchar
	jmp	h_cyc
h_eof:	
	pop	pc
;	ret


	;; In: R0 reg number
print_reg_name:
	push	lr
	push	r1
	mov	r1,r0
	cmp	r1,16		; go out if nr>16
	HI jmp	prn_ret
	cmp	r1,15		; nr=Flag?
	LS jmp	prn_015
prn_16:
	mvzl	r0,'F'
	call	putchar
	mvzl	r0,32
	call	putchar
	call	putchar
	jmp	prn_ret
prn_015:
	cmp	r1,15
	jnz	prn_no15
	mvzl	r0,prn_PC
	call	prints
	jmp	prn_ret
prn_PC:	db	"PC "
prn_no15:
	cmp	r1,14
	jnz	prn_no14
	mvzl	r0,prn_LR
	call	prints
	jmp	prn_ret
prn_LR:	db	"LR "
prn_no14:
	cmp	r1,13
	jnz	prn_no13
	mvzl	r0,prn_SP
	call	prints
	jmp	prn_ret
prn_SP:	db	"SP "
prn_no13:	
	mvzl	r0,'R'
	call	putchar	
	cmp	r1,9
	HI jmp	prn_1015
prn_09:	
	mov	r0,r1
	add	r0,'0'
	call	putchar
	mvzl	r0,32
	call	putchar
	jmp	prn_ret
prn_1015:
	mvzl	r0,'1'
	call	putchar
	mov	r0,r1
	sub	r0,10
	add	r0,'0'
	call	putchar
prn_ret:	
	pop	r1
	pop	pc
;	ret
	
	;; In: R0 reg number 0..16
print_reg_value:
	push	lr
	push	r1
	cmp	r0,16
	HI jmp	prv_ret
	mvzl	r1,reg0
	ld	r0,r1,r0
	mvzl	r1,4
	call	print_vhex
prv_ret:
	pop	r1
	pop	pc
;	ret


	;; Print register name and value and NL
	;; In: r10: register number
print_reg_name_value:
	push	lr
	push	r10
	push	r0
	mov	r0,r10
	call	print_reg_name
	mvzl	r0,32
	call	putchar
	mov	r0,r10
	call	print_reg_value
	mvzl	r0,LF
	call	putchar
	pop	r0
	pop	r10
	pop	pc
;	ret
	
	;; IN: R0 flag name char
	;;     R1 flag values
	;;     R2 mask
	;;     R3 last char to print
print_flag:
	push	lr
	call	putchar
	test	r1,r2
	NZ mvzl r0,'1'
	Z  mvzl r0,'0'
	call	putchar
	mov	r0,r3
	call	putchar
	pop	pc
;	ret
	
;;; R(eg)
cmd_r:
	push	lr
	ld	r0,called
	sz	r0
	jz	r_not_called
r_called:
	mvzl	r0,msg_r_called
	call	prints
	ld	r0,reg15
	mvzl	r1,4
	call	print_vhex
	mvzl	r0,LF
	call	putchar
	jmp	r_start
r_not_called:
	mvzl	r0,msg_r_notcalled
	call	prints
r_start:	
	mvzl	r10,0
r_cyc:
	call	print_reg_name_value
	add	r10,1
	cmp	r10,17
	jnz	r_cyc
r_flags:
	ld	r1,regf
	mvzl	r3,32
	mvzl	r0,'U'
	mvzl	r2,0x20
	call	print_flag
	mvzl	r0,'P'
	mvzl	r2,0x10
	call	print_flag
	mvzl	r0,'O'
	mvzl	r2,8
	call	print_flag
	mvzl	r0,'Z'
	mvzl	r2,4
	call	print_flag
	mvzl	r0,'C'
	mvzl	r2,2
	call	print_flag
	mvzl	r0,'S'
	mvzl	r2,1
	mvzl	r3,LF
	call	print_flag
	pop	pc
;	ret
msg_r_called:		db	"Monitor called from: "
msg_r_notcalled:	db	"Monitor not called by user\n"

;;; Rx [value]
;;; In: 
cmd_rx:	
	push	lr
	ld	r10,nuof_reg	; Reg num is in R10
	cmp	r10,16
	LS jmp	rx_nr_ok
	mvzl	r0,rx_err_nr
	call	printsnl
	jmp	rx_ret
rx_err_nr:
	db	"No such register"
rx_nr_ok:	
	mvzl	r2,words
	ld	r4,r2,1		; get aof first parameter
	sz	r4		; is it NULL?
	jz	rx_print
	mov	r0,r4
	call	htoi
	mov	r5,r1		; Value is in R5
	C1 jmp	rx_val_ok
	mvzl	r0,rx_err_val
	call	printsnl
	jmp	rx_ret
rx_err_val:
	db	"Value error"
rx_val_ok:
	cmp	r10,16		; Flag reg?
	EQ and	r5,0x3f
	mvzl	r0,reg0
	st	r5,r0,r10
rx_print:
	call	print_reg_name_value
rx_ret:	
	pop	pc
;	ret


;;; SP [value]
cmd_sp:
	mvzl	r0,13
	st	r0,nuof_reg
	jmp	cmd_rx

	
;;; LR [value]
cmd_lr:
	mvzl	r0,14
	st	r0,nuof_reg
	jmp	cmd_rx

	
;;; PC [value]
cmd_pc:
	mvzl	r0,15
	st	r0,nuof_reg
	jmp	cmd_rx

	
;;; F [value]
cmd_f:
	mvzl	r0,16
	st	r0,nuof_reg
	jmp	cmd_rx

	
;;; STRING UTILITIES
;;; ==================================================================

	;; locate charater in string
	;; IN: R0 character, R1 string address
	;; OUT: R1 address of char found, or NULL, Flag.C=1 if found
	;;      R2 byte index in the word
strchr:
	;push	r1
	;push	r2
	push	r3
	push	r4
strchr_cyc:
	mvzl	r2,0		; byte index re-start
	ld	r3,r1		; get next word
	sz	r3		; check for eof
	jz	strchr_no	; eof string found
strchr_go:	
	getbz	r4,r3,r2	; pick a byte
	sz	r4		; is it zero?
	jz	strchr_word	; if yes, pick next word
	cmp	r4,r0		; compare
	jz	strchr_yes	; found it
strchr_byte:
	inc	r2		; advance byte index
	cmp	r2,4		; check byte overflow
	jnz	strchr_go	; no, overflow, go on
strchr_word:			; overflow
	plus	r1,1		; go to next char
	jmp	strchr_cyc
strchr_yes:
	sec
	jmp	strchr_ret
strchr_no:
	mvzl	r1,0
	clc
strchr_ret:
	pop	r4
	pop	r3
	;pop	r2
	;pop	r1
	ret


	;; Check if strings are equal
	;; --------------------------
	;; IN: R0, R1 addresses of strings
	;;     R3==true case sensitive
	;;     R3==false case insensitive
	;; OUT: Flag.C=1 equal
	;;      R1 address of EOS in second string
str_cmp_eq:
	push	lr		; Save used registers
	push	r0		; and input parameters
	;push	r1
	push	r2
	push	r4
	push	r5
	push	r6
	push	r7		; byte idx in string 1
	push	r8		; byte idx in string 2
	mvzl	r7,0
	mvzl	r8,0
streq_cyc:	
	ld	r2,r0		; Got one char from first str
	sz	r2		; is it eos?
	jz	streq_pick2	; if yes, go on
	getbz	r2,r2,r7	; pick one byte
	sz	r2		; is it 0?
	jnz	streq_pick2	; if not, go on
	inc	r7		; step to next byte
	cmp	r7,4		; word is overflowed?
	jz	streq_p1ov
streq_p1nov:
	ld	r2,r0		; pick orig word, and
	getbz	r2,r2,r7	; check next byte
	sz	r2		; is it 0?
	jnz	streq_pick2	; if not, go on
streq_p1ov:	
	inc	r0		; if yes, move pointer
	mvzl	r7,0		; and reset byte counter
	ld	r2,r0		; get first byte of next word
	getbz	r2,r2,r7

streq_pick2:	
	ld	r6,r1		; pick from second string
	sz	r6		; is it eos?
	jz	streq_prep	; if yes, go to compare
	getbz	r6,r6,r8	; pick a byte
	sz	r6		; is it 0?
	jnz	streq_prep	; if not, go to compare
	inc	r8		; step to next byte
	cmp	r8,4		; is word overflowed?
	jz	streq_p2ov
streq_p2nov:
	ld	r6,r1		; pick orig word, and
	getbz	r6,r6,r8	; check next byte
	sz	r6		; is it 0?
	jnz	streq_prep	; if not, go on
streq_p2ov:
	inc	r1		; if yes, move pointer
	mvzl	r8,0		; and reset byte counter
	ld	r6,r1		; get next word
	getbz	r6,r6,r8	; and pick first byte

streq_prep:	
	sz	r3		; Prepare for comparing
	Z1 or	r2,0x20		; if insensitive case
	sz	r3
	Z1 or	r6,0x20
	cmp	r2,r6		; compare them
	jnz	streq_no	; if differs: strings are not equal

	ld	r2,r0		; Pick original (non-prepared)
	ld	r6,r1		; chars to check EOS
	getbz	r2,r2,r7
	getbz	r6,r6,r8
	sz	r2		; convert them to boolean
	Z0 mvzl	r2,1		; values in R2,R6
	Z1 mvzl	r2,0		; and copy in R4,R5
	mov	r4,r2
	sz	r6
	Z0 mvzl	r6,1
	Z1 mvzl r6,0
	mov	r5,r6
	or	r4,r5		; if both are EOS: equal
	jz	streq_yes
	and 	r2,r6		; just one is EOS: not equal
	jz	streq_no
				; non are EOS: go to check next char
streq_next:				
	inc	r7		; step byte count
	cmp	r7,4		; if word overflows
	Z plus	r0,1		; then step the pointer
	Z mvzl	r7,0		; and reset the byte counter

	inc	r8
	cmp	r8,4
	Z plus	r1,1
	Z mvzl	r8,0
	jmp	streq_cyc
	
streq_no:
	clc			; False result
	jmp	streq_ret

streq_yes:
	sec			; True result
	
streq_ret:
	ld	r6,r1		; forward R1 to EOS
	sz	r6
	jz	streq_ret_ret
	inc	r1
	jmp	streq_ret
streq_ret_ret:
	pop	r8
	pop	r7
	pop	r6
	pop	r5
	pop	r4
	pop	r2
	;pop	r1
	pop	r0
	pop	pc
;	ret
	

	;; Compare strings case sensitive way
	;; IN: R0, R1 addresses of strings
	;; OUT Flag.C==1 if equals
streq:
	push	lr
	push	r1
	push	r3
	mvzl	r3,1
	call	str_cmp_eq
	pop	r3
	pop	r1
	pop	pc
;	ret

	
	;; Compare strings case insensitive way
	;; IN: R0, R1 addresses of strings
	;; OUT Flag.C==1 if equals
strieq:
	push	lr
	push	r1
	push	r3
	mvzl	r3,0
	call	str_cmp_eq
	pop	r3
	pop	r1
	pop	pc
;	ret


	;; Convert one hex char to value
	;; IN: R0 char
	;; OUT: R0 value
	;;      Flag.C=1 valid char
hexchar2value:
	cmp	r0,'/'
	LS jmp	hc2v_nok
	cmp	r0,'9'
	LS jmp	hc2v_0_9
	cmp	r0,'@'
	LS jmp	hc2v_nok
	cmp	r0,'F'
	LS jmp	hc2v_A_F
	cmp	r0,'`'
	LS jmp	hc2v_nok
	cmp	r0,'f'
	LS jmp	hc2v_a_f
	jmp	hc2v_nok
hc2v_a_f:
	add	r0,10
	sub	r0,'a'
	jmp	hc2v_ok
hc2v_A_F:
	add	r0,10
	sub	r0,'A'
	jmp	hc2v_ok
hc2v_0_9:
	sub	r0,'0'
hc2v_ok:
	sec
	ret
hc2v_nok:	
	clc
	ret

	
value2Hexchar:
	push	r1
	and	r0,0xf
	mvzl	r1,v2hc_table
	ld	r0,r1,r0
	pop	r1
	ret
v2hc_table:	db	"0123456789ABCDEF"

value2hexchar:
	push	lr
	call	value2Hexchar
	or	r0,0x20
	pop	pc
;	ret

	
	;; Convert string to number (hexadecimal)
	;; IN: R0 addr of string
	;; OUT: R1 value
	;;      Flag.C=1 success
htoi:
	push	lr
	push	r2
	push	r3
	push	r4
	push	r5
	mvzl	r1,0		; return value
	mvzl	r3,0		; index
htoi_cyc:
	mvzl	r5,0
	ld	r4,r3+,r0	; pick a char
	sz	r4		; check eof string
	jz	htoi_eos
htoi_byte:
	getbz	r2,r4,r5
	sz	r2
	jz	htoi_cyc
	cmp	r2,'.'		; skip separators
	jz	htoi_next
	cmp	r2,'_'
	jz	htoi_next
	cmp	r2,'-'
	jz	htoi_next
	push	r0
	mov	r0,r2
	call	hexchar2value
	mov	r2,r0
	pop	r0
	C0 jmp	htoi_nok
	shl	r1
	shl	r1
	shl	r1
	shl	r1
	and	r2,0xf
	or	r1,r2
htoi_next:
	inc	r5
	cmp	r5,4
	jz	htoi_cyc
	jmp	htoi_byte
htoi_nok:
	clc
	jmp	htoi_ret
htoi_eos:
	cmp	r3,1
	HI clc
	LS sec
htoi_ret:
	pop	r5
	pop	r4
	pop	r3
	pop	r2
	pop	pc
;	ret
	
	
;;; SERIAL IO
;;; ==================================================================
	
	;; Check UART for input available
	;; ------------------------------
	;; IN: -
	;; OUT: Flag.C=1 input avail
check_uart:
	push	r0
	ld	r0,UART_RSTAT
	; Z=1: nochar Z=0: input avail
	test	r0,1		; check if queue is not empty
	clc
	Z0 sec
	pop	r0
	C1 ret
	ret
	
;; 	push	r0
;; 	push	r1
;; 	push	r2
;; 	ld	r0,sc_active
;; 	sz	r0
;; 	jnz	check_uart_ret_true
;; 	ld	r0,GPIO_PORTI
;; 	btst	r0,1
;; 	ld	r1,prev_porti
;; 	btst	r1,1
;; 	cmp	r0,r1
;; 	EQ jmp	check_uart_ret_false
;; 	st	r0,prev_porti
;; 	btst	r0,1
;; 	jz	check_uart_ret_false
;; 	;; rising edge on PORTI.0
;; 	mvzl	r2,0
;; 	mvzl	r0,1
;; 	st	r0,sc_active
;; 	mvzl	r0,sc_buffer
;; 	st	r0,sc_ptr
;; 	mvzl	r1,'h'
;; 	st	r1,r0+,r2
;; 	mvzl	r1,CR
;; 	st	r1,r0+,r2
;; 	mvzl	r1,0
;; 	st	r1,r0+,r2
;; check_uart_ret_true:	
;; 	sec
;; 	jmp	check_uart_ret
;; check_uart_ret_false:
;; 	clc
;; check_uart_ret:
;; 	pop	r2
;; 	pop	r1
;; 	pop	r0
;; 	ret
;; prev_porti:
;; 	db	0
	
	;; IN: -
	;; OUT: R0
read:
	ld	r0,UART_DR
	st	r0,UART_IRA
	ret
	
;; 	push	r1
;; 	push	r2
;; 	ld	r1,sc_active
;; 	sz	r1
;; 	jz	read_uart
;; read_sc:	
;; 	ld	r1,sc_ptr
;; 	ld	r0,r1
;; 	add	r1,1
;; 	st	r1,sc_ptr
;; 	ld	r2,r1
;; 	sz	r2
;; 	jnz	read_sc_ret
;; 	;mvzl	r2,0
;; 	st	r2,sc_active
;; 	jmp	read_sc_ret
;; read_uart:	
;; 	ld	r0,UART_DR
;; read_sc_ret:	
;; 	pop	r2
;; 	pop	r1
;; 	ret

	
	;; Wait and read one character
	;; ---------------------------
	;; IN: -
	;; OUT: F.C=1
	;;      r0 character
getchar:
	call	check_uart
	C0 jmp	getchar
	call	read
	ret
	
	
	;; Send one character
	;; ------------------
	;; IN: r0
	;; OUT: -
putchar:
	push	r9
;	mvzl	r9,'p'
;	st	r9,SIMIF
;	st	r0,SIMIF
	;st	r0,GPIO_PORTA
	;jmp	putchar_ret
wait_tc:
	ld	r9,UART_TSTAT
	test	r9,1
	jz	wait_tc
	st	r0,UART_DR
putchar_ret:
	pop	r9
	ret

	
	;; Print string
	;; ------------
	;; IN: R0 address of string
	;; OUT: -
prints:
	push	lr
	push	r0
	push	r3
	push	r4
	push	r2
	push	r1
	push	r5
	
	mvzl	r4,0
	sz	r0
	Z1 mvzl	r0,null_str
	mov	r2,r0
prints_go:
	ld	r1,r4+,r2
	sz	r1
	mvzl	r5,0
	jz	prints_done
prints_byte:
	getbz	r0,r1,r5
	sz	r0
	NZ call	putchar
	jz 	prints_go
	inc	r5
	cmp	r5,4
	jnz	prints_byte
	jmp	prints_go
	
prints_done:
	pop	r5
	pop	r1
	pop	r2
	pop	r4
	pop	r3
	pop	r0
	pop	pc
;	ret


	;; Print embedded string, return after
	;; -----------------------------------
	;; IN : - 
	;; OUT: -
pes_ret_to:	dd	0
	
pes:
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3
	mov	r1,lr
pes_next:
	ld	r2,r1
	inc	r1
	sz	r2
	jz	pes_done
	mvzl	r3,0
pes_byte:
	getbz	r0,r2,r3
	sz	r0
	NZ call	putchar
	jz	pes_next
	inc	r3
	cmp	r3,4
	jnz	pes_byte
	jmp	pes_next
pes_done:
	st	r1,pes_ret_to
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	lr
	ld	pc,pes_ret_to


	;; Print string and append a NL
	;; ----------------------------
	;; IN : R0 address of string
	;; OUT: -
printsnl:
	push	lr
	call	prints
	push	r0
	mvzl	r0,LF
	call	putchar
	pop	r0
	pop	pc
;	ret


	;; Print a value in hex format
	;; IN: R0 value
	;;     R1 nr char between .
print_vhex:
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3
	push	r4
	mov	r3,r0
	mvzl	r2,0
	mvzl	r4,1

print_vhex_cyc:	
	mvzl	r0,0
	shl	r3
	rol	r0
	shl	r3
	rol	r0
	shl	r3
	rol	r0
	shl	r3
	rol	r0
	call	value2Hexchar
	call	putchar
	add	r2,1
	cmp	r2,8
	jz	print_vhex_ret
	sz	r1
	jz	print_vhex_nosep
	cmp	r4,r1
	jnz	print_vhex_nosep
	mvzl	r0,'_'
	call	putchar
	mvzl	r4,0
print_vhex_nosep:
	add	r4,1
	jmp	print_vhex_cyc
print_vhex_ret:	
	pop	r4
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	pc
;	ret


	;; Divide Q,R= N/D
	;; IN:  R0= N, R1= D
	;; OUT: R2= Q, R3= R
div:
	push	lr
	push	r4
	
	sz	r1
	NZ jmp	div_dok
	mov	r2,r0		; div by zero
	mvzl	r3,0
	jmp	div_ret
div_dok:
	mvzl	r2,0		; Q= 0
	mvzl	r3,0		; R= 0
	mvh	r4,0x80000000	; m= 1<<31
	mvl	r4,0x80000000
div_cyc:
	sz	r4
	Z jmp	div_ret
	shl	r3		; r<<= 1
	test	r0,r4		; if (n&m)
	NZ or	r3,1		; r|= 1
	cmp	r3,r1		; if (r>=d)
	LO jmp	div_cyc_next
	sub	r3,r1		;r-= d
	or	r2,r4		;q|= m
	jmp	div_cyc_next
	jmp	div_cyc
div_cyc_next:
	shr	r4		; m>>= 1
	jmp	div_cyc
div_ret:
	pop	r4
	pop	pc
;	ret


	;; itoa
	;; IN:  R0
	;; OUT: string in itoa_buffer
itoa:
	push	lr
	push	r0
	push	r1
	push	r2
	push	r3
	push	r10
	push	r11
	push	r12

	mvzl	r12,itoa_buffer	; pointer to output buffer
	mvzl	r11,itoa_divs	; pointer to dividers
	mvzl	r10,0		; bool: first non-zero char found
itoa_cyc:	
	ld	r1,r11		; get next divider
	sz	r1		; if 0, then
	jz	itoa_ret	; finish
	cmp	r1,1		; last divider?
	EQ mvzl	r10,1		; always print last char
	call	div		; R2,R3= R0/R1
	sz	r2		; is the result zero?
	jz	itoa_f0
itoa_fno0:
	mvzl	r10,1		; non-zero: start to print
itoa_store:
	mov	r0,r2		; convert result to ASCII char
	call	value2hexchar
	st	r0,r12		; and store it in buffer
	inc	r12		; inc buf ptr
	mvzl	r0,0		; put 0 after last char
	st	r0,r12
itoa_next:
	mov	r0,r3		; continue with the reminder
	inc	r11		; and next divider
	jmp	itoa_cyc
itoa_f0:
	sz	r10		; just zeros so far?
	jnz	itoa_store	; no, print
	jmp	itoa_next
itoa_ret:
	pop	r12
	pop	r11
	pop	r10
	pop	r3
	pop	r2
	pop	r1
	pop	r0
	pop	pc
;	ret
itoa_buffer:	ds	11
itoa_divs:
	dd	1000000000
	dd	 100000000
	dd	  10000000
	dd	   1000000
	dd	    100000
	dd	     10000
	dd	      1000
	dd	       100
	dd	        10
	dd	         1
	dd	0
	

	;; Convert number to BCD
	;; In : R0
	;; Out: R0
itobcd:
	push	lr
	push	r1
	push	r2
	cmp	r0,99999999
	UGT jmp	itobcd_bad
	call	itoa
	mvzl	r0,0
	mvzl	r1,itoa_buffer
itobcd_cyc:
	ld	r2,r1
	sz	r2
	jz	itobcd_ret
	sub	r2,'0'
	shl	r0
	shl	r0
	shl	r0
	shl	r0
	or	r0,r2
	inc	r1
	jmp	itobcd_cyc
itobcd_bad:
	mvzl	r0,0
itobcd_ret:
	pop	r2
	pop	r1
	pop	pc

	
	;; Print number in decimal
	;; In : R0
	;; Out: -
printd:
	push	lr
	call	itoa
	mvzl	r0,itoa_buffer
	call	prints
	pop	pc
;	ret


	;; Format and print string
	;; In : R0 address of string template (format)
	;;      R1..R12 parameter values
	;; Out: R2 pointer to end of string (address of zero byte)
printf:
	push	lr
	push	r0
	push	r1
	push	r3
	
	st	r1,reg1
	st	r2,reg2
	st	r3,reg3
	st	r4,reg4
	st	r5,reg5
	st	r6,reg6
	st	r7,reg7
	st	r8,reg8
	st	r9,reg9
	st	r10,reg10
	st	r11,reg11
	st	r12,reg12

	mov	r2,r0		; pointer to format string
	mvzl	r1,reg1		; pointer to params
	mvzl	r3,0		; byte idx in packed str
printf_cyc:
	ld	r0,r2		; get next char
	sz	r0		; is it EOS?
	jz	printf_ret
	getbz	r0,r0,r3	; pick next byte
	sz	r0		; is it null?
	jz	printf_nextword	; no more non-nulls

	cmp	r0,'\\'
	jnz	printf_notescape

	inc	r3
	cmp	r3,4
	jnz	printf_l1
printf_l2:
	mvzl	r3,0
	inc	r2
	ld	r0,r2
	sz	r0
	jz	printf_ret
printf_l1:
	ld	r0,r2
	getbz	r0,r0,r3
	sz	r0
	jz	printf_l2
	
	cmp	r0,'a'
	Z mvzl	r0,7
	Z jmp	printf_print
	cmp	r0,'b'
	Z mvzl	r0,8
	Z jmp	printf_print
	cmp	r0,'e'
	Z mvzl	r0,0x1b
	Z jmp	printf_print
	cmp	r0,'f'
	Z mvzl	r0,0xc
	Z jmp	printf_print
	cmp	r0,'n'
	Z mvzl	r0,0xa
	Z jmp	printf_print
	cmp	r0,'r'
	Z mvzl	r0,0xd
	Z jmp	printf_print
	cmp	r0,'t'
	Z mvzl	r0,9
	Z jmp	printf_print
	cmp	r0,'v'
	Z mvzl	r0,0xb
	Z jmp	printf_print
	cmp	r0,0x5c
	Z jmp	printf_print
	cmp	r0,'0'
	Z mvzl	r0,0
	Z jmp	printf_print
	
	jmp	printf_print
	
printf_notescape:	
	cmp	r0,'%'		; is it a format char?
	jnz	printf_print

	inc	r3
	cmp	r3,4
	jnz	printf_l3
printf_l4:
	mvzl	r3,0
	inc	r2		; go to format char
	ld	r0,r2
	sz	r2		; is it EOS?
	jz	printf_ret
printf_l3:
	ld	r0,r2
	getbz	r0,r0,r3
	sz	r0
	jz	printf_l4
	
	cmp	r0,'%'		; % is used to print %
	jz	printf_print

	cmp	r0,'u'		; u,d print in decimal
	jz	printf_d
	cmp	r0,'d'
	jnz	printf_notd
printf_d:
	ld	r0,r1
	inc	r1
	call	printd
	jmp	printf_next
	
printf_notd:
	cmp	r0,'x'
	jnz	printf_notx
printf_x:
	ld	r0,r1
	inc	r1
	push	r1
	mvzl	r1,0
	call	print_vhex
	pop	r1
	jmp	printf_next
	
printf_notx:
	cmp	r0,'s'
	jnz	printf_nots
printf_s:
	ld	r0,r1
	inc	r1
	call	prints
	jmp	printf_next
	
printf_nots:
	cmp	r0,'c'
	jnz	printf_notc
	ld	r0,r1
	inc	r1
	call	putchar
	jmp	printf_next
	
printf_notc:	
	jmp	printf_next
printf_print:
	call	putchar		; print actual char
printf_next:
	inc	r3		; next byte in word
	cmp	r3,4		; all 4 processed?
	jnz	printf_cyc
printf_nextword:
	inc	r2		; inc string ptr
	mvzl	r3,0		; restart byte idx
	jmp	printf_cyc
	
printf_ret:
	pop	r3
	pop	r1
	pop	r0
	pop	pc
;	ret


pesf:
	push	r0
	push	r2
	mov	r0,LR
	call	printf
	inc	r2
	st	r2,reg2
	pop	r2
	pop	r0
	ld	PC,reg2


version:
	push	r1
	mvzl	r0,version_sub
	mvzl	r1,version_main
	putb	r0,r1,1
	pop	r1
	ret
	

	;; In : R0 ascii
	;; Out: R4 segments
ascii2seg:
	push	r0
	push	r1
	shr	r0
	shr	r0
	mvzl	r1,ascii2seg_table
	ld	r4,r0,r1
	pop	r1
	pop	r0
	getbz	r4,r4,r0
	ret
	
	
;;; VARIABLES
;;; ---------
line:		ds	100		; line buffer
line_ptr:	ds	1		; line pointer (index)
at_eol:		ds	1		; bool, true if EOL arrived
words:		ds	5		; Tokens of line
echo:		ds	1		; bool, do echo or not
called:		dd	0		; bool, entered by CALLIN
nuof_reg:	dd	0		; nr of reg for Rx command
	
reg0:		dd	0
reg1:		dd	0
reg2:		dd	0
reg3:		dd	0
reg4:		dd	0
reg5:		dd	0
reg6:		dd	0
reg7:		dd	0
reg8:		dd	0
reg9:		dd	0
reg10:		dd	0
reg11:		dd	0
reg12:		dd	0
reg13:		dd	0
reg14:		dd	0
reg15:		dd	0
regf:		dd	0
	
msg_start:	db	"PMonitor v%d.%d (cpu v%d.%d.%d)\n"
msg_stopat:	db	"Stop at: "
msg_BS:		db	8,32,8,0
prompt:		db	":"
delimiters:	db	" ;\t\v,=[]"
null_str:	db	"(null)"
sc_active:	db	0
sc_ptr:		db	0
sc_buffer:	ds	10

;;; Command table
commands:
	dd	cmd_sm		; Set Memory address value
	db	"sm"
	dd	cmd_m		; M(emory) address [value]
	db	"m"
	dd	cmd_m		; Mem(ory) address [value]
	db	"mem"
	dd	cmd_d		; D(ump) start end
	db	"d"
	dd	cmd_d
	db	"dump"
	dd	cmd_l		; L(oad)
	db	"l"
	dd	cmd_l
	db	"load"
	dd	cmd_g		; G(o)|run [address]
	db	"g"
	dd	cmd_g
	db	"go"
	dd	cmd_g
	db	"run"
	dd	cmd_h
	db	"?"
	dd	cmd_h
	db	"h"		; H[elp]
	dd	cmd_h
	db	"help"
	dd	cmd_r		; R(eg)
	db	"r"
	dd	cmd_r
	db	"reg"
	dd	cmd_r
	db	"regs"
	dd	cmd_sp
	db	"sp"
	dd	cmd_lr
	db	"lr"
	dd	cmd_pc
	db	"pc"
	dd	cmd_f
	db	"f"
	dd	0
	dd	0

helps:	db	"m[em] addr [val]  Get/set memory\n"
	db	"d[ump] start end  Dump memory content\n"
	db	"l[oad]            Load hex file to memory\n"
	db	"g[o]|run [addr]   Run from address\n"
	db	"r[eg[s]]          Print registers\n"
	db	"rX [val]          Get/set RX\n"
	db	"sp [val]          Get/set R13\n"
	db	"lr [val]          Get/set R14\n"
	db	"pc [val]          Get/set R15\n"
	db	"f [val]           Get/set flags\n"
	db	"h[elp],?          Help\n"
	dd	0


ascii2seg_table:
	dd	0		; 00-03
	dd	0		; 04-07
	dd	0		; 08-0b
	dd	0		; 0c-0f
	dd	0		; 10-13
	dd	0		; 14-17
	dd	0		; 18-1b
	dd	0		; 1c-1f
	dd	0x00220000	; 20-23 SP ! " #
	dd	0x02000000	; 24-27  $ % & '
	dd	0x00000000	; 28-2b  ( ) * +
	dd	0x00004000	; 2c-2f  , - . /
	dd	0x4f5b063f	; 30-33  0 1 2 3
	dd	0x277d6d66	; 34-37  4 5 6 7
	dd	0x00006fff	; 38-3b  8 9 : ;
	dd	0x00004800	; 3c-3f  < = > ?
	dd	0x397c7700	; 40-43  @ A B C
	dd	0x3d71795e	; 44-47  D E F G
	dd	0x001e3076	; 48-4b  H I J K
	dd	0x3f543738	; 4c-4f  L M N O
	dd	0x6d500073	; 50-53  P Q R S
	dd	0x00003e78	; 54-57  T U V W
	dd	0x39006e00	; 58-5b  X Y Z [
	dd	0x08000f00	; 5c-5f  \ ] ^ _
	dd	0x587c7700	; 60-63  ` a b c
	dd	0x3d71795e	; 64-67  d e f g
	dd	0x001e0474	; 68-6b  h i j k
	dd	0x5c540038	; 6c-6f  l m n o
	dd	0x6d500073	; 70-73  p q r s
	dd	0x00001c78	; 74-77  t u v w
	dd	0x00000000	; 78-7b  x y z {
	dd	0x00000000	; 7c-7f  | } ~ DEL

;;; STACK
;;; -----
stack:
	ds	0x40
stack_end:
	dd	0
