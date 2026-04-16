/*
 * CH552: blink P3.3 with 1 s ON and 1 s OFF using Timer2 interrupts.
 * Uses SFR/register access only (no pinMode, digitalWrite, delay, etc.).
 *
 * Timer2: 16-bit auto-reload, clock = Fsys (T2MOD: bTMR_CLK | bT2_CLK).
 * One interrupt every 1 ms (65536 - RCAP2 = F_CPU / 1000).
 * After 1000 interrupts the P3.3 level toggles (1 s half-period).
 *
 * Bootloader on this jig: P1.5 pull-down (matches CH559 test fixture).
 *
 * cli board options: clock=24internal,upload_method=usb,bootloader_pin=p15,usb_settings=user0
 *
 * (Arduino build still links the core; this sketch does not call Wiring APIs.)
 */

/* Half-period in milliseconds (Timer2 tick rate = 1 kHz here). */
#define HALF_PERIOD_MS 1000

/* Timer reload: count (65536 - RCAP2) clocks at Fsys per overflow. */
#define T2_TICKS_PER_MS (F_CPU / 1000UL)
#define T2_RCAP_VAL ((uint16_t)(0x10000UL - T2_TICKS_PER_MS))

#if (T2_TICKS_PER_MS > 65535UL)
#error F_CPU too high for 1 ms tick with 16-bit Timer2 at Fsys
#endif

static __idata uint16_t s_ms_in_phase;
static __idata uint8_t s_led_level; /* 1 = P3.3 driven high */

static void p33_init_push_pull_output(void) {
  /* P3.3 (INT1): push-pull — MOD_OC=0, DIR_PU=1 per CH552 manual. */
  P3_MOD_OC &= (uint8_t) ~bINT1;
  P3_DIR_PU |= bINT1;
  P3_3 = 0;
}

static void timer2_init_1ms_tick(void) {
  /* Do not clear T0/T1 bits in T2MOD; millis uses T0 via T2MOD.bT0_CLK. */
  T2CON = 0;
  T2MOD |= (uint8_t)(bTMR_CLK | bT2_CLK);

  RCAP2 = T2_RCAP_VAL;
  T2COUNT = T2_RCAP_VAL;

  TF2 = 0;
  ET2 = 1;
  T2CON = (uint8_t)(1u << 2); /* TR2=1: run; CP_RL2=0 auto-reload; internal count */
}

void setup(void) {
  p33_init_push_pull_output();
  s_ms_in_phase = 0;
  s_led_level = 0;
  P3_3 = 0;

  timer2_init_1ms_tick();
  EA = 1;
}

void loop(void) {
  /* All work in Timer2 ISR. */
}

void Timer2Interrupt(void) __interrupt(INT_NO_TMR2) {
  TF2 = 0;

  s_ms_in_phase++;
  if (s_ms_in_phase >= (uint16_t)HALF_PERIOD_MS) {
    s_ms_in_phase = 0;
    s_led_level ^= 1;
    P3_3 = s_led_level ? 1 : 0;
  }
}
