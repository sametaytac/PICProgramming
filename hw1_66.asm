	;----------------------------------------;
	;Student ID:1819044
	;Name and Surname: SAMET AYTAÇ
    ;----------------------------------------;
 


LIST	P=16F877
#include <p16f877.inc>
 __CONFIG   (_CP_OFF&_WDT_OFF&_PWRTE_OFF&_HS_OSC&_LVP_OFF&_BODEN_OFF&_WRT_ENABLE_OFF)

; This program controls SW00 on the development board and when we press and relase it a counter the LED array increase.
; Since the button control is not properly handled, counter sometimes increases more than one. Try to enhance the button control!

W_TEMP		equ	020h
STATUS_TEMP	equ	021h
PCLATH_TEMP	equ	022h
randNumber udata 0x23
randNumber

toplamSayi  equ 0x32
birler equ 0x25
onlar equ 0x28
cikarmaSonucu equ 0x33
var4 equ 0x26
var5 equ 0x27
var7 equ 0x30
var8 equ 0x31
ilkled equ 0x34
can    equ 0x35
sayi equ 0x36
d1  equ 0x37
d2  equ 0x38
d3  equ 0x39

    ORG 0
    goto init

    ORG 4
   goto    timer0_isr
#INCLUDE "randomGenerator.INC"

init:
call    initTimer0
	banksel	ADCON1		; We have to configure ADCON1 to be able to use PORTA and PORTE pins for digital I/O.
	movlw	0x06
	movwf 	ADCON1

	banksel TRISA
	clrf    TRISA		; We are making all of the PORTA pins output.
	banksel PORTA
	clrf    PORTA


	banksel TRISE
	clrf	TRISE		; We are making all of the PORTE pins output.
	banksel PORTE
	clrf	PORTE		; Selection pins od 7-Segment displays are on PORTE. We are clearing PORTE to ensure they are not selected.



	banksel	OPTION_REG
	bcf	OPTION_REG,7	; Enable pull ups. With this configuration we will read 1 from RB4 while SW00 is not pressed.
	banksel TRISB
	movlw	b'00011110'	; We will use SW00 on the development board which is connected between RB4 and RB0.
                        ; With b'11110000' literal we will configure RB4 as input and RB0 as output.
                        ; This literal will also make RB1,2,3 pins output and  RB5,6,7 pins input.
	movwf	TRISB
	banksel PORTB
	clrf 	PORTB		; We are clearing PORTB to clear RB0 so that when we press SW00, 0 will be read from RB4.

    call delay2

	banksel TRISD
	clrf	TRISD		; We are making all of the PORTD pins output.
	banksel PORTD
	clrf 	PORTD	; Data bus for LED array is PORTD and initially we are clearing it.
	movwf	PORTD

    banksel birler		; birler will increse when we press and release SW00.
    clrf    birler		; Initially we are clearing it,
    clrf    onlar
    clrf    toplamSayi
    
    
    movlw b'00010000'
    movwf   sayi

main:
    movlw	b'00111111'
    movwf   can



    bsf PORTD,0 ; Ba?lang?çta --- bast?rmak için

    bsf PORTE,0
    bsf PORTE,1
    bsf PORTE,2

    call delay2

    bcf PORTE,0
    bcf PORTE,1
    bcf PORTE,2

    btfsc	PORTB,4		; If Start button is pressed skip next line
    goto main

    call delay2

    btfss	PORTB,4 	; If Start button is released skip next line.
    goto    $-1

    movlw b'00000001'
    movwf ilkled
    movfw can
    call   assignRandomNumber
   
startPoint:
  
    movfw   can

    movwf PORTD
    bsf PORTA,2
    call delay
    bcf PORTA,2

  
   

    call tableFonk
    movwf PORTD
    bsf PORTE,0
    call delay
    bcf PORTE,0



    
	call tableFonk2
    movwf PORTD
    bsf PORTE,1
    call delay
    bcf PORTE,1




    movfw ilkled

	movwf PORTD
    bsf PORTE,2
    call delay
    bcf PORTE,2



    banksel TRISB
    movlw b'10001011'                 ;sw11 buttonu ayarlama
    movwf   TRISB

    banksel PORTB
    btfsc	PORTB,7		; If button is pressed skip next line
    goto 	birlerUp

    call delay

    btfss	PORTB,7 	; If button is released skip next line.
    goto    $-1
    goto    polatli



