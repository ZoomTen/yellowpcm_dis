SAMPLE_SPEED	EQU	3

; $150
PlayPCMSample:
	ld a,[$FFB8] ;H_LOADEDROMBANK
	push af
	ld a,b	; load PCM's bank
	call PCM_BankSwitch

	ld a, [hli]
	ld c,a	; lower byte of PCM length
	ld a, [hli]
	ld b,a	; high byte of PCM length
	
PlayPCMSample_Main:
	ld a, [hli]
	ld d,a	; read sample byte

; put silence
	ld a,SAMPLE_SPEED
.delay
	dec a
	jr nz,.delay

; transfer sound data
	call ExecutePCM	; 1
	call WaitSample
	call ExecutePCM	; 2
	call WaitSample
	call ExecutePCM	; 3
	call WaitSample
	call ExecutePCM	; 4
	call WaitSample
	call ExecutePCM	; 5
	call WaitSample
	call ExecutePCM	; 6
	call WaitSample
	call ExecutePCM	; 7
	call WaitSample
	call ExecutePCM	; 8
; decrement sample length
	dec bc
	ld a,c
	or b		; if b and c are 0
	jr nz,PlayPCMSample_Main
; bankswitch back
	pop af
	call PCM_BankSwitch
	ret

ExecutePCM:
; sample player
	ld a,d
	and a,$80
	srl a
	srl a
	ld [$FF1C],a	; manipulate the wave volume
	sla d
	ret

WaitSample:
	ld a,SAMPLE_SPEED
.wait
	dec a
	jr nz,.wait
	ret
			 
PCM_BankSwitch:
; $3E7E
	ld [$FFB8],a ;H_LOADEDROMBANK
	ld [$2000],a
	ret 
