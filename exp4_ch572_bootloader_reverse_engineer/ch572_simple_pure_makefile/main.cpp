/* CH572: blink PA11. Single translation unit, no #include (registers + delay only).
 * PA11 digital GPIO, push-pull output (matches GPIOA_ModeCfg GPIO_ModeOut_PP_5mA).
 */

extern "C" {

static void delay_cycles(volatile unsigned long n)
{
    while (n) {
        n--;
    }
}

int main(void)
{
    constexpr unsigned pin = 11u;
    constexpr unsigned long pin_mask = 1ul << pin;
    constexpr unsigned short pin_mask16 = static_cast<unsigned short>(1u << pin);

    volatile unsigned long &pa_dir = *reinterpret_cast<volatile unsigned long *>(0x400010A0u);
    volatile unsigned long &pa_out = *reinterpret_cast<volatile unsigned long *>(0x400010A8u);
    volatile unsigned long &pa_clr = *reinterpret_cast<volatile unsigned long *>(0x400010ACu);
    volatile unsigned long &pa_pd_drv = *reinterpret_cast<volatile unsigned long *>(0x400010B4u);
    volatile unsigned short &pin_alternate = *reinterpret_cast<volatile unsigned short *>(0x40001018u);

    /* Digital GPIO on PA11 (clear alternate function select). */
    pin_alternate = static_cast<unsigned short>(pin_alternate & static_cast<unsigned short>(~pin_mask16));

    /* Output push-pull 5 mA drive. */
    pa_pd_drv &= ~pin_mask;
    pa_dir |= pin_mask;

    for (;;) {
        pa_out |= pin_mask;
        delay_cycles(400000ul);
        pa_clr |= pin_mask;
        delay_cycles(400000ul);
    }
}

}
