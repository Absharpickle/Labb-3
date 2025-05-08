;
; Labb 3 (2).asm
;
; Created: 2025-05-08 11:17:03
; Author : joeeb477
;


.dseg
.org	SRAM_START
TIME:	.byte 4
POS:	.byte 1
TAB:	.db	10,6,10,6

	.cseg
		.org $0000
	jmp MAIN
		.org INT0addr
	jmp	MUX
		.org INT1addr
	jmp	BCD
		.org INT_VECTORS_SIZE

HW_INIT:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	ldi		r16, $FF
	out		DDRB, r16
	clr		r16
	out		DDRA, r16

HW_INIT_EXIT:
	ret

SEGTAB:
	.db		0x3F

MUX:
	push	r16
	in		r16, SREG
	push	r16
	ldi		XH, HIGH(TIME)
	ldi		XL, LOW(TIME)
	ldi		r16, X
	inc		r16
	cpi		r16, 4
	brlo	MUX_NEXT
	clr		r16

MUX_NEXT:
	sts		X, r16

MUX_EXIT:
	pop		r16
	out		SREG, r16
	pop		r16
	reti

BCD:
	push	r16
	in		r16, SREG
	push	r16
	push	XH
	push	XL
	ldi		XH, HIGH(TIME)
	ldi		XL, LOW(TIME)
	ldi		YH, HIGH(TAB)
	ldi		YL, LOW(TAB)

BCD_LOOP:
	ldi		r16, X
	inc		r16
	cpi		r16, Y+
	brlo	BCD_EXIT
	clr		r16
	sts		X, r16
	adiw	X, 1
	call	BCD_CHECK
	rjmp	BCD_LOOP

BCD_CHECK:
	inc		r17
	cpi		r17, 4
	brlo	BCD_CHECK_EXIT
	clr		r16
	rjmp	BCD_EXIT

BCD_CHECK_EXIT:
	ret

BCD_EXIT:
	sts		X, r16
	pop		XL
	pop		XH
	pop		r16
	out		SREG, r16
	pop		r16
	reti

MAIN:
	call	HW_INIT
	ldi		r16, (1<<ISC01)|(0<<ISC00)|
				 (1<<ISC11)|(0<<ISC10)
	out		MCUCR, r16
	ldi		r16, (1<<INT1)|(1<<INT0)
	out		GICR, r16
	sei

MAIN_WAIT:
	jmp		MAIN_WAIT