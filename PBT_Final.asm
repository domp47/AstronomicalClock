;Astro Clock
;Domenic,Martin,Paul,Chris^2
;March 17 2017
;Phys 2P32
;The task is to detect (count) the time of an astronomical Event, with 10ms resolution (assuming a precise clock of 100 Hz is available externally, if necessary),
;and to display the time in the format "YY:DDD:HH:MM:SS.mm", where YY=0..99, DDD=0..365 (note that one year is 365.25 days), HH=0..23, MM=0..59, SS=0..59, mm=0..99. ;Assume you would be using the LCD display, 2x40 characters.
;
;To test transitions across hour/day/year boundaries your counter should be pre-loadable with appropriate values that can demonstrate these transitions within a few ;seconds, e.g. something like "00:365:23:59:55.00" could be pre-loaded as a starting point for the "stopwatch". 
;Uses LCD subroutines to display to LCD Display
;Uses built in Math subroutines

;common declarations
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
	movlw	20
	movwf	Year1 	;initilize Year0
	movlw	17
	movwf	Year0 	;initilize Year1	
	call    testLeap
	call LCDinit

begin	
	movlw	1		;adds 1 second to delay
	call 	Delay1s
    
	movlw   0x00		;sets lcd pointer to top left corner
	call    LCDset    
    
	call    DisplayYear	;displays year (Y1/y0)

	movlw   ':		;adds a colon
	call    ASC2LCD
    

	call    DisplayDay	;displays days
    
	movlw	0x40		;moves lcd pointer to bottom left corner
	call	LCDset

	movlw   ':		
	call    ASC2LCD
			
	call    RTC2LCD		;displays real time clock (HH:MM:SS)
     
	call	incDaysYears	

;;;;;;;;;;;;;;;;;;;;;;
;allows for button to stop program and display count for ms (x/1000)
;;;;;;;;;;;;;;;;;;;;
	
	call	Getkey		;allows for a button to stop program and display MS count

	sublw	7		;subtracts literally 7
	btfsc	STATUS,Z	;test to see if button was pressed
	goto	begin		;if not go back
	movlw	'.		;add decimale for ms display
	call	ASC2LCD		;displays decimal
	movf	Count5ms,W	;moves 5ms count into W
	movwf	WL		;moves into WL
	movlw	5		;bring literal 5 to W
	call	Mul8x8		;multiply 5 ms count by 5 to create ms
	movlw	100		;move 100 to W
	movwf	CH		;put it into CH to divide
	call	Div16x8	;divide the miliseconds by 100
	movwf	temp		;put remainder into temp
	movf	WL,W		;move result into W
	addlw	48		;add 48 to convert into ASCII
	call	ASC2LCD	;write the char to LCD
	movf	temp,W		;put remainder back into W
	clrf	WH		;clear the WH
	movwf	WL		;put remainder back into lower one
	movlw	10		;move 10 to CH 
	movwf	CH		;to divide by 10
	call	Div16x8	;divide remainder by 10 to get last two digits
	movwf	temp		;move remainder to temp
	movf	WL,W		;move result to W
	addlw	48		;add 48 to convert to ASCII
	call	ASC2LCD	;write to LCD
	movf	temp,W		;move remainder to W
	addlw	48		;add 48 to convert to ASCII
	call	ASC2LCD	;write to LCD
	return	
;;;;;;;;;;;;;;
;Main End Here
;;;;;;;;;;;;;;

nextYear
;Martin
;count up the year and clears days 
;year1 = century (00-99)
;year0 = year within the century (00-99)
	clrf	Days0		;clear days (two least significant digits) register (00-255) 
	clrf	Days1		;clear days (the most significant digit) register(255-364/5)
	
	incf	Year0		;increments year0 register (decades 00-99)
	call    testLeap	;checks for leap year
	movlw	100		;putting the year limit value into w (100)
	subwf	Year0,W		;;subtract the value in year0 from w
	btfss	STATUS,Z	;test for year 100
	return			;if no flag then keep counting
	clrf	Year0		;if at 100 clears decades (17-99)
	incf	Year1		;increments centuries/milleniums (20-99)
	movlw	100		;move literal 100 into W
	subwf	Year1,W		;subtract C/M-100
	btfsc	STATUS,Z	;test for year 9999
	clrf	Year1		;no way
	return			;cant be true


DisplayYear
;displays the year as a 4 digit number
	
	clrf	WH	;clear WH
	movf	Year1,W;put MSB of Years into W
	movwf	WL	;put years1 into WL
	
	movlw	10	
	movwf	CH	;put 10 into CH

	call	Div16x8	;divide Years1 by 10
	movwf	temp	;put remainder in temp
	movf	WL,W	;put result in W

	addlw	48	;add 48 to result to convert to ASCII
	call	ASC2LCD	;put first digit of year to LCD
	
	movf	temp,W	;put remainder into W
	addlw	48	;add 48 to convert to ASCII
	call	ASC2LCD	;write second digit to LCD
	
	clrf	WH	;clear WH
	movf	Year0,W;put Years0 to W
	movwf	WL	;put into WL to divide

	movlw	10	
	movwf	CH	;put 10 into CH

	call	Div16x8	;divide Years0 by 10
	movwf	temp	;put remainder in temp
	movf	WL,W	;put result in W

	addlw	48	;add 48 to result to convert to ASCII
	call	ASC2LCD	;put third digit of year to LCD
	
	movf	temp,W	;put remainder into W
	addlw	48	;convert fourth digit to ASCII
	call	ASC2LCD	;put fourth digit of year to LCD

	return

DisplayDay
;displays the day as a 3 digit number
	
	movf	Days0,W	;put first half of days into WL
	movwf	WL
	movf	Days1,W	;put second half od days into WH
	movwf	WH

	movlw	100
	movwf	CH	;put 100 into CH to divide by 100
	call	Div16x8	;divide days by 100
	movwf	temp	;put remainder in temp
	movf	WL,W	;put result in W
	addlw	48	;add 30 to result to convert to ASCII
	call	ASC2LCD	;write ascii to LCD
	movf	temp,W	;put remainder back into W
	movwf	WL	;then into WL for division

	movlw	10
	movwf	CH	;put 10 into CH
	call	Div16x8	;divide remainder of days by 10
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

		;1 01101110 - 366 
		;1 01101101 - 365

	movlw	%00000001 	;put 1 into w for 9th bit of day
	subwf	Days1,W		;check if 9th bit of days is set
	btfss	STATUS,Z	;if the bit is set skip next instruction
	goto	notZero	

	movlw	%01101101 	;put 
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






