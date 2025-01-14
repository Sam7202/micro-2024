#include <xc.h>
#define TMR1_PRELOAD 3035
void TMR0_Initialize() {
    // Configure Timer0
    T0CONbits.TMR0ON = 0;    // Stop Timer0
    T0CONbits.T08BIT = 0;    // Set Timer0 to 16-bit mode
    T0CONbits.T0CS = 0;      // Use internal clock source (FOSC/4)
    T0CONbits.PSA = 0;       // Enable prescaler
    T0CONbits.T0PS = 0b111;  // Set prescaler to 1:256
    TMR0H = 0x00;            // Clear the high byte of Timer0
    TMR0L = 0x00;            // Clear the low byte of Timer0
    T0CONbits.TMR0ON = 1;    // Start Timer0
}

void TMR1_Initialize() {
    // Configure Timer1
    T1CONbits.TMR1ON = 0;    // Stop Timer1
    T1CONbits.RD16 = 1;      // Enable 16-bit read/write mode
    T1CONbits.TMR1CS = 0;    // Use internal clock source (FOSC/4)
    T1CONbits.T1CKPS = 0b11; // Set prescaler to 1:8
    TMR1H = 0x00;            // Clear the high byte of Timer1
    TMR1L = 0x00;            // Clear the low byte of Timer1
    PIR1bits.TMR1IF = 0;     // Clear Timer1 interrupt flag
    PIE1bits.TMR1IE = 1;     // Enable Timer1 interrupt
    
    TMR1H = (TMR1_PRELOAD >> 8) & 0xFF; // Set high byte of preload
    TMR1L = TMR1_PRELOAD & 0xFF;        // Set low byte of preload
    
    T1CONbits.TMR1ON = 0;    // Start Timer1
}

void TMR2_Initialize() {
    // Configure Timer2
    T2CONbits.TMR2ON = 0;    // Stop Timer2
    T2CONbits.T2CKPS = 0b11; // Set prescaler to 1:16
    T2CONbits.T2OUTPS = 0b1111; // Set postscaler to 1:16
    PR2 = 255;               // Set the match value for Timer2
    TMR2 = 0x00;             // Clear the Timer2 counter
    PIR1bits.TMR2IF = 0;     // Clear Timer2 interrupt flag
    PIE1bits.TMR2IE = 1;     // Enable Timer2 interrupt
    T2CONbits.TMR2ON = 1;    // Start Timer2
}
void reset_TMR1(){
    TMR1H = (TMR1_PRELOAD >> 8) & 0xFF; // Set high byte of preload
    TMR1L = TMR1_PRELOAD & 0xFF;        // Set low byte of preload
}
void set_timer_continue(){
    
    reset_TMR1();
    T1CONbits.TMR1ON = 1;    // Start Timer1
}