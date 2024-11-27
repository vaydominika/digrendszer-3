	.proc	p2
	
	;;
	;;      tu_save_cursor    ()
	;;      tu_restore_cursor ()
	;;      tu_hide           ()
	;;      tu_show           ()
	;;      tu_clear_screen   ()
	;;      tu_clear_char     ()
	;;      tu_go_left        (R0:n)
	;;      tu_go_right       (R0:n)
	;;      tu_go_up          (R0:n)
	;;      tu_go_down        (R0:n)
	;;      tu_go             (R0:x1,R1:y1)
	;;      tu_color          (R0:bg,R1:fg)
	;;      tu_fg             (R0:fg)
	;;      tu_bg             (R0:bg)
	;;      tu_wob            ()
	;;      tu_bow            ()
	;;      tu_gob            ()
	;;


	.seg	_lib_segment_tu_cursor

tu_save_cursor::
	push	lr
	ces	eprints
	.db	"\e[s"
	pop	pc

	
tu_restore_cursor::
	push	lr
	ces	eprints
	.db	"\e[u"
	pop	pc


tu_hide::
	push	lr
	ces	eprints
	.db	"\e[?25l"
	pop	pc


tu_show::
	push	lr
	ces	eprints
	.db	"\e[?25h"
	pop	pc
	
	.ends


	.seg	_lib_segment_tu_clear

tu_clear_screen::
	push	lr
	ces	eprints
	.db	"\e[2J\e[1;1H"	
	pop	pc


tu_clear_char::
	push	lr
	ces	eprints
	.db	"\e[s \e[u"
	pop	pc
	
	.ends

	
	.seg	_lib_segment_tu_moving

	;; In : R0 distance
tu_go_left::
	push	lr
	push	r1
	mov	r1,r0
	ces	eprintf
	.db	"\e[%dD"
	pop	r1
	pop	pc


	;; In : R0 distance
tu_go_right::
	push	lr
	push	r1
	mov	r1,r0
	ces	eprintf
	.db	"\e[%dC"
	pop	r1
	pop	pc


	;; In : R0 distance
tu_go_up::
	push	lr
	push	r1
	mov	r1,r0
	ces	eprintf
	.db	"\e[%dA"
	pop	r1
	pop	pc


	;;  In : R0 distance
tu_go_down::
	push	lr
	push	r1
	mov	r1,r0
	ces	eprintf
	.db	"\e[%dB"
	pop	r1
	pop	pc


	;; In : R0 X1
	;;      R1 Y1
tu_go::
	push	lr
	push	r1
	push	r2
	mov	r2,r0
	ces	eprintf
	.db	"\e[%d;%dH"
	pop	r2
	pop	r1
	pop	pc

	.ends


	.seg	_lib_segment_tu_color

_tu_bg_color:
	ds	1
_tu_fg_color:
	ds	1
	
	;; In : R0 bg 0-15, R0<0 do not change
	;;      R1 fg 0-15, R1<0 do not change
tu_color::
	push	lr
	push	r0
	push	r1
	
	sz	r1
	S1 jmp	set_bg
set_fg:
	btst	r1,15
	test	r1,8
	Z plus	r1,30
	NZ plus	r1,82
	st	r1,_tu_fg_color
	ces	eprintf
	.db	"\e[%dm"
set_bg:
	sz	r0
	S1 jmp	end
	btst	r0,15
	test	r0,8
	Z plus	r0,40
	NZ plus	r0,92
	mov	r1,r0
	st	r1,_tu_bg_color
	ces	eprintf
	.db	"\e[%dm"
end:
	pop	r1
	pop	r0
	pop	pc


	;; In : R0 color 0-15
tu_fg::
	push	lr
	push	r0
	push	r1
	mov	r1,r0
	mvs	r0,-1
	call	tu_color
	pop	r1
	pop	r0
	pop	pc


	;; In : R0 color 0-15
tu_bg::
	push	lr
	push	r0
	push	r1
	mvs	r1,-1
	call	tu_color
	pop	r1
	pop	r0
	pop	pc


	;; white on black
tu_wob::
	push	lr
	ces	eprints
	.db	"\e[37;40m"
	pop	pc


	;; black on white
tu_bow::
	push	lr
	ces	eprints
	.db	"\e[30;47m"
	pop	pc


	;; green on black
tu_gob::
	push	lr
	ces	eprints
	.db	"\e[32;40m"
	pop	pc

	.ends
	
