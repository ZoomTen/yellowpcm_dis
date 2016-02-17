; Disassembled from Pokemon Yellow
; Routine to set up audio for PCM playback

; e is the PCM ID to play

PCMFREQ		EQU	$7FF

PlayPCM:
; $f0000 (3c:4000)
	ld a,e
	ld e,a
	ld d, 0
	ld hl,PCMPointers
	add hl,de
	add hl,de
	add hl,de		; multiply by 3 to get the correct pointer address
	ld b,[hl]		; b = bank of PCM data
	inc hl
	ld a,[hli]
	ld h,[hl]
	ld l,a		; hl = pointer to PCM data

	ld c, 4
.wait
	dec c
	jr z,.begin
	call $1E64	; DelayFrame
	jr .wait

; begin the actual routine
.begin
	di 		; we're gonna screw around with
			; the audio, so don't mess things up
	push bc
	push hl

; save wave channel
	ld a,$80	; set bit 7 (all sound on)
	ld [$FF26],a	; NR52, sound control
	ld a,$77	; 
	ld [$FF24],a	; NR50, channel volume control
	xor a		;
	ld [$FF1A],a	; NR30, turn off wave channel

	ld hl,$FF30		; wave ram
	ld de,$CBFC	; wave instrument backup	
.fillwaveram
	ld a,[hl]
	ld [de],a
	inc de
	ld a,$FF		; fill up wave ram
	ldi [hl],a
	ld a,l
	cp a,$40		; are we at the end?
	jr nz,.fillwaveram
	
	ld a,$80	;
	ld [$FF1A],a	; turn on wave channel
	ld a,[$FF25]	; NR51
	or a,$44	; enable all channels?
	ld [$FF25],a	; NR51, sound output
	
; prepare wave channel
	ld a,$FF		; wave channel length?
	ld [$FF1B],a	; NR31
	ld a,$20		; set output to 50%
	ld [$FF1C],a	; NR32

	ld a,(PCMFREQ % $100)
	ld [$FF1D],a	; NR33, wave channel low frequency
	ld a,$80 + (PCMFREQ / $100)
	ld [$FF1E],a	; NR34, wave channel high frequency

; we're done setting up wave channels
; play it
	pop hl
	pop bc
	call PlayPCMSample	; routine is in the other file

; don't know what C0F3 and C0F4 does
	xor a
	ld [$C0F3],a
	ld [$C0F4],a

; reset wave channel
	ld a,$80		; set bit 7 (all sound on)
	ld [$FF26],a	; NR52, sound control
	xor a	
	ld [$FF1A],a	; turn off wave channel

	ld hl,$FF30		; wave ram
	ld de,$CBFC	; wave instrument backup
.copybackup
	ld a,[de]		; copy saved wave instrument back to wave ram
	inc de
	ldi [hl],a
	ld a,l
	cp a,$40
	jr nz,.copybackup

	ld a,$80
	ld [$FF1A],a	; turn on wave channel
	ld a,[$FF25]
	and a,$BB
	ld [$FF25],a	; turn off wave output?

; reset sfx and music
	xor a
	ld [wc02a],a
	ld [wc02b],a
	ld [wc02c],a
	ld [wc02d],a
	
	ld a,[$FFB8]	;H_LOADEDROMBANK
	ei
	ret 

PCMPointers:
; 3c:408e
; The pointers to the PCM data would go here.
; A three byte pointer in the order: [bank], [offset]
	db $21
	dw $4000
	db $21
	dw $491A
	db $21
	dw $4FDC
; and so on.