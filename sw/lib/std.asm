	cpu	p2

	;;
	;; R4=             itobcd   (R0:val)
	;;
	

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.seg	_lib_segment_itobcd
itobcd::
	push	lr
	push	r0
	call	_pm_itobcd
	mov	r4,r0
	pop	r0
	pop	pc
	
	.ends

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
