/* CH572: blink PA11. Single translation unit, no #include (registers + delay only).
 * PA11 digital GPIO, push-pull output (matches GPIOA_ModeCfg GPIO_ModeOut_PP_5mA).
 */

 /* openocd must be run during blinking
  ../arduino_cli/data/packages/WCH/tools/openocd/ide_2.3.0_trimmed_packed/OpenOCD/OpenOCD/bin/openocd -f ../arduino_cli/data/packages/WCH/tools/openocd/ide_2.3.0_trimmed_packed/OpenOCD/OpenOCD/bin/wch-riscv.cfg
 */
 #include <stdint.h>

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

static void delay_cycles(volatile unsigned long n)
{
    while (n) {
        n--;
    }
}

int main(void)
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

    while (1) {
        ;
    }
}

