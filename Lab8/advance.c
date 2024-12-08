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
#define _XTAL_FREQ 125000           // OSC frequency (125 kHz)

char state = 0;
int dir = 0;
void set_deg(int deg,unsigned char *r_8b,unsigned char *r_2b){
    int target = 500+((deg+90)*1900/180);
    for(int j = 0; j<256;j++){
        for(int i = 0;i<4;i++){
            //(CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
            //(0x0b*4 + 0b01) * 8탎 * 4
            if((j*4 + i)*8*4 >= target){
                *r_8b = (unsigned char)j;
                *r_2b = (unsigned char)i;
                
                return;
            }
        }
    }
    return;
}
void __interrupt() ISR(void) {
    unsigned char r_8b = 0;
    unsigned char r_2b = 0;
    __delay_ms(70);      // bouncing 
    //if isr trigered by btn
    if(INTCONbits.INT0IF){
        dir = 1;
        //celar flag bit
        INTCONbits.INT0IF = 0;
        return;
        
    }
    

     
        

     
    
}
void main(void)
{
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;
    
    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 탎
    OSCCONbits.IRCF = 0b001;
    
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
    //initial motor to -90 deg
    
    CCPR1L = 4;
    CCP1CONbits.DC1B = 0;
    //btn input
    TRISB =   0;
    TRISBbits.RB0 = 1;
    //interrupt
    RCONbits.IPEN = 0;      //intertupt piority
    INTCONbits.INT0IF = 0;       //Interrupt flag bit   
    INTCONbits.GIE = 1;         //set Global interrupt enable bit?
    INTCONbits.INT0IE = 1;        //set interrupt0 enable bit  (INT0 = RB0 pin)
    
    
    
    int r_8b =4;
    int r_2b = 0;
    while(1){
        __delay_ms(50); //avoid motor deg change  to fast 
        //-90 to 90     
        if(dir>0){
            r_2b++;
            if(r_2b ==4){
                r_2b = 0;
                r_8b+=dir;
            }
            if(r_8b == 19){
                r_8b = 18;
                r_2b = 3;
                dir = -1;
            }
            
            
        }
        //90 to -90
        else if(dir <0){
            r_2b--;
            if(r_2b == -1){
                r_2b = 3;
                r_8b--;
            }
            if(r_8b == 3){
                r_8b = 4;
                r_2b = 0;
                __delay_ms(50);
                CCPR1L = 4;
                CCP1CONbits.DC1B = 0;
                dir = 0; //stop motor to -90
            }
            
        }
        
        CCPR1L = r_8b & 0b11111111;
        CCP1CONbits.DC1B = r_2b & 0b00000011;
    }
    return;
}