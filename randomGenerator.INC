initTimer0

    banksel	OPTION_REG
    movlw	B'10000111'	; Timer0 increment from internal clock with a prescaler of 1:256.
    movwf	OPTION_REG

    banksel	INTCON
    bsf 	INTCON, T0IE 	; Enable TMR0 interrupt
    bsf 	INTCON, GIE 	; Enable all interrupts
    return

assignRandomNumber

    banksel	TMR0
    movf   TMR0,0
    movwf  randNumber
    movlw  d'157'
    subwf  randNumber,1
    addwf  randNumber,0
    return

timer0_isr
	
	call	save_registers ; save current content of STATUS and PCLATH registers to be abel to restore later
	
    banksel	TMR0
    movlw	d'157'		;256-157=99
    movwf	TMR0 		

    banksel	INTCON
    bcf	INTCON,T0IF
	
	call	restore_registers ; restore STATUS and PCLATH registers to their state before interrupt occurs
	
    retfie

;;;;;;;;;;;; Register handling for proper operation of main program ;;;;;;;;;;;;

save_registers:
	MOVWF 	W_TEMP		;Copy W to TEMP register
	SWAPF 	STATUS,W 	;Swap status to be saved into W
	CLRF 	STATUS 		;bank 0, regardless of current bank, Clears IRP,RP1,RP0
	MOVWF 	STATUS_TEMP 	;Save status to bank zero STATUS_TEMP register
	MOVF 	PCLATH, W 	;Only required if using pages 1, 2 and/or 3
	MOVWF 	PCLATH_TEMP 	;Save PCLATH into W
	CLRF 	PCLATH 		;Page zero, regardless of current page

	return

restore_registers:
	MOVF 	PCLATH_TEMP, W 	;Restore PCLATH
	MOVWF 	PCLATH 		;Move W into PCLATH
	SWAPF 	STATUS_TEMP,W 	;Swap STATUS_TEMP register into W
	;(sets bank to original state)
	MOVWF 	STATUS 		;Move W into STATUS register
	SWAPF 	W_TEMP,F 	;Swap W_TEMP
	SWAPF 	W_TEMP,W 	;Swap W_TEMP into W

	return
