/*
 * File:   bulb.c
 * Author: user
 *
 * Created on 2024?12?18?, ?? 12:18
 */


#include <xc.h>
#include <pic18f4520.h>
#define _XTAL_FREQ  125000
void initial_bulb(){

    TRISD = 0b00000000; 
    LATD= 00001111;
    return;
    
}
void set_binary_bulb(int num){
//    LATA &= 0x00000001;      // Clear bits 1 to 7
//    LATA |= ((num & 0x0F)<<1); // Set bits 1 to 4 based on 'num'
    LATD = num;
    return;
}
void test_bulb(){
    LATD = 0xff;

    __delay_ms(1000);
    LATD = 0;

    __delay_ms(1000);
}
    
