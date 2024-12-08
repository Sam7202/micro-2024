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
  COUNTER EQU 0x21	;set variable  count
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
goto Initial			    
ISR:				
    org 0x08                ; ????: ?0.5??????interrupt
    INCF COUNTER
    BCF PIR1, TMR2IF        ; ??????TMR2IF?? (??flag bit)
    RETFIE
    
Initial:			
    MOVLW 0x0F
    MOVWF ADCON1
    CLRF TRISA
    CLRF LATA
    BSF RCON, IPEN
    BSF INTCON, GIE
    BCF PIR1, TMR2IF		; ????TIMER2??????????TMR2IF?TMR2IE?TMR2IP?
    BSF IPR1, TMR2IP
    BSF PIE1 , TMR2IE
    MOVLW b'11111111'	        ; Prescale,Postscale set to 1:16, every 256 cycle will increase TIMER2 by 1
    MOVWF T2CON		; ???TIMER?????????/4????????
;    MOVLW D'122'		; ???256 * 4 = 1024?cycles???TIMER2 + 1
;    MOVWF PR2			; ??????250khz???Delay 0.5?????????125000cycles??????Interrupt
				; PR2= 125000 / 1024 = 122.0703125
    MOVLW D'00100000'
    MOVWF OSCCON	        ; clock as 250kHz
    
	    
state_1:;0 to 3
    MOVLW D'61'		;set 0.25s
    MOVWF PR2	
    loop_c1:
	Light COUNTER
	MOVLW d'4'
	SUBWF COUNTER,w
	BNZ loop_c1
    ;finsh loop can move to state 2

state_2:;4 to 7
    MOVLW D'122'		;set 0.5s
    MOVWF PR2	
    loop_c2:
	Light COUNTER
	MOVLW d'8'
	SUBWF COUNTER,w
	BNZ loop_c2
    ;finsh loop can move to state 3

state_3:; 8 to 15
    MOVLW D'244'		;set 1s
    MOVWF PR2	
    loop_c3:
	Light COUNTER
	MOVLW d'16'
	SUBWF COUNTER,w
	BNZ loop_c3
    ;finsh loop can move to state 1
    CLRF COUNTER	;back counter to 0
    goto state_1
end