#include "setting_hardaware/setting.h"
#include <stdlib.h>
#include "stdio.h"
#include "string.h"
#include <math.h>
#include <pic18f4520.h>
// using namespace std;
#define _XTAL_FREQ 500000
#define THRESH 10          //thteshold on ADC vlaue to update LATB
char str[20];
int num = 0;
int count_num = 0;
int step = 20;       //totol 14106058 8 part
int seq[8] = {1,4,1,0,6,0,5,8};
int deg = 0;

//
void Mode1(){   // Todo : Mode1 
    set_binary_bulb(num);
    return ;
}
//bonus
void Mode2(){   // Todo : Mode2 
    set_binary_bulb(count_num);
    return ;
}
void check_sensor(){
    int r_8b,r_2b;
    //RB0 = right sensor(if 1 need deg++)
    //RB1 = left sensor
    if(PORTBbits.RB0 == 1 && PORTBbits.RB1 == 1){
        set_binary_bulb(0b1111);
        UART_Write_Text("lr\n\r");
    }
    //right hvave people,  left doesn't
    else if(PORTBbits.RB0 == 1 && PORTBbits.RB1 ==0){
        if(deg<85)
            deg+=step;
//        set_binary_bulb(0b1100);
        UART_Write_Text("r\n\r");
    }
    else if(PORTBbits.RB0 == 0 && PORTBbits.RB1 ==1){
        if(deg>-85)
            deg-=step;
//        set_binary_bulb(0b0011);
        UART_Write_Text("1\n\r");
    }
    //none of sensor working
    else{
            set_binary_bulb(0);
    }
    set_deg(deg,&r_8b,&r_2b);
    __delay_ms(1000);
    
}
void adc_action(){
    //step4   
        int value = ADC_Read();  
        int part = 1024/8;
        
        
        static int pre_value = -1;
       
        int r_8b,r_2b;
        //prevent chage too fast, only chage LATB on value change > Threshold
        if(abs(value - pre_value) > THRESH){
            pre_value = value;
            set_binary_bulb(value/part);   
            
            //set deg of motor
             //maping 1024 to -90 90
            int deg  = -90.0 + value/1024.0 *180.0;
            set_deg(deg,&r_8b,&r_2b);
            
            CCPR1L = r_8b & 0b11111111;
            CCP1CONbits.DC1B = r_2b & 0b00000011;
            UART_Write_Text("set deg\n\r");
        }
        
        
        //step5 & go back step3
        /*
        delay at least 2tad
        */
//        __delay_ms(1000);
        ADCON0bits.GO = 1;
//        UART_Write_Text("ADC triggered from main\n\r");
}
void main(void) 
{
    
    SYSTEM_Initialize() ;
  
    while(1) {
      check_sensor();
        
//      
    }
    return;
}
char c ;
void __interrupt(high_priority) Hi_ISR(void)
{   
    //UART TXIREG no use
    if(PIR1bits.TXIF){   
        
    }
    //
    if(PIR1bits.RCIF)
    {  
        if(RCSTAbits.OERR)
        {
            CREN = 0;
            Nop();
            CREN = 1;
        }
        c= MyusartRead();
        if(c =='\r'){
            UART_Write('\n');
        }
        UART_Write(c);
        //light up : advance
        if(c>='0' && c<='9'){
            num = c-'0';
//            set_timer_continue();
            count_num = 0;  //reset to 0
        }
       return;
       
    }
   
    //isr of btn
    if(INTCONbits.INT0F){
        //bouncing problem
        
        T1CONbits.TMR1ON = 0;    // Stop Timer1
        INTCONbits.INT0F = 0;
        set_binary_bulb(15);
        
//        __delay_ms(100);
        UART_Write_Text("btn pressed\n\r");
    }
    
    //TMR1
    else if (PIR1bits.TMR1IF) {  // Check if Timer1 interrupt occurred
        UART_Write_Text("Timer1 Interrupt Triggered\n\r");
        //task
        reset_TMR1();      // Reload Timer1 low byte
        count_num++;
        //if < 0 reset to  original num
        if(count_num == num+1){
            count_num = 0;
        }
        PIR1bits.TMR1IF = 0;   // Clear interrupt flag

    }
//    //ADC isr
//    else if(PIR1bits.ADIF){
//        //clear flag bit
//        PIR1bits.ADIF = 0;
//        adc_action();
////        UART_Write_Text("ADC triggered\n\r");
//    }
    

    return;
    
}
// void interrupt low_priority Lo_ISR(void)
void __interrupt(low_priority)  Lo_ISR(void)
{   
   
//   // process other interrupt sources here, if required
    return;
}