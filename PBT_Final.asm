;common dec
Milisecs equ	0x20
Days0	equ	0x21
Days1	equ	0x22
Year0	equ	0x23
Year1	equ	0x24
leapYr	equ	0x25

; intialize registers
	movlw	0
	movwf	Milisecs 	;initilize Miliseconds
	movlw	55
	movwf	Seconds	;initilize seconds
	movlw	59
	movwf	Minutes	;initilize Minutes
	movlw	23
	movwf	Hours	;initilize Hours
	movlw	108
	movwf	Days0 	;initilize Days0
	movlw	1
	movwf	Days1 	;initilize Days1
	movlw	0
	movwf	Year0 	;initilize Year0
	movlw	0
	movwf	Year1 	;initilize Year1	

begin	
	movlw	1
	call 	Delay1s
    
	movlw   0x00
	call    LCDset    
    
	call    DisplayYear

	movlw   ':
	call    ASC2LCD
    

	call    DisplayDay
    
	movlw   ':
	call    ASC2LCD

	call    RTC2LCD
     
	call    testLeap
	call	incDaysYears
	
	goto 	begin

nextYear
;Martin
;count up the year
;year1 = century (00-99)
;year0 = year within the century (00-99)
	return


DisplayYear
;Martin
;displays the year as a 4 digit number

	return

DisplayDay
;Paul/Me
;displays the day as a 3 digit number
	
	movf	Days0,W
	movwf	WL
	movf	Days1,W
	movwf	WH

	movlw	100
	movwf	CH
	call	Div16x8	;
	movwf	temp	;put remainder in temp
	movf	WL,W	;put result in W
	addlw	48	;add 30 to result to convert to ASCII
	call	ASC2LCD	;write ascii to LCD
	movf	temp,W	;put remainder back into W
	movwf	WL	;then into WL for division

	movlw	10
	movwf	CH
	call	Div16x8	;
	movwf	temp	;put remainder in temp
	movf	WL,W	;put result in W
	addlw	48	;add 30 to result to convert to ASCII
	call	ASC2LCD	;write ascii to LCD

	movf	temp,W	;put remainder back into W
	addlw	48	;convert to ascii
	call	ASC2LCD	;write to LCD

	return

incDaysYears
;increments days if needed and years if needed aswell
	
	;checks if seconds is at 59
	movf	Seconds,W	;move Seconds to W
	sublw	59		;subtract seconds from 59
	btfss	STATUS,Z	;if 0 skip next instruction
	goto	notZero		;branch to notZero
	
	;checks if minutes is at 59
	movf	Minutes,W	;move Minutes to W
	sublw	59		;subtract minutes from 59
	btfss	STATUS,Z	;if 0 skip next instruction
	goto 	notZero		;branch to notZero
	
	;checks if hours is at 23	
	movf	Hours,W		;move Hours to W
	sublw	23		;subtract hours from 59
	btfss	STATUS,Z	;if not 0 skip next instruction
	goto 	notZero		;branch to notZero
	
	movlw	1		;put 1 into W to increment Days0
	addwf	Days0		;add 1 to days0
	
	btfsc	STATUS,C	;skip next instruction if Days0 does not cause carry flag
	incf	Days1		;increment Days1 

	;1 01101101 - 365 
	;1 01101100 - 364

	movlw	%00000001 	;put 1 into w for 9th bit of day
	subwf	Days1,W		;check if 9th bit of days is set
	btfss	STATUS,Z	;if the bit is set skip next instruction
	goto	notZero	

	movlw	%01101100 	;put 
	addwf	leapYr,W	;add leap year to 365, so if leap year it'll go to 365 days
	subwf	Days0,W		;checks if day is at the max value - 364 or 365
	btfsc	STATUS,Z	;if the byte isn't at max day skip next instruction
	call	nextYear
	
notZero
	return
	

testLeap
;test if this is a leap Year
;returns 0 if no leap year, 1 if leap year
    	clrf	leapYr      ;clear leap year
	incf	leapYr      ;incremeant leap year - Assume this is a leap Year
	movf	Year0,W     ;move year0 to W
	andlw	0x03        ;and it with 3 to test the 2 bits
	btfss	STATUS,Z    ;test if the bits were 0
	clrf	leapYr      ;if the bit wasnt zero then clear leapYr because it's not a leap year
	return              



