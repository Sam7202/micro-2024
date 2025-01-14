#include <xc.h>

void ADC_Initialize(void) {
    TRISAbits.RA0 = 1; 		// Set as an0 as input port
    ADCON1 = 0x0e;  	// Ref vtg is VDD & Configure pin as analog pin (00001110), and only AN0 as analog input
    ADCON0bits.CHS = 0b0000;  //AN0 as analog input
    ADCON0bits.ADON = 1;
    ADCON2bits.ADFM = 1 ;          // Right Justify
    ADCON2bits.ADCS = 0b000;   // ADC clock = Fosc/2(Tad)
    ADCON2bits.ACQT = 0b001;   // Acquisition time = 2 TAD (>= 2.45 µs)
    ADRESH=0;  			// Flush ADC output Register
    ADRESL=0;  
    
     //step2  Configure the ADC interrupt:
    PIE1bits.ADIE = 0;      //ADC enable
    PIR1bits.ADIF = 0;      //ADC flag




    //step3
    ADCON0bits.GO = 1;
}
//using interrupt instead not using this
int ADC_Read()
{
    int digital;
    
    
    while(ADCON0bits.GO_nDONE==1);

    digital = (ADRESH<<8) | (ADRESL);
    return(digital);
}