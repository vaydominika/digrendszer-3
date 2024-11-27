	.proc	p2

	
	.seg	_lib_segment_regs_of_clock
	
CLOCK.CLOCK	==	0xff50
CLOCK.CLK	==	0xff50
CLOCK.PRE	==	0xff51
CLOCK.BCNT2	==	0xff52
CLOCK.BCNT3	==	0xff53
CLOCK.BCNT4	==	0xff54
CLOCK.BCNT5	==	0xff55
CLOCK.BCNT6	==	0xff56
CLOCK.BCNT7	==	0xff57
CLOCK.BCNT8	==	0xff58
CLOCK.BCNT9	==	0xff59
CLOCK.BCNT10	==	0xff5a
CLOCK.BCNT11	==	0xff5b
CLOCK.BCNT12	==	0xff5c
CLOCK.BCNT13	==	0xff5d
CLOCK.BCNT14	==	0xff5e
CLOCK.BCNT15	==	0xff5f

	.ends

	
	.seg	_lib_segment_regs_of_gpio

GPIO.PORTA	==	0xff00	; 7seg (selectable)
GPIO.PORTB	==	0xff01	; led
GPIO.PORTC	==	0xff02
GPIO.PORTD	==	0xff03

GPIOA.ODR	==	0xff00
GPIOB.ODR	==	0xff01
GPIOC.ODR	==	0xff02
GPIOD.ODR	==	0xff03

GPIO.7SEG	==	0xff00	; GPIOA.ODR
GPIO.LED	==	0xff01	; GPIOB.ODR
	
GPIO.PORTI	==	0xff20	; btn
GPIO.PORTJ	==	0xff10	; sw

GPIOI.IDR	==	0xff20	; GPIO.PORTI
GPIOJ.IDR	==	0xff10	; GPIO.PORTJ

GPIO.BTN	==	0xff20	; GPIOI.IDR
GPIO.SW		==	0xff10	; GPIOJ.IDR

	.ends

	
	.seg	_lib_segment_regs_of_timer

TIMER.CTRL	==	0xff30
TIMER.AR	==	0xff31
TIMER.CNTR	==	0xff32
TIMER.STAT	==	0xff33

	.ends

	
	.seg	_lib_segment_regs_of_uart

UART.DR		==	0xff40
UART.CTRL	==	0xff41
UART.RSTAT	==	0xff42
UART.TSTAT	==	0xff43
UART.CPB	==	0xff44
UART.SREG0	==	0xff4c
UART.SREG1	==	0xff4d
UART.SREG2	==	0xff4e
UART.SREG3	==	0xff4f

	.ends


	.seg	_lib_segment_brd_ctrl

BRD_CTRL.OUT	==	0xfff0

	.ends

	
	.seg	_lib_segment_regs_of_simif

SIMIF.CMD_PAR	==	0xffff

	.ends
	
