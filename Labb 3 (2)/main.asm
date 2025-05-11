;
; Labb 3 (2).asm
;
; Created: 2025-05-08 11:17:03
; Author : joeeb477
;
jmp		HW_INIT

.dseg
.org	SRAM_START
TIME:	.byte 4
POS:	.byte 1
TAB:	.db	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

	.cseg
		.org INT0addr
	jmp	BCD
		.org INT1addr
	jmp	MUX
		.org INT_VECTORS_SIZE

HW_INIT:
	ldi		r16, HIGH(RAMEND)	; Inititera stack
	out		SPH, r16			
	ldi		r16, LOW(RAMEND)	
	out		SPL, r16			
	ldi		r16, $FF			; Initiera portar
	out		DDRB, r16			
	clr		r16		
	out		DDRA, r16			
	ldi		r16, (1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)	; Konfigurera flanker
	out		MCUCR, r16
	ldi		r16, (1<<INT1)|(1<<INT0)		; Aktivera specifika avbrott
	out		GICR, r16
	sei										; Aktivera globalt

MAIN:	
	clr		r16
	clr		r17
	clr		r18
	clr		XH
	clr		XL
	clr		YH
	clr		YL
	clr		ZH
	clr		ZL
	jmp		MAIN

MUX:
	push	r16
	in		r16, SREG
	push	r16
	push	ZH
	push	ZL

	lds		r16, POS
	inc		r16
	cpi		r16, 4
	brne	MUX_NEXT
	ldi		r16, 0

MUX_NEXT:
	sts		POS, r16
	ldi		ZH, HIGH(TIME)
	ldi		ZL, LOW(TIME)
	add		ZL, r16
	clr		r18
	adc		ZH, r18
	ld		r17, Z

LOOKUP:
	push	ZH
	push	ZL
	ldi		ZH, HIGH(TAB*2)
	ldi		ZL, LOW(TAB*2)
	add		ZL, r17
	clr		r17
	adc		ZH, r17
	lpm		r17, Z
	pop		ZL
	pop		ZH

MUX_OUT:
	out		PORTB, r17
	lsl		r16
	inc		r16
	out		PORTA, r16

MUX_EXIT:
	pop		ZL
	pop		ZH
	pop		r16
	out		SREG, r16
	pop		r16
	reti

BCD:
	push	r16
	in		r16, SREG
	push	r16
	push	r18
	push	ZH
	push	ZL

	lds		XH, TIME+1
	lds		XL, TIME+0
	lds		YH, TIME+3
	lds		YL, TIME+2

	inc		XL
	cpi		XL, 10
	brne	BCD_EXIT
	ldi		XL, 0

	inc		XH
	cpi		XH, 6
	brne	BCD_EXIT
	ldi		XH, 0

	inc		YL
	cpi		YL, 10
	brne	BCD_EXIT
	ldi		YL, 0

	inc		YH
	cpi		YH, 6
	brne	BCD_EXIT
	ldi		YH, 0

BCD_EXIT:
	sts		TIME+1, XH
	sts		TIME+0, XL
	sts		TIME+3, YH
	sts		TIME+2, YL
	pop		ZL
	pop		ZH
	pop		r16
	out		SREG, r16
	pop		r16
	reti