birlerUp:



    banksel TRISB
    movlw	b'01001101'     ;sw05 buttonu ayarlama
    movwf   TRISB

    banksel PORTB
    btfsc	PORTB,6		; If button is pressed skip next line
    goto 	onlarUp

    call delay

    btfss	PORTB,6 	; If button is released skip next line.
    goto    $-1

    btfsc   birler,0
    btfss   birler,3
    incf    birler,1


     movlw b'00000001'
    movwf ilkled



    goto	startPoint

onlarUp:
    banksel TRISB
    movlw	b'00011101'     ;sw04 buttonu ayarlama
    movwf   TRISB

    call delay

    banksel PORTB
    btfsc	PORTB,4		; If button is pressed skip next line
    goto 	birlerdown

  

    btfss	PORTB,4 	; If button is released skip next line.
    goto    $-1

    btfsc   onlar,0
    btfss   onlar,3
    incf    onlar,1

 movlw b'00000001'
    movwf ilkled
    goto	startPoint


birlerdown:
    banksel TRISB
    movlw	b'10001101'     ;sw09 buttonu ayarlama
    movwf   TRISB

    banksel PORTB
    btfsc	PORTB,7		; If button is pressed skip next line
    goto 	onlardown

    call delay

    btfss	PORTB,7 	; If button is released skip next line.
    goto    $-1

    btfsc   birler,0
    goto sam
    btfsc   birler,1
    goto sam
    btfsc   birler,2
    goto sam
    btfss   birler,3
    goto startPoint2

    startPoint2:
 movlw b'00000001'
    movwf ilkled
    goto startPoint
sam:
    decf    birler,1

 movlw b'00000001'
    movwf ilkled
    goto	startPoint

onlardown:
    banksel TRISB
    movlw	b'00101101'     ;sw08 buttonu ayarlama
    movwf   TRISB


    banksel PORTB
    btfsc	PORTB,5		; If button is pressed skip next line
    goto 	startPoint



    btfss	PORTB,5 	; If button is released skip next line.
    goto    $-1

    btfsc   onlar,0
    goto sam1
    btfsc   onlar,1
    goto sam1
    btfsc   onlar,2
    goto sam1
    btfss   onlar,3
    goto startPoint2
sam1:
    decf    onlar,1

 movlw b'00000001'
    movwf ilkled
    goto	startPoint


polatli:
        call toplama
        movf toplamSayi,0
        subwf randNumber,0
        movwf cikarmaSonucu



        btfsc   cikarmaSonucu,0
        goto startPoint1
        btfsc   cikarmaSonucu,1
        goto startPoint1
        btfsc   cikarmaSonucu,2
        goto startPoint1
        btfsc   cikarmaSonucu,3
        goto startPoint1
        btfsc   cikarmaSonucu,4
        goto startPoint1
        btfsc   cikarmaSonucu,5
        goto startPoint1
        btfss   cikarmaSonucu,6
        goto dogruCevap2



startPoint1:

        btfss cikarmaSonucu,7
        goto pozitif
        goto negatif

        pozitif:
        movlw b'00100011'
        movwf ilkled
        call canAzaltma
        

        movwf can
        
        call delay2

        goto startPoint






        goto startPoint

        negatif:
        movlw b'00010101'
        movwf ilkled
        call canAzaltma
        

        movwf can

        call delay2

        goto startPoint





delay2:
    movlw 0x11
	movwf var4
	movlw 0x00
	movwf var5


loop3:
	decfsz var4,1
	goto loop3
	decfsz var5,1
	goto loop3


    return

delay5:
    movlw 0xff
	movwf var4
	movlw 0xff
	movwf var5
    movlw 0x01
	movwf sayi

loop5:
	decfsz var4,1
	goto loop5
	decfsz var5,1
	goto loop5
    decfsz sayi,1
	goto loop5


    return


