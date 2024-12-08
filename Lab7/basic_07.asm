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

    L1 EQU 0x14
    L2 EQU 0x15
    org 0x00
    STATE EQU 0x23
    COUNTER EQU 0x21
    FINISH EQU 0x25
DELAY macro num1, num2, running_state 
    local LOOP1 
    local LOOP2
    MOVLW num2
    MOVWF L2
    LOOP2:
	MOVLW num1
	MOVWF L1
    LOOP1:
	NOP
	MOVLW running_state	;check if running state == real state
	SUBWF STATE,w
	    BNZ main		; if not equ, renew state
	
	DECFSZ L1, 1
	BRA LOOP1
	DECFSZ L2, 1
	BRA LOOP2
endm
DELAY1 macro num1, num2
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
; ??????????main??????????RB0???????interrupt???ISR??
; ISR??????????RA?????Delay?0.5?????

goto Initial			; ????????????ISR????????
ISR:				; Interrupt????????????
    org 0x08			
;    DELAY1 d'111',d'100' 
    INCF STATE
    MOVLW 0x03
    CPFSGT STATE	;if state ==4 
	goto ret_isr	
    CLRF STATE		;back to state 1
    INCF STATE
    ret_isr:
	CLRF FINISH	    ;set finish = 0(false)
	BCF INTCON, INT0IF
 
	RETFIE                    ; ??ISR?????????????????GIE??1??????interrupt????
    
    
Initial:				; ????????
    MOVLW 0x0F
    MOVWF ADCON1		; Digitial I/O 
    
    CLRF TRISA
    CLRF TRISB
    BSF TRISB,  0
    CLRF LATA
    BCF RCON, IPEN
    BCF INTCON, INT0IF		; ??Interrupt flag bit??
    BSF INTCON, GIE		; set Global interrupt enable bit??
    BSF INTCON, INT0IE		; set interrupt0 enable bit ?? (INT0 = RB0 pin?????)
    
  
    CLRF STATE			;set state = 0
    
main:
    ;check which state
    MOVLW 0x00	    ;if state  0
    SUBWF STATE,w
    BZ state_0
    
    MOVLW 0x01	    ;if state  1
    SUBWF STATE,w
    BZ state_1
    
    MOVLW 0x02	    ;if state  2
    SUBWF STATE,w
    BZ state_2
    
    MOVLW 0x03	    ;if state  3
    SUBWF STATE,w
    BZ state_3
    
    goto main
state_0:
    
    CLRF COUNTER
    CLRF LATA
    goto main
   
state_1:
    MOVF FINISH,w	;if finished(1), to main
    BNZ main
    
    MOVLW 0x04	    ; i =4
    MOVWF 0x20
    CLRF LATA
    CLRF COUNTER
    loop_c1:
	Light COUNTER
	DELAY  d'90' , d'180',d'1'	
	INCF COUNTER
	DECF 0x20		;
	BNZ loop_c1
    ;finsh loop
    CLRF LATA
    INCF FINISH
    goto main
;    goto idle
state_2:
    MOVF FINISH,w	;if finished(1), to main
    BNZ main
    MOVLW 0x08	    ; i =8
    MOVWF 0x20
    CLRF LATA
    CLRF COUNTER
    loop_c2:
	Light COUNTER
	DELAY  d'90' , d'180',d'2'	
	INCF COUNTER
	DECF 0x20		;i--
	BNZ loop_c2
    ;finsh loop
    CLRF LATA				    
    INCF FINISH				    
    goto main

state_3:
    MOVF FINISH,w	;if finished(1), to main
    BNZ main
    MOVLW d'16'	    ; i =16
    MOVWF 0x20
    CLRF LATA			    ;finsh loop
    CLRF COUNTER
    loop_c3:
	Light COUNTER
	DELAY  d'90' , d'180',d'3'	
	INCF COUNTER
	DECF 0x20		;i--
	BNZ loop_c3
    CLRF LATA			    ;finsh loop
    INCF FINISH
    goto main

end