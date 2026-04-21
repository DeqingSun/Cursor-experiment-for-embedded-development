/*
 * This demo jumps to the built-in bootloader, so it can be programmed over ISP.
 * Most ch5xx dev boards come with a "boot" or "download" button, when this
 * is pressed the chip resets and executes the ISP bootloader which presents
 * itself on USB to the host.
 * NOTE: if "FUNCONF_USE_USBPRINTF" is used, a call to USBFSReset() is needed
 *       just before jump_isprom()
 */

/*

export PATH="/Users/deqinguser/Library/Arduino15/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin:$PATH"

*/

#include "ch32fun.h"

#define PIN_LED    PA11
#define PIN_BUTTON PA1
#define BUTTON_PRESSED funDigitalRead( PIN_BUTTON )


void blink(int n) {
	for(int i = n-1; i >= 0; i--) {
		funDigitalWrite( PIN_LED, FUN_LOW ); // Turn on LED
		Delay_Ms(100);
		funDigitalWrite( PIN_LED, FUN_HIGH ); // Turn off LED
		if(i) Delay_Ms(100);
	}
}

static void delay_cycles(volatile unsigned long n)
{
    while (n) {
        n--;
    }
}


//static inline void jump_isprom_strip()
static void jump_isprom_strip()
{
	volatile uint8_t *dst = (volatile uint8_t *)0x20000000;
	const uint8_t *src = (const uint8_t *)(0x0003c000 + 0xc0);
	for (uint32_t index = 0; index < 0x2000; ++index) {
		dst[index] = src[index];
	}

	*(int32_t*)(0x20000100 + 0xc) = 0x00014505; // nop \n li a0,1, patch PA1 detection
	
	for (uint32_t index = 0; index < 0x0474; ++index) {
		((volatile uint8_t *)0x20001ba0)[index] = 0;
	}

	asm( "la gp, 0x20002398\n"
		 ".option arch, +zicsr\n"
		 "li t0, 0x20001196\n"
		 "csrw mepc, t0\n" // __set_MEPC is not available here
		 "mret\n");

}

int main()
{

	    /* Output push-pull 5 mA drive. */
    *((unsigned long*)(0x400010B4u)) &= ~(1<<11);  //PA_PD_DRV &= ~(1<<11);
    *((unsigned long*)(0x400010A0u)) |= (1<<11); //PA_DIR |= (1<<11);

    for (int i=0;i<10;i++) {
        *((unsigned long*)(0x400010A8u)) |= (1<<11); //PA_OUT |= (1<<11);
        delay_cycles(10000ul);
        *((unsigned long*)(0x400010ACu)) |= (1<<11); //PA_CLR |= (1<<11);
        delay_cycles(10000ul);
    }

	
	jump_isprom_strip();
	// SystemInit();

	// funGpioInitAll(); // no-op on ch5xx

	// funPinMode( PIN_LED,    GPIO_CFGLR_OUT_10Mhz_PP ); // Set PIN_LED to output
	// funPinMode( PIN_BUTTON, GPIO_CFGLR_IN_PUPD ); // Set PIN_BUTTON to input
	// blink(10);
	
	// while(1)
	// {

	// }
}
