#include <xc.h>
#include "uart.h"
//#define TMR2_prescaler = 16
void set_deg(int deg,int *r_8b,int *r_2b){

    if(deg<-90) deg = 90;
    if(deg>90) deg = 90;
    int target = 500 + ((deg + 90.0) / 180.0) * 1900.0;
    // PWM 
    /* * Duty cycle= (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)* = (0x0b*4 + 0b01) * 2탎 * 16 */

    int total_pwm = target / (2 * 16);  // get 
    *r_8b = total_pwm / 4;              // high 8 bit
    *r_2b = total_pwm % 4;      
    CCPR1L = *r_8b & 0b11111111;
    CCP1CONbits.DC1B = *r_2b & 0b00000011;
    return;
}
void CCP1_Initialize() {
    //need to modify----------------------------------------------------
    // Timer2 -> On, 
    T2CONbits.TMR2ON = 1;   // Enable Timer2
    T2CONbits.T2CKPS = 0b11;  // Prescaler = 16

    
    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 탎
//    OSCCONbits.IRCF = 0b001;
    //--------------------------------------------------------
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    // CCP1/RC2 -> Output
    TRISC = 0b11111011;
    LATC = 0;
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /** 
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9b + 1) * 4 * 8탎 * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 155;
    
    /**
     * 500 ~ 2400 탎 (-90 ~ 90, 1450 us = 0)
     * Duty cycle
     * = (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
     * = (0x0b*4 + 0b01) * 8탎 * 4
     * = 0.00144s ~= 1450탎
     * 
     */
    //initial motor to -90 deg
    CCPR1L = 4;
    CCP1CONbits.DC1B = 0;
//     CCPR1L = 39;            // Set duty cycle (50%)
//     CCP1CONbits.DC1B = 0;   // Lower 2 bits of duty cycle
//    int* a, *b;
//    setdeg(0,a,b);
    
    //interupt of CCP(no need)

}
