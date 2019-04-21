.model tiny

; macro for rinse cycle 
RINSE_CYCLE MACRO DURATION
	MOV AL, 00000001b
	OUT PORTB, AL
	MOV CX, DURATION
	X1: 
		CALL DELAY
		LOOP X1
	CALL RINSED
ENDM


; macro for wash cycle 
WASH_CYCLE MACRO DURATION
	MOV AL, 00000001b
	OUT PORTB, AL
	MOV CX, DURATION
	X2:
		CALL DELAY
		LOOP X2
	CALL WASHED
ENDM


; macro for dry cycle
DRY_CYCLE MACRO DURATION
	MOV AL, 00000010b
	OUT PORTB, AL
	MOV CX, DURATION
	X3:
		CALL DELAY
		LOOP X3
	CALL DRIED
ENDM

.data
	PORTA EQU 00h
	PORTB EQU 02h
	PORTC EQU 04h
	CREG_8255 EQU 06h
	MODE DB 00h

.code
.startup
	; initializing 8255 using control word reg.
	MOV AL, 10010000b
	OUT CREG_8255, AL

	; reset port b
	MOV AL, 00h
	OUT PORTB, AL

	; check if start button is ON(Active Low)
	START: 
		MOV LOAD, 00h
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
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed

		RINSE_CYCLE 2 ; RINSE cycle for 2 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		WASH_CYCLE 3 ; WASH cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		RINSE_CYCLE 2 ; RINSE cycle for 2 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		DRY_CYCLE 2 ; DRY cycle for 2 minutes
		JMP COMPLETE

	MEDIUM:
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed

		RINSE_CYCLE 3 ; RINSE cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		WASH_CYCLE 5 ; WASH cycle for 5 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		RINSE_CYCLE 3 ; RINSE cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		DRY_CYCLE 4 ; DRY cycle for 4 minutes
		JMP COMPLETE

	HEAVY:
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed

		RINSE_CYCLE 3 ; RINSE cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		WASH_CYCLE 5 ; WASH cycle for 5 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		RINSE_CYCLE 3 ; RINSE cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		WASH_CYCLE 5 ; WASH cycle for 5 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL WATER_LVL_MAX ; check if water level is maximum and door is closed
		CALL DEBOUNCE_DELAY 
		CALL DELAY ; user enters detergent during this delay period
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		RINSE_CYCLE 3 ; RINSE cycle for 3 minutes
		CALL WATER_LVL_MIN ; check if water level is minimum and door is closed
		CALL RESUMED ; check if resume button is pressed
		CALL DEBOUNCE_DELAY

		DRY_CYCLE 4 ; DRY cycle for 4 minutes
		JMP COMPLETE

	COMPLETE:

.exit


; introduce delay in the system
DELAY PROC NEAR USES BX, CX
	MOV BX, 0F0h
	L1:
		MOV CX, 0FFFFh
	L2:
		NOP
		LOOP L2
		DEC BX
		JNZ L1
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
WATER_LVL_MAX PROC NEAR 
	MAX:
		IN AL, PORTA
		CMP AL, 11001111b
		JNE MAX
	RET
WATER_LVL_MAX ENDP


; check if water level is minimum and door is closed
WATER_LVL_MIN PROC NEAR 
	MIN:
		IN AL, PORTA
		CMP AL, 10101111b
		JNE MIN
	RET
WATER_LVL_MIN ENDP


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
	CALL DELAY ; turn on buzzer for 1 minute
	MOV AL, 00h
	OUT PORTB, AL
	RET
DRIED ENDP

END