delay1:
    movlw h'1'
	movwf var7
    decfsz var7,1
	goto delay1
    return




delay:
	movlw	0x11  ; 0xff
	movwf	var8
    movlw	0x07
	movwf	var7
loop2
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz	var8,1
	goto	loop2
    decfsz	var7,1
	goto	loop2
	return
toplama:
    clrw
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     onlar,0
    addwf     birler,0
    movwf     toplamSayi
    return

canAzaltma:
    btfsc can,5
    goto can5

    btfsc can,4
    goto can4

    btfsc can,3
    goto can3

    btfsc can,2
    goto can2

    btfsc can,1
    goto can1

    btfsc can,0
    goto yanma


    can5:
    movlw b'00011111'
    ;movwf can
    return
    can4:
    movlw b'00001111'
   ; movwf can

     return
    can3:
    movlw b'00000111'
    ;movwf can

    return
    can2:
    movlw b'00000011'
    ;movwf can

    return
    can1:
    movlw b'00000001'
    ;movwf can
    return

yanma:
   bcf PORTA,2

   movlw b'00111101'     ; D basiyor
   movwf    PORTD

   bsf PORTE,0
   call delay
   bcf PORTE,0


   movlw b'00010101'
   movwf    PORTD

   bsf PORTE,1
   call delay
   bcf PORTE,1

   movlw b'01001111'
   movwf    PORTD

   bsf PORTE,2
   call delay
   bcf PORTE,2

   goto yanma

dogruCevap2:





    movf birler,0
    call tableFonk
    movwf PORTD
    bsf PORTE,0
    call delay
    bcf PORTE,0




    movf onlar,0
	call tableFonk2
    movwf PORTD
    bsf PORTE,1
    call delay
    bcf PORTE,1

    call delay2
    call delay2
    call delay2
    call delay2


decfsz	sayi,1
goto dogruCevap2




dogruCevap:




    movfw   can
    movwf PORTD
    bsf PORTA,2
    call delay
    bcf PORTA,2



   movlw b'00111101'     ; D basiyor
   movwf    PORTD

   bsf PORTE,0
   call delay
   bcf PORTE,0


   movlw b'00010101'
   movwf    PORTD

   bsf PORTE,1
   call delay
   bcf PORTE,1

   movlw b'01001111'
   movwf    PORTD

   bsf PORTE,2
   call delay
   bcf PORTE,2

goto dogruCevap


tableFonk:

btfsc birler,3
goto dortbitler
btfsc birler,2
goto ucbitler
btfsc birler,1
goto ikibitler
btfsc birler,0
goto bir
movlw b'01111110' ;0
return

bir
movlw b'00110000' ;1
return

ikibitler
btfsc birler,0
movlw b'01111001' ;3
btfss birler,0
movlw b'01101101' ;2
return



ucbitler
btfsc birler,1
goto altiyedi
goto dortbes

dortbes
btfsc birler,0
movlw b'01011011' ;5
btfss birler,0
movlw b'00110011' ;4
return




altiyedi

btfsc birler,0
movlw b'01110000' ;7
btfss birler,0
movlw b'01011111' ;6
return


dortbitler
btfsc birler,0
movlw b'01111011' ;9
btfss birler,0
movlw b'01111111' ;8
return

tableFonk2:

btfsc onlar,3
goto dortbitler2
btfsc onlar,2
goto ucbitler2
btfsc onlar,1
goto ikibitler2
btfsc onlar,0
goto bir2
movlw b'01111110' ;0
return

bir2
movlw b'00110000' ;1
return

ikibitler2
btfsc onlar,0
movlw b'01111001' ;3
btfss onlar,0
movlw b'01101101' ;2
return



ucbitler2
btfsc onlar,1
goto altiyedi2
goto dortbes2

dortbes2
btfsc onlar,0
movlw b'01011011' ;5
btfss onlar,0
movlw b'00110011' ;4
return




altiyedi2

btfsc onlar,0
movlw b'01110000' ;7
btfss onlar,0
movlw b'01011111' ;6
return


dortbitler2
btfsc onlar,0
movlw b'01111011' ;9
btfss onlar,0
movlw b'01111111' ;8
return



end
