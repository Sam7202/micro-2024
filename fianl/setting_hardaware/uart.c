#include <xc.h>
    //setting TX/RX
#include<string.h>
char mystring[20];
int lenStr = 0;

void UART_Initialize() {
//    test_uart_init();
    /*       TODObasic   dds
           Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
     */      
    TRISCbits.TRISC6 = 1;            
    TRISCbits.TRISC7 = 1;            
    
    //  Setting baud rate
    /*(BRG8)
     * target Boundrate = 1200
     * SPBRG = Fosc / (64*Boundrate) -1
     * (BRG 16)
     * SPBRG = Fosc / (16*Boundrate) -1
     */
//    TXSTAbits.SYNC = 0;           
//    BAUDCONbits.BRG16 = 0;          
//    TXSTAbits.BRGH = 0;
//    SPBRG = 51;     
    //set 1200 br
    TXSTAbits.SYNC = 0;           
    BAUDCONbits.BRG16 = 1;          
    TXSTAbits.BRGH = 0;
    SPBRG = 25;     
    
   //   Serial enable
    RCSTAbits.SPEN = 1;              
    TXSTAbits.TXEN = 1;           
    RCSTAbits.CREN = 1;             
    //interrupt ENABLE
    PIE1bits.TXIE = 0;       
    PIE1bits.RCIE = 1; 
     //interrupt flag
    PIR1bits.TXIF = 0;
    PIR1bits.RCIF = 0;
    //priority
    IPR1bits.TXIP = 0;             
    IPR1bits.RCIP = 1;    
    return;
}

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);
    TXREG = data;              //write to TXREG will send data 
    return;
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++){

        UART_Write(text[i]);
    }
    return;
}

void ClearBuffer(){
    for(int i = 0; i < 10 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

char MyusartRead()
{
    /* TODObasic: try to use UART_Write to finish this function */
    if (RCSTAbits.OERR) {
        RCSTAbits.CREN = 0; // ????
        RCSTAbits.CREN = 1; // ??????
    }
    return RCREG;
}

char* GetString(){
    strcpy(mystring, "m3");
    return mystring;
}


