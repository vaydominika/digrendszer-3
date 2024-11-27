	.proc	p2

	;;
	;;          monitor           ()
	;; 	    monitor_by_uart   ()
	;;          monitor_by_button (R0:btn)
	;; R4:ver   monitor_version   ()
	;;
	
	
	.seg	_lib_segment_pmon

_pm_callin		==	0xf000
_pm_enter_by_uart	==	0xf001
_pm_getchar		==	0xf002
_pm_version		==	0xf003
_pm_itobcd		==	0xf004	
_pm_cold_start		==	0xf005
_pm_strchr		==	0xf006
_pm_streq		==	0xf007
_pm_check_uart		==	0xf008
_pm_input_avail		==	0xf008	
_pm_hexchar2value	==	0xf009
_pm_value2hexchar	==	0xf00a
_pm_htoi		==	0xf00b
_pm_strieq		==	0xf00c
_pm_read		==	0xf00d
_pm_putchar		==	0xf00e
_pm_prints		==	0xf00f
_pm_printsnl		==	0xf010
_pm_print_vhex		==	0xf011
_pm_pes			==	0xf012
_pm_printd		==	0xf013
_pm_printf		==	0xf014
_pm_pesf		==	0xf015
_pm_ascii2seg		==	0xf016
	

monitor::
	jmp	_pm_callin

	
monitor_by_uart::
	jmp	_pm_enter_by_uart

	
monitor_by_button::
	push	lr
	call	btn_posedge
	NC pop	pc
	call	monitor
	call	btn_restart
	pop	pc

	
monitor_version::
	push	lr
	push	r0
	call	_pm_version
	mov	r4,r0
	pop	r0
	pop	pc
	
	.ends
