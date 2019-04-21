.model tiny

; --- MACROS --- ;

; macro for rinse cycle 
RINSE_CYCLE MACRO DURATION
	MOV AL, 00000001b 
	OUT PORTB, AL ; turn on agitator
	MOV CX, DURATION
	CALL DELAY
	CALL RINSED
ENDM

; macro for wash cycle 
WASH_CYCLE MACRO DURATION
	MOV AL, 00000001b 
	OUT PORTB, AL ; turn on agitator
	MOV CX, DURATION
	CALL DELAY
	CALL WASHED
ENDM

; macro for dry cycle
DRY_CYCLE MACRO DURATION
	MOV AL, 00000010b
	OUT PORTB, AL ; turn on revolving tub
	MOV CX, DURATION
	CALL DELAY
	CALL DRIED
ENDM

; macro for consective rinse and wash cycles
RINSE_WASH MACRO RINSE_TIME, WASH_TIME
	RINSE_CYCLE RINSE_TIME ; RINSE cycle 
	CALL WATER_LEVEL_MIN
	CALL WATER_LEVEL_MAX
	MOV CX, 1
	CALL DELAY ; user enters detergent during this delay period
	CALL RESUMED
	CALL DEBOUNCE_DELAY

	WASH_CYCLE WASH_TIME ; WASH cycle 
	CALL WATER_LEVEL_MIN
	CALL WATER_LEVEL_MAX
	CALL RESUMED
	CALL DEBOUNCE_DELAY 
ENDM

; macro for consecutive rinse and dry cycles
RINSE_DRY MACRO RINSE_TIME, DRY_TIME
	RINSE_CYCLE RINSE_TIME ; RINSE cycle 
	CALL WATER_LEVEL_MIN
	CALL RESUMED
	CALL DEBOUNCE_DELAY

	DRY_CYCLE DRY_TIME ; DRY cycle 
ENDM

; --- CODE --- ;

.data
	PORTA EQU 00h
	PORTB EQU 02h
	PORTC EQU 04h
	CREG EQU 06h
	MODE DB 00h

.code
.startup
	; initializing 8255 using control word reg.
	MOV AL, 10010000b
	OUT CREG, AL

	; reset port b
	MOV AL, 00h
	OUT PORTB, AL

	; check if start button is ON(Active Low)
	START: 
		MOV MODE, 00h
		IN AL, PORTA
		CMP AL, 11111110b
		JNZ START
		CALL DEBOUNCE_DELAY
		MOV AL, 00h
		OUT PORTC, AL

	; check for number of load presses
	LOAD:
		IN AL, PORTA
		CMP AL, 11101111b ; check if door is closed
		JZ DOOR_CLOSED
		CMP AL, 11111011b ; else if load button pressed
		JNZ LOAD
		INC BYTE PTR MODE
		CALL DEBOUNCE_DELAY
		JMP LOAD

	; door is now closed
	DOOR_CLOSED:
		MOV AH, MODE
		CMP AH, 00h ; should have greater than 0 presses
		JZ LOAD
		CMP AH, 03h ; should have less than 3 presses
		JLE MODE1
		MOV MODE, 00h
		JMP LOAD

	; valid mode has been entered
	MODE1:
		CMP MODE, 01h
		JNE MODE2
		MOV AL, 01h
		OUT PORTC, AL ; display mode number on 7 seg display
		JMP LIGHT

	MODE2:
		CMP MODE, 02h
		JNE MODE3
		MOV AL, 02h
		OUT PORTC, AL ; display mode number on 7 seg display
		JMP MEDIUM

	MODE3:
		MOV AL, 03h
		OUT PORTC, AL ; display mode number on 7 seg display
		JMP HEAVY

	LIGHT:
		CALL WATER_LEVEL_MAX
		RINSE_WASH 2, 3
		RINSE_DRY 2, 2
		JMP COMPLETE

	MEDIUM:
		CALL WATER_LEVEL_MAX
		RINSE_WASH 3, 5
		RINSE_DRY 3, 4
		JMP COMPLETE

	HEAVY:
		CALL WATER_LEVEL_MAX
		RINSE_WASH 3, 5
		RINSE_WASH 3, 5
		RINSE_DRY 3, 4
		JMP COMPLETE

	COMPLETE:

.exit

; --- PROCEDURES --- ;

; introduce delay in the system- DURATION held in CX register
DELAY PROC NEAR USES BX, DX
	L0:
		MOV BX, 0F0h
	L1:
		MOV DX, 0FFFFh
	L2:
		NOP
		DEC DX
		JNZ L2
		DEC BX
		JNZ L1
	LOOP L0
	RET
DELAY ENDP

; ensure all buttons are unpressed
DEBOUNCE_DELAY PROC NEAR
	DEBOUNCE:
		IN AL, PORTA
		OR AL, 11110000b
		CMP AL, 11111111b
		JNE DEBOUNCE
	RET
DEBOUNCE_DELAY ENDP

; check if water level is maximum and door is closed
WATER_LEVEL_MAX PROC NEAR 
	MAX:
		IN AL, PORTA
		CMP AL, 11001111b
		JNE MAX
	RET
WATER_LEVEL_MAX ENDP

; check if water level is minimum and door is closed
WATER_LEVEL_MIN PROC NEAR 
	MIN:
		IN AL, PORTA
		CMP AL, 10101111b
		JNE MIN
	RET
WATER_LEVEL_MIN ENDP

; check if resume button is pressed
RESUMED PROC NEAR
	RESUMEOFF:
		IN AL, PORTA
		OR AL,11100111B
        CMP AL,11100111B
        JNE RESUMEOFF
    RET
RESUMED ENDP

; rinse cycle completed
RINSED PROC NEAR
	MOV AL, 00h
	OUT PORTB, AL ; turn off agitator
	MOV AL, 00010000b 
	OUT PORTB, AL 
	MOV CX, 1
	CALL DELAY ; turn on buzzer for 1 minute
	MOV AL, 00h 
	OUT PORTB, AL ; turn off buzzer
	RET
RINSED ENDP

; wash cycle completed
WASHED PROC NEAR
	MOV AL, 00h
	OUT PORTB, AL ; turn off agitator
	MOV AL, 00001000b
	OUT PORTB, AL
	MOV CX, 1
	CALL DELAY ; turn on buzzer for 1 minute
	MOV AL, 00h
	OUT PORTB, AL
	RET
WASHED ENDP

; dry cycle completed
DRIED PROC NEAR
	MOV AL, 00h
	OUT PORTB, AL ;turn off revolving tub
	MOV AL, 00000100b
	OUT PORTB, AL
	MOV CX, 1
	CALL DELAY ; turn on buzzer for 1 minute
	MOV AL, 00h
	OUT PORTB, AL
	RET
DRIED ENDP

END