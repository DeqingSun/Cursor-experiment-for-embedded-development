/* CH572: blink PA11. Single translation unit, no #include (registers + delay only).
 * PA11 digital GPIO, push-pull output (matches GPIOA_ModeCfg GPIO_ModeOut_PP_5mA).
 */

 /* openocd must be run during blinking
  ../arduino_cli/data/packages/WCH/tools/openocd/ide_2.3.0_trimmed_packed/OpenOCD/OpenOCD/bin/openocd -f ../arduino_cli/data/packages/WCH/tools/openocd/ide_2.3.0_trimmed_packed/OpenOCD/OpenOCD/bin/wch-riscv.cfg
  
  ../arduino_cli/data/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/riscv-wch-elf-gdb build/ch572_pa11_blink.elf
  target remote localhost:3333
  
*/
#include <stdint.h>

extern "C" {
__attribute__((section(".highcode_init")))
void highcode_init(void)
{
}
}

__attribute__((noinline, used)) static void jump_isprom_strip()
{
    if (*((const uint16_t *)(0x00078000 + 0x88 + 0x10a + 0xa)) == 0x8905) { //    0007819c: 0589 c.andi a0,0x1
        /* Word copy like WCH FLASH_ROM_READ: flash ROM reads are naturally 32-bit. */
        volatile uint32_t *dst = (volatile uint32_t *)0x20000000;
        const uint32_t *src = (const uint32_t *)(0x00078000 + 0x88);
        const uint32_t words = 0x2500u >> 2;
        for (uint32_t i = 0; i < words; ++i) {
            dst[i] = src[i];
        }

        //0x78192 is ReadPB11. 0007819c: 0589 c.andi a0,0x1
        *(int16_t*)(0x2000010a + 0xa) = 0x4505; //li a0,1, patch PB11 (option byte is not read correctly) detection
        
        volatile uint32_t *clr = (volatile uint32_t *)0x200024f0;
        for (uint32_t i = 0; i < (0x0560u >> 2); ++i) {
            clr[i] = 0;
        }

        //0x200018c2 -> 0x7994A, main of bootloader 
        asm( "la gp, 0x20002ce8\n"
            ".option arch, +zicsr\n"
            "li t0, 0x200018c2\n"
            "jr t0\n");
        //   "csrw mepc, t0\n" // __set_MEPC is not available here
        //   "mret\n");
    }
}

extern "C" {
    void TMR_IRQHandler(void) __attribute__((interrupt("WCH-Interrupt-fast"))) __attribute__((section(".highcode")));
    void TMR_IRQHandler(void) {
        static bool level = false;
        static int counter = 0;
        static int toggleCount = 0;
        counter++;
        if (counter >= 10) { // toggle every 10 timer interrupts, about 100ms with current timer settings
          level = !level;
          counter = 0;
          toggleCount++;
          if (toggleCount == 20) { // after 2 seconds, jump to ISP
            *((unsigned long*)(0xE000E180u)) = (1 << ((uint32_t)(24) & 0x1F)); // PFIC_DisableIRQ(TMR_IRQn);
            asm volatile("fence.i");
            //PFIC_DisableIRQ(TMR_IRQn);
            *((unsigned long*)(0x40002402u)) = 0; // TMR_INTER_EN = 0;
            //R8_TMR_INTER_EN = 0;
            jump_isprom_strip();
          }
        }
        if (level) {
            *((unsigned long*)(0x400010A8u)) |= (1<<11); //PA_OUT |= (1<<11);
        } else {
            *((unsigned long*)(0x400010ACu)) |= (1<<11); //PA_CLR |= (1<<11);
        }

  

        // PFIC_DisableIRQ(TMR_IRQn);
        // *((unsigned long*)(0x40002402u)) = 0; // TMR_INTER_EN = 0;
        // jump_isprom_strip();

        *((unsigned long*)(0x40002406u)) = 0x01; // TMR_INT_FLAG = RB_TMR_IF_CYC_END;
    }
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

    // *((unsigned long*)(0x4000240Cu)) = 60000; // TMR_CNT_END = 60000;
    // *((unsigned long*)(0x40002400u)) = 1<<1; // TMR_CTRL_MOD = RB_TMR_ALL_CLEAR;
    // *((unsigned long*)(0x40002400u)) = 1<<2; // TMR_CTRL_MOD = RB_TMR_COUNT_EN;
    // *((unsigned long*)(0x40002402u)) = 0x01; // TMR_INTER_EN = RB_TMR_IE_CYC_END;
    // *((unsigned long*)(0xE000E100u)) = (1 << ((uint32_t)(24) & 0x1F)); // PFIC_IENR1, PFIC_EnableIRQ(TMR_IRQn);

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

