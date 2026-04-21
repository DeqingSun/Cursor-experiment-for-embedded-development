/* CH572: blink PA11. Single translation unit, no #include (registers + delay only).
 * PA11 digital GPIO, push-pull output (matches GPIOA_ModeCfg GPIO_ModeOut_PP_5mA).
 */

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

    while (1) {
        ;
    }
}

