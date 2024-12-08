#include <xc.h>
#include <pic18f4520.h>
#include<math.h>

#pragma config OSC = INTIO67 // Oscillator Selection bits
#pragma config WDT = OFF     // Watchdog Timer Enable bit
#pragma config PWRT = OFF    // Power-up Enable bit
#pragma config BOREN = ON    // Brown-out Reset Enable bit
#pragma config PBADEN = OFF  // Watchdog Timer Enable bit
#pragma config LVP = OFF     // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF     // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)
#define _XTAL_FREQ 1000000           // OSC frequency (1MHz)
#define THRESH 10           //thteshold on ADC vlaue to update LATB
int step = 0;       //totol 8 part
int seq_pos[8] = {1,3,5,7,9,11,13,15};
int seq_neg[8] = {0,2,4,6,8,10,12,14};
void SetBrightness(unsigned char dutyCycle) {
    unsigned int dc_value = (dutyCycle * 1023.0) / 100.0; // Duty Cycle max 1023 min 0
    CCPR1L = dc_value >> 2;                          // set high 8 bit
    CCP1CONbits.DC1B = dc_value & 0x03;              // set low 2 bit
    
}
void __interrupt(high_priority)H_ISR(){
    
    if(PIR1bits.ADIF){
        int value = (ADRESH<<2)|(ADRESL>>6);    //need to shift, because is left justified
        static int pre_value = -1;
        float dc =( 1.0- abs(512.0-value)/512.0)*100.0;     //ratial of brightness,0 to 100
        
        //prevent chage too fast, only chage LATB on value change > Threshold
        if(abs(value - pre_value) > THRESH){
            SetBrightness(dc/2.0);
            pre_value = value;
        }

        //clear flag bit
        PIR1bits.ADIF = 0;
        __delay_ms(30); 
        //step5 & go back step3
        /*
        delay at least 2tad
        */
        
        ADCON0bits.GO = 1;
    }
    return;
}
void PWMinitial(){
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;
    
    // Internal Oscillator Frequency, Fosc = 1 MHz, Tosc = 1 탎
//    OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    // CCP1/RC2 -> Output
    TRISC = 0;
    LATC = 0;
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /** 
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9b + 1) * 4 * 8탎 * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 0x9b;
    
    /**
     * 500 ~ 2400 탎 (-90 ~ 90, 1450 us = 0)
     * Duty cycle
     * = (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
     * = (0x0b*4 + 0b01) * 8탎 * 4
     * = 0.00144s ~= 1450탎
     * 
     */
}
void main(void) 
{
    PWMinitial();
    //configure OSC and port
    OSCCONbits.IRCF = 0b100; //1MHz
    TRISAbits.RA0 = 1;       //analog input port
    
    //step1
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
    ADCON1bits.PCFG = 0b1110; //AN0 analog input,else digital
    ADCON0bits.CHS = 0b0000;  //AN0 as analog input
    ADCON2bits.ADCS = 0b000;  //000 = Tosc (1Mhz < 2.86Mhsz)
    ADCON2bits.ACQT = 0b001;  //Tad = 2 u,s acquisition time = 2Tad = 4 > 2.4(min required)
    ADCON0bits.ADON = 1;
    ADCON2bits.ADFM = 0;    //left justified 
    

    //step2  Configure the ADC interrupt:
    PIE1bits.ADIE = 1;      //ADC enable
    PIR1bits.ADIF = 0;      //ADC flag
    INTCONbits.PEIE = 1;    //
    INTCONbits.GIE = 1;     //set Global interrupt enable bit


    //step3
    ADCON0bits.GO = 1;
    
    //set ouput (LED)
    TRISB = 0;
    LATB = 0;
    
    //main program
    while(1){
    }
    return;
}