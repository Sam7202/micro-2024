#include <xc.h>
#include <pic18f4520.h>

void INTERRUPT_Initialize (void)
{
    RCONbits.IPEN = 1;      //enable Interrupt Priority mode
    INTCONbits.GIEH = 1;    //enable high priority interrupt
    INTCONbits.GIEL = 1;     //enable low priority interrupt
    //for btn interrupt
    INTCONbits.INT0E = 0;    //enable btn(INT0) interrupt
    INTCON2bits.INTEDG0 = 0;   // Trigger on falling edge
    //priority
    IPR1bits.CCP1IP = 1;    //ccp1 as high priorty
    IPR1bits.ADIP = 1;      //ADC
    IPR1bits.TMR2IP = 1;
    IPR1bits.TMR1IP = 1;    //timer
   
    
}

