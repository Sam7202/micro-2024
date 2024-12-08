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
void __interrupt(high_priority)H_ISR(){
    
    if(PIR1bits.ADIF){
        int value = (ADRESH<<2)|(ADRESL>>6);    //need to shift, because is left justified
        static int pre_value = -1;
        
        int part = 1024/8;
        step = value/part;
        //prevent chage too fast, only chage LATB on value change > Threshold
        if(abs(value - pre_value) > THRESH){
            if(pre_value > value){
                LATB = seq_neg[step];
            }
            else if(pre_value < value) {
                LATB = seq_pos[step];
            }
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

void main(void) 
{
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
    
    // set input
    TRISAbits.TRISA0 = 1;      // set  AN0?RA0????
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