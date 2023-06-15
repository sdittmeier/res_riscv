#include <stdint.h>

#define LED (*(volatile uint32_t*)0x02000000)

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

void putchar(char c)
{
    if (c == '\n')
        putchar('\r');
    reg_uart_data = c;
}

void print(const char *p)
{
    while (*p){
        putchar(*(p++));
        //p = p + 4;
    }
}

void delay() {
    for (volatile int i = 0; i < 12000000; i++)
        ;
}

int main() {
    // 9600 baud at 50MHz
    reg_uart_clkdiv = 5208;
 //   reg_uart_data = 72; // ascii "H"
//    putchar('H');
    const char p[] = "Hello world";
    //print(p);
//    print(message);
    while (1) {
        LED = 0xFF;	//you could think to add an LED PIO
        print(p);
        delay();
        LED = 0x00;
        delay();
    }
}
