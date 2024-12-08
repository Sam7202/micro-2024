#include <xc.h>
#include <xc.h>
#include <pic18f4520.h>
#include <stdio.h>
#pragma config OSC = INTIO67    // Oscillator Selection bits
#pragma config WDT = OFF        // Watchdog Timer Enable bit 
#pragma config PWRT = OFF       // Power-up Enable bit
#pragma config BOREN = ON       // Brown-out Reset Enable bit
#pragma config PBADEN = OFF     // Watchdog Timer Enable bit 
#pragma config LVP = OFF        // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF        // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)

#define _XTAL_FREQ 1000000 

void PWM_Init(void) {
    PR2 = 249;                     // ???? (????? 20ms)
    CCPR1L = 0;                    // ?? Duty Cycle ? 0
    CCP1CONbits.CCP1M = 0b1100;    // PWM ??
    T2CONbits.T2CKPS = 0b11;       // ?? Timer2 ???? 16
    T2CONbits.TMR2ON = 1;          // ?? Timer2
    while (!PIR1bits.TMR2IF);      // ?? Timer2 ??
    TRISC = 0;
    LATC = 0;       //set output
}

void SetBrightness(unsigned char dutyCycle) {
    unsigned int dc_value = (dutyCycle * 1023.0) / 100.0; // Duty Cycle max 1023 min 0
    CCPR1L = dc_value >> 2;                          // set high 8 bit
    CCP1CONbits.DC1B = dc_value & 0x03;              // set low 2 bit
    
}

void main(void) {
    OSCCONbits.IRCF = 0b100; //1MHz
    PWM_Init();
    
    int limit = 50;
    while (1) {
        for (unsigned char i = 0; i <= limit; i += 1) {
            SetBrightness(i);       // ????? 0% ? 100%
            __delay_ms(50);
        }
        for (unsigned char i = limit; i > 0; i -= 1) {
            SetBrightness(i);       // ????? 100% ? 0%
            __delay_ms(50);
        }
    }
}
