#include "p18f4520.inc"

; CONFIG1H
  CONFIG  OSC = INTIO67         ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)
 
STATE EQU 0x20		;set variable:  STATE
COUNTER EQU 0x21	;set variable:  COUNTER
INVERSE EQU 0x22
LIMIT EQU 0x23  
    L1 EQU 0x14
    L2 EQU 0x15 
    org 0x00
    
Light macro counter
    ;put 4 bit into LATA 0,1,2,3
    CLRF LATA
    MOVLW b'00001111'
    ANDWF counter,w
    BTFSC WREG,0    ;if w = 0, don't set lata3
	BSF LATA,3
    
    BTFSC WREG,1    ;if w = 0, don't set lata2
	BSF LATA,2
    
    BTFSC WREG,2    ;if w = 0, don't set lata1
	BSF LATA,1
    
    BTFSC WREG,3    ;if w = 0, don't set lata0
	BSF LATA,0
endm    

DELAY macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles
    LOOP2:
    MOVLW num1          
    MOVWF L1  
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    NOP                 ; busy waiting
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1        
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2           
endm    
goto Initial
ISR:                    
    org 0x08            
    ; ckek if is from btn
    BTFSS INTCON, INT0IF ; check INTCON  INT0IF bit = 1
    BRA CHECK_TIMER      ; ???????????
    ; INT0 ISA
    DELAY d'50',d'20'		;bouncing problem
    INCF STATE
    MOVLW 0x06
    CPFSGT STATE	;if state ==7
	goto ret_isr	
    CLRF STATE		;back to state 1
    INCF STATE
    
    ret_isr:
	BCF INTCON, INT0IF   ; clear INT0 flag
	RETFIE

CHECK_TIMER:
    ; timer2 interrupt
    BTFSS PIR1, TMR2IF   ; ?? Timer2 ??????? 1
	RETFIE               ; ?????????
    ; Timer2 ISR
    INCF    COUNTER
    BTFSS INVERSE ,0	    ;if now is not inverse ret
	bra ret_timer
    DECF    COUNTER
    DECF    COUNTER
    ret_timer:
    BCF PIR1, TMR2IF     ; clear flag bit
    RETFIE

    
Initial:			
    MOVLW 0x0F
    MOVWF ADCON1		; Digitial I/O 
    
    CLRF TRISA
    CLRF LATA
    CLRF TRISB	    
    BSF TRISB,  0		;set RB0 as input
    BSF RCON, IPEN		;eable  priority interrupt
    BCF INTCON, INT0IF		; clear Interrupt flag bit
    BSF INTCON, GIE		; set Global interrupt enable bit
    BSF INTCON, INT0IE		; set interrupt0 enable bit  (INT0=RB0 pin)
    BCF PIR1, TMR2IF		; ????TIMER2??????????TMR2IF?TMR2IE?TMR2IP?
    BSF IPR1, TMR2IP		;priority
    BSF PIE1 , TMR2IE		;enable TMR2
    MOVLW b'11111111'	        ; ?Prescale?Postscale???1:16???????256??????TIMER2+1
    MOVWF T2CON		; ???TIMER?????????/4????????
;    MOVLW D'122'		; ???256 * 4 = 1024?cycles???TIMER2 + 1
;    MOVWF PR2			; ??????250khz???Delay 0.5?????????125000cycles??????Interrupt
				; ??PR2??? 125000 / 1024 = 122.0703125? ???122?
    MOVLW D'00100000'
    MOVWF OSCCON	        ; clock as 250kHz
    
   
    
check_state:
    BCF PIE1 , TMR2IE
    CLRF TMR2             ; clear tm2 count
    CLRF COUNTER		;start from 0
    Light COUNTER
    CLRF INVERSE
   
    
    MOVLW d'1'
    SUBWF STATE,w
    BZ ss1
    MOVLW d'2'
    SUBWF STATE,w
    BZ ss2
    MOVLW d'3'
    SUBWF STATE,w
    BZ ss3
    MOVLW d'4'
    SUBWF STATE,w
    BZ ss4
    MOVLW d'5'
    SUBWF STATE,w
    BZ ss5
    MOVLW d'6'
    SUBWF STATE,w
    BZ ss6
    BRA check_state
;s1,s1    
ss1:
    MOVLW D'61'		;set 0.25s
    MOVWF PR2	 
    BSF PIE1 , TMR2IE
    CLRF COUNTER
    loop_c1:
	MOVLW d'1'	    ;current state ==1 ,if not goto see which state
	SUBWF STATE,w
	BNZ check_state
	Light COUNTER
	MOVLW d'8'
	SUBWF COUNTER,w
	BNZ loop_c1
    ;if to count to 8, loop back to ss1
    goto check_state
    
ss2:
    MOVLW D'121'		;set 0.65s
    MOVWF PR2	
    BSF PIE1 , TMR2IE
;    CLRF COUNTER
    loop_c2:
	MOVLW d'2'	    ;current state ==5 ,if not goto see which state
	SUBWF STATE,w
	BNZ check_state
	Light COUNTER
	MOVLW d'16'
	SUBWF COUNTER,w
	BNZ loop_c2
    ;if to count to 16, loop back to ss2
    goto check_state
ss3:
    BSF INVERSE,0
    MOVLW D'62'		;set 0.25s
    MOVWF PR2	
    BSF PIE1 , TMR2IE
    MOVLW d'15'
    MOVWF COUNTER		;start from 15
    loop_c3:
	MOVLW d'3'	    ;current state ==6 ,if not goto see which state
	SUBWF STATE,w
	BNZ mid_b
	Light COUNTER
	MOVLW 0xFF
	SUBWF COUNTER,w
	BNZ loop_c3
    ;if to count to 16, loop back to ss3
    goto check_state   
mid_b:    
    BRA check_state
ss4:
    MOVLW D'121'		;set 0.5s
    MOVWF PR2	
    BSF PIE1 , TMR2IE	    ;start timer
    CLRF COUNTER

    loop_c4:
	MOVLW d'4'	    ;current state ==4 ,if not goto see which state
	SUBWF STATE,w
	BNZ check_state
	Light COUNTER
	MOVLW d'8'
	SUBWF COUNTER,w
	BNZ loop_c4
    ;if to count to 8, loop back to zero
    goto check_state
ss5:
    MOVLW D'61'		;set 0.25s
    MOVWF PR2	
    BSF PIE1 , TMR2IE		;start timer
;    CLRF COUNTER		;start from 0
    
    loop_c5:
	MOVLW d'5'	    ;current state ==5 ,if not goto see which state
	SUBWF STATE,w
	BNZ mid_b
	Light COUNTER
	MOVLW d'16'
	SUBWF COUNTER,w
	BNZ loop_c5
    ;if to count to 16, loop back to ss2
    goto check_state
ss6:
    BSF INVERSE,0
    MOVLW D'122'		;set 0.5s
    MOVWF PR2	
    BSF PIE1 , TMR2IE
    MOVLW d'15'
    MOVWF COUNTER		;start from 15
    loop_c6:
	MOVLW d'6'	    ;current state ==6 ,if not goto see which state
	SUBWF STATE,w
	BNZ mid_b
	Light COUNTER
	MOVLW 0xFF
	SUBWF COUNTER,w
	BNZ loop_c6
    ;if to count to 16, loop back to ss3
    goto check_state
end