/*
 * CH572 RB_BOOT_LOAD_MAN Experiment — v2
 *
 * Goal: Trigger a software reset that causes the bootloader to see
 *       RB_BOOT_LOAD_MAN=1, keeping the chip in DFU mode (USB 0x1A86/0x55E0).
 *
 * Datasheet condition (translated from Chinese):
 *   "When RB_WDOG_INT_EN AND RB_ROM_CODE_WE are 1, RB_ROM_DATA_WE is 0,
 *    and 128<=R8_WDOG_COUNT<192, RB_BOOT_LOAD_MAN=1 and starts from BOOT"
 *
 * Bootloader flow (from disassembly):
 *   app_valid=0 path: checks RB_BOOT_LOAD_MAN at 0x3D5A0 immediately
 *   app_valid=1 path: UART3 ISP, DFU loop, first timer tick (~16ms) →
 *                     checks RB_BOOT_LOAD_MAN at 0x3D6CA
 *   If RB_BOOT_LOAD_MAN=1: calls 0x3D102 (USB DFU init) → 0x1A86/0x55E0
 *   If RB_BOOT_LOAD_MAN=0: calls USB D+ detect → fails (no external pull-up)
 *
 * NEW DIAGNOSTIC: Method 'a' saves register values before reset; on reboot,
 *   startup immediately captures registers to determine if RWA registers
 *   survive software reset (root cause investigation).
 *
 * APPJumpBoot: Method 'b' erases flash page 0 then resets — WCH's own
 *   method (from SimpleUsbCdc.c) — confirms USB DFU path works at all.
 *   WARNING: erases user app; must re-flash after!
 *
 * Commands:
 *   r  - print current registers
 *   1  - ROM_CODE_WE=0xC0 + WDOG_INT_EN + WDOG_COUNT=150
 *   2  - ROM_CODE_WE=0x40 + WDOG_INT_EN + WDOG_COUNT=150
 *   3  - ROM_CODE_WE=0x80 (bit7 only) + WDOG_INT_EN + WDOG_COUNT=150
 *   4  - WDOG_INT_EN only + WDOG_COUNT=150 (no ROM_CODE_WE)
 *   5  - ROM_CODE_WE=0xC0 only + WDOG_COUNT=150 (no WDOG_INT_EN)
 *   6  - WDOG_INT_EN + ROM_CODE_WE=0xC0 + WDOG_COUNT=150 + wait for overflow
 *   7  - safeWrite8 (direct): wdog=0x04, romcfg=0xC0, wdog_count=150, reset
 *   8  - safeWrite8: wdog=0x04, romcfg=0x80, wdog_count=150, reset
 *   9  - plain software reset only (baseline)
 *   a  - DIAGNOSTIC: set conditions + RESET_KEEP=0xAB + reset
 *          (next boot prints if RWA registers survived)
 *   b  - APPJumpBoot: erase flash page 0 + reset (WARNING: destroys user app!)
 *   c  - JUMP to bootloader ROM (0x3C000) WITH conditions set (no reset!)
 *          Tests if RB_BOOT_LOAD_MAN is combinatorial vs latched-at-reset.
 *          If DFU mode appears (0x1A86/0x55E0): bit is live/combinatorial.
 *          If device returns as user app: bit is latched (cleared at last reset).
 *   d  - JUMP to bootloader ROM (0x3C000) WITHOUT conditions (baseline).
 *          Bootloader runs 16ms DFU window, sees RB_BOOT_LOAD_MAN=0,
 *          triggers its own software reset -> user app comes back.
 *   e  - Register survival test: write WDOG_CTRL=0x04, ROM_CFG=0x40,
 *          WDOG_COUNT=55 then clean-jump (same as d).
 *          RESET_KEEP=0xE5 on return confirms we came back from bootloader;
 *          s_WDOG_CTRL=0x00, s_ROM_CFG=0x00 confirm bootloader software-reset
 *          cleared RWA registers.
 *   f  - UART3 loopback: pre-load 0x57 into UART3 RX FIFO without external
 *          hardware, then clean-jump. Three approaches in order:
 *            1) MCR bit-4 loopback (0x10) — WCH UART doesn't support this
 *            2) Same-pin TX/RX on PA2: remap TXD→PA2 via R16_PIN_ALTERNATE_H
 *               bit 3 (u_tx=1<<3=0x08); PA2 is already default RXD (u_rx=0).
 *               Clear R16_PIN_ALTERNATE bit 2 (PA_DI_DIS) to enable PA2 input.
 *            3) GPIO bit-bang on PA2 @ 9600 baud; UART RX samples via digital
 *               input path (active as long as PA_DI_DIS bit 2 = 0).
 *          If DATA_RDY=1 before jump: bootloader enters UART ISP (blocks!).
 *          WARNING: if UART ISP entered, power cycle required to recover.
 *   h  - WDOG-OVF SWEEP: 32 combos (WDOG_CTRL=0x06 fixed, 4 ROM_CFG × 8 COUNT).
 *          Hardware watchdog overflow reset (NOT software reset).
 *          Key hypothesis: BLM=1 only triggers on wdog overflow, not sw-reset.
 *          RESET_KEEP 0xA0-0xBF tracks progress.
 *   g  - SW-RESET SWEEP: 128 combos (4 WDOG_CTRL × 4 ROM_CFG × 8 WDOG_COUNT).
 *          Uses RESET_KEEP 0x20-0x9F to self-continue across reboots.
 *          Each boot prints "SWEEP NNN: W=.. R=.. C=.. -> BLM=0/1".
 *          If BLM=1: the bootloader enters DFU (USB 0x1A86/0x55E0 appears).
 *          Sweep stops when all 128 combos are done or BLM=1 is found.
 *          Press 'q' to abort (plain software reset, RESET_KEEP cleared).
 *   q  - abort sweep / plain software reset
 *   v  - verify writes work (no reset)
 */

#include <SimpleUsbSerial.h>
#include "ISP572.h"

// -------------------------------------------------------------------------
// Startup register snapshot — captured BEFORE USB init in setup()
// -------------------------------------------------------------------------
static uint8_t g_startup_wdog_ctrl;
static uint8_t g_startup_rom_cfg;
static uint8_t g_startup_wdog_count;
static uint8_t g_startup_cfg_info;
static uint8_t g_startup_reset_keep;

// -------------------------------------------------------------------------
// Helpers — run from RAM (.highcode) to survive register manipulation
// -------------------------------------------------------------------------

__attribute__((section(".highcode")))
static void safeWrite8(volatile uint8_t *reg, uint8_t value)
{
    volatile uint32_t mpie_mie;
    mpie_mie = __risc_v_disable_irq();
    asm volatile("fence.i");
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
    asm volatile("fence.i");
    *reg = value;
    R8_SAFE_ACCESS_SIG = 0;
    __risc_v_enable_irq(mpie_mie);
    asm volatile("fence.i");
}

__attribute__((section(".highcode")))
static void safeOr8(volatile uint8_t *reg, uint8_t mask)
{
    volatile uint32_t mpie_mie;
    mpie_mie = __risc_v_disable_irq();
    asm volatile("fence.i");
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
    asm volatile("fence.i");
    *reg |= mask;
    R8_SAFE_ACCESS_SIG = 0;
    __risc_v_enable_irq(mpie_mie);
    asm volatile("fence.i");
}

// -------------------------------------------------------------------------
// Sweep tables  (combo = wi*32 + ri*8 + ci, range 0-127)
// -------------------------------------------------------------------------
// RESET_KEEP 0x20-0x9F = sweep in progress; stored value = 0x20 + combo_just_run
static const uint8_t SWEEP_WDOG[4]   = { 0x00, 0x02, 0x04, 0x06 };
static const uint8_t SWEEP_ROMCFG[4] = { 0x00, 0x40, 0x80, 0xC0 };
static const uint8_t SWEEP_COUNT[8]  = { 0, 96, 127, 128, 150, 160, 191, 255 };
#define SWEEP_TOTAL  128   /* 4 * 4 * 8 */

static void sweepDecode(uint8_t idx,
                        uint8_t *wdog, uint8_t *romcfg, uint8_t *cnt)
{
    *wdog   = SWEEP_WDOG[idx / 32];
    *romcfg = SWEEP_ROMCFG[(idx / 8) & 3];
    *cnt    = SWEEP_COUNT[idx & 7];
}

__attribute__((section(".highcode"), noinline))
static void sweepFire(uint8_t next_idx,
                      uint8_t wdog, uint8_t romcfg, uint8_t cnt)
{
    R8_GLOB_RESET_KEEP = (uint8_t)(0x20u + next_idx); // mark for next boot
    safeWrite8(&R8_RST_WDOG_CTRL, wdog);
    safeWrite8(&R8_GLOB_ROM_CFG,  romcfg);
    R8_WDOG_COUNT = cnt;
    // Trigger software reset (bit 0) while keeping other WDOG bits set
    safeWrite8(&R8_RST_WDOG_CTRL, (uint8_t)(wdog | 0x01u));
    while (1);
}

// -------------------------------------------------------------------------
// Boot methods
// -------------------------------------------------------------------------

/* Method 1: ROM_CODE_WE=0xC0 (11b) + WDOG_INT_EN + WDOG_COUNT=150 */
__attribute__((section(".highcode")))
void bootMethod1(void)
{
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);   // 0x04
    safeOr8(&R8_GLOB_ROM_CFG, 0xC0);               // bits 7:6 = 11
    R8_WDOG_COUNT = 150;
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method 2: ROM_CODE_WE=0x40 (01b, only bit6) + WDOG_INT_EN + WDOG_COUNT=150 */
__attribute__((section(".highcode")))
void bootMethod2(void)
{
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);
    safeOr8(&R8_GLOB_ROM_CFG, 0x40);              // bit6 only
    R8_WDOG_COUNT = 150;
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method 3: ROM_CODE_WE=0x80 (bit7 only) + WDOG_INT_EN + WDOG_COUNT=150 */
__attribute__((section(".highcode")))
void bootMethod3(void)
{
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);
    safeOr8(&R8_GLOB_ROM_CFG, 0x80);              // bit7 only
    R8_WDOG_COUNT = 150;
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method 4: WDOG_INT_EN + WDOG_COUNT=150 (no ROM_CODE_WE) */
__attribute__((section(".highcode")))
void bootMethod4(void)
{
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);
    R8_WDOG_COUNT = 150;
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method 5: ROM_CODE_WE=0xC0 + WDOG_COUNT=150 (no WDOG_INT_EN) */
__attribute__((section(".highcode")))
void bootMethod5(void)
{
    safeOr8(&R8_GLOB_ROM_CFG, 0xC0);
    R8_WDOG_COUNT = 150;
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method 6: WDOG_INT_EN + ROM_CODE_WE=0xC0 + WDOG_COUNT=150
 * + WAIT for watchdog overflow (INT_FLAG set) BEFORE resetting */
__attribute__((section(".highcode")))
void bootMethod6(void)
{
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);
    safeOr8(&R8_GLOB_ROM_CFG, 0xC0);
    R8_WDOG_COUNT = 150;
    // Wait until the watchdog overflows (count wraps 255->0, INT_FLAG set)
    while (!(R8_RST_WDOG_CTRL & RB_WDOG_INT_FLAG)) {
        asm volatile("nop");
    }
    safeOr8(&R8_RST_WDOG_CTRL, RB_SOFTWARE_RESET);
    while(1);
}

/* Method h: WATCHDOG OVERFLOW RESET (hardware-triggered, not software reset).
 *
 * Key hypothesis: BLM=1 may only be set by a HARDWARE watchdog overflow reset,
 * NOT by a software reset.  This is consistent with the datasheet condition:
 *   WDOG_INT_EN=1 AND ROM_CODE_WE=01b AND ROM_DATA_WE=0 AND 128<=WDOG_COUNT<192
 * — these conditions can only be met at watchdog overflow time, not at
 *   software-reset time (where the hardware might evaluate post-clear values).
 *
 * Method h sweeps all 4 ROM_CFG × 8 WDOG_COUNT = 32 combos via watchdog overflow.
 * RESET_KEEP = 0xA0 + combo_index (0x0-0x1F) to track sweep across boots.
 *
 * The wdog overflow fires automatically when WDOG_COUNT counts from the written
 * value up to 0xFF then overflows (with WDOG_RST_EN=1), in ~(255-count)/32kHz.
 * No software reset is needed.
 */
#define WDOG_OVF_TOTAL  32
// WDOG_CTRL is always 0x06 (WDOG_INT_EN + WDOG_RST_EN)
// SWEEP_ROMCFG and SWEEP_COUNT tables reused; wdog_idx=3 always (0x06 combos from full table)
// But we only use 4 ROM_CFG × 8 COUNT = 32 combos here.

__attribute__((section(".highcode"), noinline))
static void wdogOvfFire(uint8_t next_idx, uint8_t romcfg, uint8_t cnt)
{
    R8_GLOB_RESET_KEEP = (uint8_t)(0xA0u + next_idx); // for next boot
    safeWrite8(&R8_RST_WDOG_CTRL, 0x00);   // clear any stale bits
    safeWrite8(&R8_GLOB_ROM_CFG,  romcfg);
    // Feed watchdog with our target count, then enable WDOG_RST_EN.
    // Must NOT feed it again — let it count up and overflow.
    R8_WDOG_COUNT = cnt;
    // Enable WDOG_INT_EN + WDOG_RST_EN; overflow will fire in ~(255-cnt)/32kHz ms
    safeWrite8(&R8_RST_WDOG_CTRL, 0x06u);
    // Spin — the watchdog overflows and resets the chip without any code action
    while (1) { __asm volatile("nop"); }
}

/* Method 7: safeWrite8 (direct, no read-modify-write)
 * wdog=0x04 (WDOG_INT_EN only), romcfg=0xC0, wdog_count=150 */
__attribute__((section(".highcode")))
void bootMethod7(void)
{
    safeWrite8(&R8_RST_WDOG_CTRL, 0x04);   // RB_WDOG_INT_EN only, direct write
    safeWrite8(&R8_GLOB_ROM_CFG, 0xC0);    // ROM_CODE_WE = 11b, direct write
    R8_WDOG_COUNT = 150;
    safeWrite8(&R8_RST_WDOG_CTRL, 0x05);   // WDOG_INT_EN + SOFTWARE_RESET = 0x04|0x01
    while(1);
}

/* Method 8: safeWrite8 with romcfg=0x80 (bit7 only) */
__attribute__((section(".highcode")))
void bootMethod8(void)
{
    safeWrite8(&R8_RST_WDOG_CTRL, 0x04);   // RB_WDOG_INT_EN only
    safeWrite8(&R8_GLOB_ROM_CFG, 0x80);    // bit7 only
    R8_WDOG_COUNT = 150;
    safeWrite8(&R8_RST_WDOG_CTRL, 0x05);   // WDOG_INT_EN + SOFTWARE_RESET
    while(1);
}

/* Method 9: plain software reset — boot condition reference */
__attribute__((section(".highcode")))
void bootMethod9(void)
{
    safeWrite8(&R8_RST_WDOG_CTRL, 0x01);  // only RB_SOFTWARE_RESET
    while(1);
}

/* Method a (diagnostic): set full conditions + mark RESET_KEEP=0xAB + reset.
 * On the NEXT boot, startup will print whether RWA registers survived. */
__attribute__((section(".highcode")))
void bootMethodA(void)
{
    // Mark that we deliberately triggered this reset
    R8_GLOB_RESET_KEEP = 0xAB;

    // Set all conditions per datasheet
    safeWrite8(&R8_RST_WDOG_CTRL, 0x04);  // WDOG_INT_EN
    safeWrite8(&R8_GLOB_ROM_CFG, 0x40);   // ROM_CODE_WE=01b (bit6=1, bit7=0)
    R8_WDOG_COUNT = 150;                  // 128 <= 150 < 192

    // Trigger software reset — conditions should be sampled by hardware here
    safeWrite8(&R8_RST_WDOG_CTRL, 0x05);  // WDOG_INT_EN | SOFTWARE_RESET
    while(1);
}

/* Method b (APPJumpBoot): erase flash page 0 + reset.
 * This is WCH's own method — does NOT use RB_BOOT_LOAD_MAN.
 * Erases the first 4K of flash so app_valid=0; bootloader enters USB DFU.
 * WARNING: destroys the user application! Must re-flash after. */
__attribute__((section(".highcode")))
void bootMethodB(void)
{
    // Disable PA2 (UART3 RX) pull-up/drive to prevent false UART data
    R32_PA_DIR &= ~(1u << 2);
    R32_PA_PU  &= ~(1u << 2);
    R16_PIN_ALTERNATE &= ~(1u << 2);
    R32_PA_PD_DRV |= (1u << 2);

    // Erase first 4096 bytes (page 0) — makes app_valid=0 in bootloader
    while (FLASH_EEPROM_CMD(0x01, 0, NULL, 4096) != 0x00) {
        ;
    }
    // Reset flash controller
    FLASH_EEPROM_CMD(0x04, 0, NULL, 0);

    // Software reset — bootloader will see app_valid=0 → USB DFU
    volatile uint32_t mpie_mie = __risc_v_disable_irq();
    asm volatile("fence.i");
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
    asm volatile("fence.i");
    R8_RST_WDOG_CTRL |= RB_SOFTWARE_RESET;
    R8_SAFE_ACCESS_SIG = 0;
    (void)mpie_mie;
    while(1);
}

/* Method C: Jump to bootloader ROM entry (0x3C000) WITH conditions set.
 *
 * NO hardware reset is triggered — the RWA registers (WDOG_INT_EN, ROM_CODE_WE,
 * WDOG_COUNT) are set here and will still hold those values when the bootloader
 * reads R8_RST_WDOG_CTRL.
 *
 * Key question: is RB_BOOT_LOAD_MAN (bit 0) COMBINATORIAL (reflects the live
 * state of its conditions) or LATCHED only at hardware-reset time?
 *
 *   USB 0x1A86/0x55E0 appears  =>  combinatorial; DFU mode entered.
 *   Device returns as user app  =>  latched; bootloader saw bit=0 and reset.
 *
 * Bootloader sets its own stack to 0x2003E800 — no conflict with user RAM.
 * Its BSS (0x2003DBA0..0x2003E014) is re-zeroed on entry; safe to re-enter.
 */
__attribute__((section(".highcode"), noinline))
void bootMethodC(void)
{
    // Set all conditions for RB_BOOT_LOAD_MAN (no reset, RWA registers persist)
    safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);    // WDOG_INT_EN = 1
    safeOr8(&R8_GLOB_ROM_CFG, 0x40);               // ROM_CODE_WE = 01b
    // ROM_DATA_WE must be 0 (default, not modifying)
    R8_WDOG_COUNT = 150;                            // 128 <= 150 < 192

    // Disable interrupts before jumping to avoid spurious IRQs during bootloader init
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    __asm volatile("fence.i" ::: "memory");

    // Jump directly to the bootloader ROM entry point — no return
    __asm volatile(
        "li t0, 0x3C000\n"
        "jr t0\n"
        ::: "t0", "memory"
    );
    __builtin_unreachable();
}

/* Method D: Clean jump to bootloader ROM (0x3C000) with USB + IRQs torn down.
 *
 * This variant properly shuts down the USB peripheral and all interrupt sources
 * before jumping. This lets the bootloader detect the D+ line state fresh.
 *
 * To test that the bootloader is genuinely running and its D+ detection path
 * works: attach a 1.5kΩ pull-up resistor from the USB D+ pin to 3.3V BEFORE
 * (or immediately after) sending this command.
 *
 * With the internal D+ pull-up cleared, D+ floats. The external pull-up pulls
 * it high. The bootloader's D+ detection function (at ROM 0x3D1F0) sees high
 * and enters DFU mode → 0x1A86/0x55E0 appears on the host.
 *
 * Without the external pull-up, D+ stays low and the bootloader falls through
 * its 16ms window → triggers software reset → user app comes back.
 */
__attribute__((section(".highcode"), noinline))
void bootMethodD(void)
{
    // --- 1. Disable all PFIC individual interrupt enables ---
    // Writing 1 to IRER bit = disable that IRQ (like ARM NVIC ICER)
    *((volatile uint32_t *)0xE000E180) = 0xFFFFFFFF;  // PFIC IRER[0]: IRQs  0-31
    *((volatile uint32_t *)0xE000E184) = 0xFFFFFFFF;  // PFIC IRER[1]: IRQs 32-63

    // --- 2. Clear global MIE so no interrupt can fire during teardown ---
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    __asm volatile("fence.i" ::: "memory");

    // --- 3. Tear down USB peripheral ---
    // 3a. Disable all USB interrupt sources
    R8_USB_INT_EN = 0x00;

    // 3b. Disable USB device SIE and internal D+ pull-up
    //     R8_USB_CTRL bits[5:4]=00 → "disable USB device and internal pull-up"
    R8_USB_CTRL = 0x00;

    // 3c. Disable USB physical port I/O.
    //     Set RB_UD_PD_DIS so the on-chip D+/D− pull-downs are OFF;
    //     D+ will float, letting an external 1.5kΩ pull-up dominate.
    R8_UDEV_CTRL = RB_UD_PD_DIS;   // = 0x80

    // 3d. Clear the sleep-mode software pull-up as well
    R16_PIN_ALTERNATE &= (uint16_t)~RB_UDP_PU_EN;  // clear bit 12

    // --- 4. Delay ~1 ms so the USB host registers the disconnect ---
    for (volatile uint32_t i = 0; i < 48000; i++) { __asm volatile("nop"); }

    // --- 5. Jump to bootloader ROM — no return ---
    //     Bootloader re-initialises its own stack (0x2003E800) and BSS,
    //     then calls the D+ detection routine at ROM 0x3D1F0.
    __asm volatile(
        "li t0, 0x3C000\n"
        "jr t0\n"
        ::: "t0", "memory"
    );
    __builtin_unreachable();
}

/* Method E: Register survival test.
 *
 * Writes known test values to R8_RST_WDOG_CTRL (0x04), R8_GLOB_ROM_CFG (0x40),
 * and R8_WDOG_COUNT (55), marks RESET_KEEP=0xE5, then performs a clean jump
 * to the bootloader ROM — identical to Method D.
 *
 * On the next boot after the bootloader's own software reset:
 *   s_RESET_KEEP = 0xE5  → survived the software reset (confirms we returned
 *                           from the bootloader, not from a power cycle).
 *   s_WDOG_CTRL  = 0x00  → hardware cleared the RWA register on reset.
 *   s_ROM_CFG    = 0x00  → hardware cleared the RWA register on reset.
 *   s_WDOG_COUNT = ???   → R8_WDOG_COUNT is not RWA; observe if 55 persists.
 *
 * Conclusion: values written before the jump DO survive the jump itself
 * (no hardware reset occurs at jump time), but the bootloader's own software
 * reset clears all RWA registers on the way back.
 */
__attribute__((section(".highcode"), noinline))
void bootMethodE(void)
{
    R8_GLOB_RESET_KEEP = 0xE5;            // mark: method E triggered this jump

    safeWrite8(&R8_RST_WDOG_CTRL, 0x04); // WDOG_INT_EN = 1
    safeWrite8(&R8_GLOB_ROM_CFG,  0x40); // ROM_CODE_WE = 01b
    R8_WDOG_COUNT = 55;                  // 0x37 — distinct non-default value

    // Same clean teardown and jump as Method D
    *((volatile uint32_t *)0xE000E180) = 0xFFFFFFFF; // PFIC IRER[0]
    *((volatile uint32_t *)0xE000E184) = 0xFFFFFFFF; // PFIC IRER[1]
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    __asm volatile("fence.i" ::: "memory");
    R8_USB_INT_EN = 0x00;
    R8_USB_CTRL   = 0x00;
    R8_UDEV_CTRL  = RB_UD_PD_DIS;
    R16_PIN_ALTERNATE &= (uint16_t)~RB_UDP_PU_EN;
    for (volatile uint32_t i = 0; i < 48000; i++) __asm volatile("nop");
    __asm volatile(
        "li t0, 0x3C000\n"
        "jr t0\n"
        ::: "t0", "memory"
    );
    __builtin_unreachable();
}

/* Method F: Pre-load 0x57 into UART3 RX FIFO without external hardware,
 * then clean-jump to the bootloader ROM.
 *
 * The bootloader at 0x3D638 checks R8_UART_LSR bit 0 (DATA_RDY). If 1,
 * it enters UART ISP mode:
 *   1. Drives PA1 HIGH (USB D+ pull-up → host sees device connect)
 *   2. Reads first byte from UART RX → expects 0x57
 *   3. Reads second byte → expects 0xAB (blocks indefinitely if not sent)
 *
 * Three loopback approaches are tried in order — no external hardware needed:
 *   Approach 1: MCR bit-4 loopback (standard 8250 MCR[4] = 0x10).
 *   Approach 2: Same-pin TX+RX share on PA2. R16_PIN_ALTERNATE bit 2 enables
 *               PA2 as both TXD_1 and RXD_0 simultaneously; the UART TX output
 *               drives the pin while UART RX samples it.
 *   Approach 3: GPIO bit-bang — configure PA2 as output, transmit a UART frame
 *               for 0x57 at 9600 baud with PA2 also muxed as UART RXD.
 *
 * Results are printed via SerialUSB BEFORE USB is disabled.
 * RESET_KEEP = 0xF5 on return (if power-cycled out of UART ISP: RESET_KEEP=0).
 *
 * Clock assumed 24 MHz (bootloader sets R8_CLK_SYS_CFG=0x59 → PLL÷25=24 MHz).
 * WARNING: if DATA_RDY=1 and bootloader enters UART ISP, power cycle required.
 */
__attribute__((section(".highcode"), noinline))
void bootMethodF(void)
{
    uint8_t lsr_val   = 0;
    uint8_t rfc_val   = 0;
    uint8_t method_ok = 0; // 0=all failed, 1/2/3 = which approach worked

    // -----------------------------------------------------------------------
    // Step 1: Compute baud-rate divisor from live system clock
    // (replicate GetSysClock() inline to avoid undefined Freq_LSI symbol)
    // -----------------------------------------------------------------------
    uint8_t  clk_cfg = R8_CLK_SYS_CFG;
    uint32_t clk_div = (uint32_t)(clk_cfg & 0x1Fu);
    if (clk_div == 0u) clk_div = 32u;
    uint32_t fsys;
    if ((clk_cfg & 0xC0u) == 0xC0u) {         // LSI mode — very slow, fall back to safe value
        fsys = 32768u;
    } else if ((clk_cfg & 0x40u) != 0u) {     // PLL mode: Fpll=600 MHz, div by clk_div
        fsys = 600000000u / clk_div;           // e.g. 0x59 → 24 MHz
    } else {                                   // XT 32 MHz mode
        fsys = 32000000u / clk_div;
    }
    uint16_t dl = (uint16_t)(fsys / 8u / 9600u); // DL for 9600 baud
    if (dl == 0u) dl = 1u;                    // safety

    // -----------------------------------------------------------------------
    // Step 2: Initialise UART3 — 9600 baud, 8N1, FIFO enabled
    // -----------------------------------------------------------------------
    R8_UART_FCR = 0x07;   // enable FIFO + reset RX FIFO + reset TX FIFO
    R8_UART_FCR = 0x01;   // keep FIFO enabled, clear reset bits
    R8_UART_LCR = 0x03;   // 8 data bits, 1 stop bit, no parity
    R16_UART_DL = dl;
    R8_UART_DIV = 1;
    R8_UART_IER = 0x40;   // RB_IER_TXD_EN: enable TXD output pin

    // -----------------------------------------------------------------------
    // Step 3a: Approach 1 — MCR loopback (MCR bit 4 = 0x10)
    // -----------------------------------------------------------------------
    R8_UART_MCR = 0x10;
    R8_UART_THR = 0x57;
    // Wait > 1 UART frame: 10 bits @ 9600 bd = 1.04 ms ≈ 25 000 cycles @ 24 MHz
    for (volatile uint32_t w = 0; w < 30000u; w++) __asm volatile("nop");
    lsr_val = R8_UART_LSR;
    rfc_val = R8_UART_RFC;
    if (lsr_val & 0x01u) {
        method_ok = 1;
    } else {
        // -----------------------------------------------------------------------
        // Step 3b: Approach 2 — same-pin TX+RX on PA2
        //   CH572 UART pin mux is in R16_PIN_ALTERNATE_H (0x4000101A):
        //     RB_UART_RXD = bits[2:0]: u_rx index → PA2 default = 0 (no change)
        //     RB_UART_TXD = bits[5:3]: u_tx << 3  → PA2 as TXD = 1<<3 = 0x08
        //   R16_PIN_ALTERNATE (0x40001018) bits[11:0] = RB_PA_DI_DIS (input disable);
        //     bit 2 = 1 DISABLES PA2 digital input — must CLEAR it to allow UART RX.
        //   With PA2 driving TXD output and UART RX sampling the same PA2 pin,
        //   the transmitted byte loops back into the RX FIFO.
        // -----------------------------------------------------------------------
        R8_UART_FCR = 0x07;
        R8_UART_FCR = 0x01;
        R8_UART_MCR = 0x00;
        // Remap UART TXD → PA2 (u_tx=1, u_tx<<3=0x08); RXD stays PA2 (default u_rx=0).
        R16_PIN_ALTERNATE_H = (R16_PIN_ALTERNATE_H & ~(uint16_t)(RB_UART_TXD | RB_UART_RXD))
                             | (uint16_t)0x08u;
        // Enable PA2 digital input: clear RB_PA_DI_DIS bit 2 in R16_PIN_ALTERNATE.
        R16_PIN_ALTERNATE &= ~(uint16_t)0x0004u;
        R32_PA_DIR &= ~(1u << 2); // PA2 as input — UART TX peripheral drives pin
        R8_UART_THR = 0x57;
        for (volatile uint32_t w = 0; w < 30000u; w++) __asm volatile("nop");
        lsr_val = R8_UART_LSR;
        rfc_val = R8_UART_RFC;
        if (lsr_val & 0x01u) {
            method_ok = 2;
        } else {
            // -----------------------------------------------------------------------
            // Step 3c: Approach 3 — GPIO bit-bang UART frame on PA2 @ 9600 baud
            //   PA2 is UART default RXD (u_rx=0, no R16_PIN_ALTERNATE_H change needed).
            //   PA2 digital input must be ENABLED (PA_DI_DIS bit 2 = 0, set in approach 2).
            //   PA2 configured as GPIO output drives the frame; the CH572 digital input
            //   buffer remains active (PA_DI_DIS=0), so UART RX still samples the pin.
            //   Restore TXD to default PA3 so UART TX driver doesn't interfere.
            //
            //   Timing: fsys/9600 cycles per bit; loop ≈ 6 cycles/iter.
            // -----------------------------------------------------------------------
            R8_UART_FCR = 0x07;
            R8_UART_FCR = 0x01;
            // Restore TXD to default PA3 (clear TXD field); RXD stays at PA2 (default).
            R16_PIN_ALTERNATE_H &= ~(uint16_t)RB_UART_TXD;
            // PA_DI_DIS bit 2 already cleared in approach 2 — PA2 digital input is enabled.
            R32_PA_OUT |= (1u << 2);   // pre-set output HIGH (UART idle / MARK)
            R32_PA_DIR |= (1u << 2);   // PA2 as GPIO output → drives frame
            for (volatile uint32_t w = 0; w < 500u; w++) __asm volatile("nop"); // settle

            // Bit period in loop-iterations (≈6 cycles/iter)
            volatile uint32_t bd = fsys / 9600u / 6u;
            if (bd == 0) bd = 1;

            // 0x57 = 0b 0101 0111  (bit 7 .. bit 0)
            // Transmitted LSB first: D0=1 D1=1 D2=1 D3=0 D4=1 D5=0 D6=1 D7=0

#define BB_PA2_SET() R32_PA_SET = (1u << 2)
#define BB_PA2_CLR() R32_PA_CLR = (1u << 2)
#define BB_DELAY()   do { for (volatile uint32_t _d = 0; _d < bd; _d++) __asm volatile("nop"); } while(0)

            BB_PA2_CLR(); BB_DELAY(); // START bit = LOW
            BB_PA2_SET(); BB_DELAY(); // D0 = 1
            BB_PA2_SET(); BB_DELAY(); // D1 = 1
            BB_PA2_SET(); BB_DELAY(); // D2 = 1
            BB_PA2_CLR(); BB_DELAY(); // D3 = 0
            BB_PA2_SET(); BB_DELAY(); // D4 = 1
            BB_PA2_CLR(); BB_DELAY(); // D5 = 0
            BB_PA2_SET(); BB_DELAY(); // D6 = 1
            BB_PA2_CLR(); BB_DELAY(); // D7 = 0
            BB_PA2_SET(); BB_DELAY(); BB_DELAY(); // STOP (1.5 bits idle)

#undef BB_PA2_SET
#undef BB_PA2_CLR
#undef BB_DELAY

            // Release PA2 back to input; UART RX FIFO should now hold 0x57
            R32_PA_DIR &= ~(1u << 2);
            for (volatile uint32_t w = 0; w < 30000u; w++) __asm volatile("nop");
            lsr_val = R8_UART_LSR;
            rfc_val = R8_UART_RFC;
            method_ok = 3; // attempted (check lsr_val to see if it worked)
        }
    }

    // -----------------------------------------------------------------------
    // Step 4: Report results via SerialUSB BEFORE disabling USB
    // -----------------------------------------------------------------------
    SerialUSB.print(">> Method F result: approach=");
    SerialUSB.print((int)method_ok);
    SerialUSB.print("  LSR=0x");
    if (lsr_val < 0x10) SerialUSB.print("0");
    SerialUSB.print((int)lsr_val, HEX);
    SerialUSB.print("  RFC=");
    SerialUSB.println((int)rfc_val);
    if (lsr_val & 0x01u) {
        SerialUSB.println("   DATA_RDY=1: 0x57 in UART3 RX FIFO!");
        SerialUSB.println("   Bootloader will enter UART ISP mode.");
        SerialUSB.println("   PA1 (USB D+) driven HIGH by bootloader.");
        SerialUSB.println("   Chip BLOCKS in UART ISP — POWER CYCLE to recover.");
        R8_GLOB_RESET_KEEP = 0xF0u | method_ok; // 0xF1, 0xF2, or 0xF3
    } else {
        SerialUSB.println("   DATA_RDY=0: all loopback approaches failed.");
        SerialUSB.println("   Bootloader will run DFU window (~10s) then reset.");
        R8_GLOB_RESET_KEEP = 0xF5; // method F ran but loopback failed
    }
    SerialUSB.flush();
    // ~500 ms busy-wait so USB CDC flushes before we kill USB
    for (volatile uint32_t w = 0; w < (fsys / 48u); w++) __asm volatile("nop");

    // -----------------------------------------------------------------------
    // Step 5: Disable IRQs and USB, then jump.
    //   PA2 is already default UART RXD (u_rx=0), PA_DI_DIS bit 2 is cleared.
    //   Only clear the USB sleep pull-up (RB_UDP_PU_EN) from R16_PIN_ALTERNATE.
    // -----------------------------------------------------------------------
    *((volatile uint32_t *)0xE000E180) = 0xFFFFFFFF;
    *((volatile uint32_t *)0xE000E184) = 0xFFFFFFFF;
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    __asm volatile("fence.i" ::: "memory");
    R8_USB_INT_EN = 0x00;
    R8_USB_CTRL   = 0x00;
    R8_UDEV_CTRL  = RB_UD_PD_DIS;
    R16_PIN_ALTERNATE &= (uint16_t)~RB_UDP_PU_EN; // keep bit 2 (UART RXD_0)
    __asm volatile(
        "li t0, 0x3C000\n"
        "jr t0\n"
        ::: "t0", "memory"
    );
    __builtin_unreachable();
}

// -------------------------------------------------------------------------

static void printRegs(void)
{
    uint8_t wdog    = R8_RST_WDOG_CTRL;
    uint8_t romcfg  = R8_GLOB_ROM_CFG;
    uint8_t wcount  = R8_WDOG_COUNT;
    uint8_t cfginfo = R8_GLOB_CFG_INFO;
    uint8_t keep    = R8_GLOB_RESET_KEEP;

    SerialUSB.println("=== Register Snapshot ===");
    SerialUSB.print("R8_RST_WDOG_CTRL (0x40001046): 0x");
    if (wdog < 0x10) SerialUSB.print("0");
    SerialUSB.println(wdog, HEX);
    SerialUSB.print("  RB_WDOG_INT_FLAG (bit4): "); SerialUSB.println((wdog >> 4) & 1);
    SerialUSB.print("  RB_WDOG_INT_EN   (bit2): "); SerialUSB.println((wdog >> 2) & 1);
    SerialUSB.print("  RB_WDOG_RST_EN   (bit1): "); SerialUSB.println((wdog >> 1) & 1);
    SerialUSB.print("  RB_BOOT_LOAD_MAN (bit0): "); SerialUSB.println(wdog & 1);

    SerialUSB.print("R8_GLOB_ROM_CFG  (0x40001044): 0x");
    if (romcfg < 0x10) SerialUSB.print("0");
    SerialUSB.println(romcfg, HEX);
    SerialUSB.print("  bits[7:6] (ROM_CODE_WE): 0b");
    SerialUSB.print((romcfg >> 7) & 1);
    SerialUSB.println((romcfg >> 6) & 1);
    SerialUSB.print("  bits[2:0] (RESET_FLAG):  ");
    SerialUSB.println(romcfg & 0x07);

    SerialUSB.print("R8_WDOG_COUNT    (0x40001043): "); SerialUSB.println(wcount, DEC);

    SerialUSB.print("R8_GLOB_CFG_INFO (0x40001045): 0x");
    if (cfginfo < 0x10) SerialUSB.print("0");
    SerialUSB.println(cfginfo, HEX);
    SerialUSB.print("  RB_BOOT_LOADER  (bit5): "); SerialUSB.println((cfginfo >> 5) & 1);

    SerialUSB.print("R8_GLOB_RESET_KEEP (0x40001047): 0x");
    if (keep < 0x10) SerialUSB.print("0");
    SerialUSB.println(keep, HEX);

    // Always include startup snapshot so it is never missed
    SerialUSB.println("--- Startup snapshot (captured before USB init) ---");
    SerialUSB.print("  s_RST_WDOG_CTRL: 0x");
    if (g_startup_wdog_ctrl < 0x10) SerialUSB.print("0");
    SerialUSB.print(g_startup_wdog_ctrl, HEX);
    SerialUSB.print("  s_GLOB_ROM_CFG: 0x");
    if (g_startup_rom_cfg < 0x10) SerialUSB.print("0");
    SerialUSB.print(g_startup_rom_cfg, HEX);
    SerialUSB.print("  s_WDOG_COUNT: "); SerialUSB.print(g_startup_wdog_count, DEC);
    SerialUSB.print("  s_RESET_KEEP: 0x");
    if (g_startup_reset_keep < 0x10) SerialUSB.print("0");
    SerialUSB.println(g_startup_reset_keep, HEX);
    SerialUSB.print("  RESET_FLAG: "); SerialUSB.print(g_startup_rom_cfg & 0x07);
    SerialUSB.print("  RB_WDOG_INT_EN survived: ");
    SerialUSB.print((g_startup_wdog_ctrl >> 2) & 1);
    SerialUSB.print("  ROM_CODE_WE survived: 0b");
    SerialUSB.print((g_startup_rom_cfg >> 7) & 1);
    SerialUSB.println((g_startup_rom_cfg >> 6) & 1);
    if (g_startup_reset_keep == 0xAB) {
        SerialUSB.println("  *** FROM METHOD-A RESET: RESET_KEEP=0xAB SURVIVED! ***");
        R8_GLOB_RESET_KEEP = 0x00;
    } else if (g_startup_reset_keep == 0xE5) {
        SerialUSB.println("  *** FROM METHOD-E JUMP: RESET_KEEP=0xE5 survived bootloader SW-reset. ***");
        SerialUSB.println("  *** RWA regs above are 0x00 -> cleared by bootloader software reset.  ***");
        SerialUSB.print  ("  *** s_WDOG_COUNT="); SerialUSB.print(g_startup_wdog_count);
        SerialUSB.println(" (55=0x37 expected if not RWA, 0 if cleared) ***");
        R8_GLOB_RESET_KEEP = 0x00;
    } else if ((g_startup_reset_keep & 0xF0u) == 0xF0u && g_startup_reset_keep != 0xF0u) {
        uint8_t appr = g_startup_reset_keep & 0x0Fu;
        SerialUSB.print  ("  *** FROM METHOD-F: loopback approach ");
        SerialUSB.print  ((int)appr);
        SerialUSB.println(" set DATA_RDY=1 before jump. ***");
        SerialUSB.println("  *** Bootloader entered UART ISP — then power-cycled (RESET_KEEP=0 after POR). ***");
        SerialUSB.println("  *** (This message only appears if somehow returned via SW-reset, not POR.)    ***");
        R8_GLOB_RESET_KEEP = 0x00;
    } else if (g_startup_reset_keep == 0xF5) {
        SerialUSB.println("  *** FROM METHOD-F: all loopback approaches failed (DATA_RDY=0). ***");
        SerialUSB.println("  *** Bootloader ran DFU window (~10s) then returned normally.    ***");
        R8_GLOB_RESET_KEEP = 0x00;
    }

    SerialUSB.println("=========================");
    SerialUSB.println("Cmds: r 1-9 a b(!) c d e f g(sw-sweep) h(wdog-ovf-sweep) q v");
    SerialUSB.flush();
}


// -------------------------------------------------------------------------
// Sweep continuation — called from setup() before USB init
// -------------------------------------------------------------------------
__attribute__((section(".highcode"), noinline))
static void sweepContinue(uint8_t keep)
{
    // keep = 0x20 + combo_just_run (0..127)
    uint8_t done_idx = keep - 0x20u;
    uint8_t blm      = g_startup_wdog_ctrl & 0x01u; // RB_BOOT_LOAD_MAN
    uint8_t wdog, romcfg, cnt;
    sweepDecode(done_idx, &wdog, &romcfg, &cnt);

    // Flush this result over serial BEFORE doing the next reset
    // (USB will be init'd by caller after we return — we return if NOT last)
    // For speed we use a tiny busy-print via SerialUSB only AFTER USB is up.
    // So we just store in a flag and let setup() print then continue.
    // Nothing to do here that needs highcode — logic handled in setup().
    (void)blm; (void)wdog; (void)romcfg; (void)cnt;
}

void setup()
{
    // Capture registers IMMEDIATELY before any other initialization
    g_startup_wdog_ctrl  = R8_RST_WDOG_CTRL;
    g_startup_rom_cfg    = R8_GLOB_ROM_CFG;
    g_startup_wdog_count = R8_WDOG_COUNT;
    g_startup_cfg_info   = R8_GLOB_CFG_INFO;
    g_startup_reset_keep = R8_GLOB_RESET_KEEP;

    SerialUSB.begin();

    // ---- Wdog-overflow sweep continuation (RESET_KEEP 0xA0-0xBF) ----
    if (g_startup_reset_keep >= 0xA0u && g_startup_reset_keep <= 0xBFu) {
        uint8_t done_idx = g_startup_reset_keep - 0xA0u;
        uint8_t blm      = (g_startup_wdog_ctrl & 0x01u);
        uint8_t romcfg   = SWEEP_ROMCFG[(done_idx / 8) & 3];
        uint8_t cnt      = SWEEP_COUNT[done_idx & 7];

        SerialUSB.print("WDOG_OVF ");
        if (done_idx < 10)  SerialUSB.print("0");
        SerialUSB.print((int)done_idx);
        SerialUSB.print(": W=0x06 R=0x");
        if (romcfg < 0x10) SerialUSB.print("0");
        SerialUSB.print((int)romcfg, HEX);
        SerialUSB.print(" C=");
        if (cnt < 100) SerialUSB.print(" ");
        if (cnt < 10)  SerialUSB.print(" ");
        SerialUSB.print((int)cnt);
        SerialUSB.print(" -> BLM=");
        SerialUSB.print((int)blm);
        SerialUSB.print("  RFLAG=");
        SerialUSB.println((int)(g_startup_rom_cfg & 0x07));
        SerialUSB.flush();

        if (blm) {
            SerialUSB.println("*** WDOG_OVF: BOOT_LOAD_MAN=1 WAS SET! ***");
            SerialUSB.flush();
            R8_GLOB_RESET_KEEP = 0x00;
            return;
        }

        uint8_t next_idx = done_idx + 1u;
        if (next_idx < WDOG_OVF_TOTAL) {
            for (volatile uint32_t d = 0; d < 240000u; d++) {}
            uint8_t nr = SWEEP_ROMCFG[(next_idx / 8) & 3];
            uint8_t nc = SWEEP_COUNT[next_idx & 7];
            SerialUSB.print("  -> next: R=0x");
            if (nr < 0x10) SerialUSB.print("0");
            SerialUSB.print((int)nr, HEX);
            SerialUSB.print(" C="); SerialUSB.println((int)nc);
            SerialUSB.flush();
            for (volatile uint32_t d = 0; d < 240000u; d++) {}
            wdogOvfFire(next_idx, nr, nc);
            // never returns
        } else {
            SerialUSB.println("=== WDOG_OVF SWEEP COMPLETE: no combo set BLM=1 ===");
            SerialUSB.flush();
            R8_GLOB_RESET_KEEP = 0x00;
        }
    }

    // ---- Software-reset sweep continuation (RESET_KEEP 0x20-0x9F) ----
    // If RESET_KEEP is in [0x20, 0x9F], a sweep combo just ran.
    // Print result, then immediately fire the next combo (if any).
    if (g_startup_reset_keep >= 0x20u && g_startup_reset_keep <= 0x9Fu) {
        uint8_t done_idx = g_startup_reset_keep - 0x20u;
        uint8_t blm      = (g_startup_wdog_ctrl & 0x01u);
        uint8_t wdog, romcfg, cnt;
        sweepDecode(done_idx, &wdog, &romcfg, &cnt);

        // Print one-liner result so the Python side can parse it
        SerialUSB.print("SWEEP ");
        if (done_idx < 10)  SerialUSB.print("0");
        if (done_idx < 100) SerialUSB.print("0");
        SerialUSB.print((int)done_idx);
        SerialUSB.print(": W=0x");
        if (wdog < 0x10) SerialUSB.print("0");
        SerialUSB.print((int)wdog, HEX);
        SerialUSB.print(" R=0x");
        if (romcfg < 0x10) SerialUSB.print("0");
        SerialUSB.print((int)romcfg, HEX);
        SerialUSB.print(" C=");
        if (cnt < 100) SerialUSB.print(" ");
        if (cnt < 10)  SerialUSB.print(" ");
        SerialUSB.print((int)cnt);
        SerialUSB.print(" -> BLM=");
        SerialUSB.print((int)blm);
        SerialUSB.print("  RFLAG=");
        SerialUSB.println((int)(g_startup_rom_cfg & 0x07));
        SerialUSB.flush();

        if (blm) {
            // SUCCESS — but this path is theoretically unreachable since if
            // BLM=1 the bootloader would have run DFU, not the user app.
            SerialUSB.println("*** BOOT_LOAD_MAN=1 WAS SET! ***");
            SerialUSB.println("*** Combo above was the winner. ***");
            SerialUSB.flush();
            R8_GLOB_RESET_KEEP = 0x00;
            return; // stop sweep, enter normal operation
        }

        uint8_t next_idx = done_idx + 1u;
        if (next_idx < SWEEP_TOTAL) {
            // Small delay so USB CDC prints make it out before reset
            for (volatile uint32_t d = 0; d < 240000u; d++) {}
            uint8_t nw, nr, nc;
            sweepDecode(next_idx, &nw, &nr, &nc);
            SerialUSB.print("  -> next: W=0x");
            if (nw < 0x10) SerialUSB.print("0");
            SerialUSB.print((int)nw, HEX);
            SerialUSB.print(" R=0x");
            if (nr < 0x10) SerialUSB.print("0");
            SerialUSB.print((int)nr, HEX);
            SerialUSB.print(" C=");
            SerialUSB.println((int)nc);
            SerialUSB.flush();
            for (volatile uint32_t d = 0; d < 240000u; d++) {}
            sweepFire(next_idx, nw, nr, nc);
            // never returns
        } else {
            SerialUSB.println("=== SWEEP COMPLETE: no combo set BLM=1 ===");
            SerialUSB.flush();
            R8_GLOB_RESET_KEEP = 0x00;
        }
    }
}

void loop()
{
    static uint32_t lastPrint = 0;

    // Periodic print every 5s
    if (millis() - lastPrint > 5000) {
        lastPrint = millis();
        printRegs();
    }

    if (SerialUSB.available()) {
        char c = SerialUSB.read();
        switch (c) {
            case 'r':
                printRegs();
                break;
            case '1':
                SerialUSB.println(">> Method 1: OR romcfg=0xC0, WDOG_INT_EN, WDOG_COUNT=150");
                SerialUSB.flush(); delay(50);
                bootMethod1();
                break;
            case '2':
                SerialUSB.println(">> Method 2: OR romcfg=0x40, WDOG_INT_EN, WDOG_COUNT=150");
                SerialUSB.flush(); delay(50);
                bootMethod2();
                break;
            case '3':
                SerialUSB.println(">> Method 3: OR romcfg=0x80 (bit7 only), WDOG_INT_EN, WDOG_COUNT=150");
                SerialUSB.flush(); delay(50);
                bootMethod3();
                break;
            case '4':
                SerialUSB.println(">> Method 4: WDOG_INT_EN + WDOG_COUNT=150 (no ROM_CODE_WE)");
                SerialUSB.flush(); delay(50);
                bootMethod4();
                break;
            case '5':
                SerialUSB.println(">> Method 5: romcfg=0xC0 + WDOG_COUNT=150 (no WDOG_INT_EN)");
                SerialUSB.flush(); delay(50);
                bootMethod5();
                break;
            case '6':
                SerialUSB.println(">> Method 6: WDOG_INT_EN + romcfg=0xC0 + WDOG_COUNT=150 + wait for overflow");
                SerialUSB.println("   (this may take ~280ms then reset)");
                SerialUSB.flush(); delay(50);
                bootMethod6();
                break;
            case '7':
                SerialUSB.println(">> Method 7: direct write wdog=0x04, romcfg=0xC0, count=150, reset=0x05");
                SerialUSB.flush(); delay(50);
                bootMethod7();
                break;
            case '8':
                SerialUSB.println(">> Method 8: direct write wdog=0x04, romcfg=0x80, count=150, reset=0x05");
                SerialUSB.flush(); delay(50);
                bootMethod8();
                break;
            case '9':
                SerialUSB.println(">> Method 9: plain software reset (wdog=0x01 only)");
                SerialUSB.flush(); delay(50);
                bootMethod9();
                break;
            case 'a': {
                SerialUSB.println(">> Method A: DIAGNOSTIC reset");
                SerialUSB.println("   Sets RESET_KEEP=0xAB, WDOG_INT_EN=1, ROM_CFG=0x40, COUNT=150");
                SerialUSB.println("   -> On next boot, prints whether RWA registers survived.");
                SerialUSB.flush(); delay(50);
                bootMethodA();
                break;
            }
            case 'b': {
                SerialUSB.println(">> Method B: APPJumpBoot — erase flash page 0 + reset");
                SerialUSB.println("   WARNING: DESTROYS USER APP. Must re-flash via wchisp after!");
                SerialUSB.println("   Watch for USB device 0x1A86/0x55E0 on host.");
                SerialUSB.flush(); delay(200);
                bootMethodB();
                break;
            }
            case 'c': {
                SerialUSB.println(">> Method C: JUMP to bootloader ROM 0x3C000 WITH conditions set");
                SerialUSB.println("   Sets WDOG_INT_EN=1, ROM_CODE_WE=0x40, WDOG_COUNT=150");
                SerialUSB.println("   Then jumps directly (NO hardware reset).");
                SerialUSB.println("   If 0x1A86/0x55E0 appears: RB_BOOT_LOAD_MAN is combinatorial!");
                SerialUSB.println("   If app returns after ~16ms: RB_BOOT_LOAD_MAN is latched/0.");
                SerialUSB.flush(); delay(200);
                bootMethodC();
                break;
            }
            case 'd': {
                SerialUSB.println(">> Method D: JUMP to bootloader ROM 0x3C000 (USB + IRQs torn down)");
                SerialUSB.println("   Disables all PFIC IRQs, clears MIE, shuts down USB peripheral,");
                SerialUSB.println("   releases D+ (internal pull-up OFF, on-chip pull-down OFF).");
                SerialUSB.println("   Then jumps to 0x3C000 — bootloader detects D+ state fresh.");
                SerialUSB.println("   >> With 1.5k pull-up on D+ to 3.3V: expect 0x1A86/0x55E0 DFU!");
                SerialUSB.println("   >> Without pull-up: bootloader resets -> app returns in ~16ms.");
                SerialUSB.flush(); delay(300);
                bootMethodD();
                break;
            }
            case 'e': {
                SerialUSB.println(">> Method E: Register survival test");
                SerialUSB.println("   Writes WDOG_CTRL=0x04, ROM_CFG=0x40, WDOG_COUNT=55 via safe access.");
                SerialUSB.println("   Marks RESET_KEEP=0xE5, then clean-jumps to bootloader (like D).");
                SerialUSB.println("   On return: startup snapshot shows what survived the SW-reset.");
                SerialUSB.println("   Expected: s_WDOG_CTRL=0x00, s_ROM_CFG=0x00, RESET_KEEP=0xE5.");
                SerialUSB.flush(); delay(300);
                bootMethodE();
                break;
            }
            case 'f': {
                SerialUSB.println(">> Method F: UART3 loopback + jump");
                SerialUSB.println("   Init UART3 @ 9600 baud, try to put 0x57 in RX FIFO:");
                SerialUSB.println("     1) MCR bit-4 loopback  2) PA2 same-pin TX+RX  3) GPIO bit-bang");
                SerialUSB.println("   Prints LSR/RFC result, then clean-jumps to bootloader.");
                SerialUSB.println("   DATA_RDY=1 -> bootloader enters UART ISP (POWER CYCLE to recover!)");
                SerialUSB.println("   DATA_RDY=0 -> bootloader DFU (~10s) then normal return.");
                SerialUSB.flush(); delay(300);
                bootMethodF();
                break;
            }
            case 'g': {
                // Automated sweep: 128 combos of WDOG_CTRL x ROM_CFG x WDOG_COUNT
                // RESET_KEEP = 0x20+N tracks progress; each boot prints result
                // and fires the next combo.  Watch USB: if 0x1A86/0x55E0 appears,
                // that combo set BLM=1.  'q' aborts (normal reset, KEEP=0).
                uint8_t w0, r0, c0;
                sweepDecode(0, &w0, &r0, &c0);
                SerialUSB.print(">> SWEEP START: 128 combos. Firing combo 000:");
                SerialUSB.print(" W=0x"); if (w0<0x10) SerialUSB.print("0");
                SerialUSB.print((int)w0,HEX);
                SerialUSB.print(" R=0x"); if (r0<0x10) SerialUSB.print("0");
                SerialUSB.print((int)r0,HEX);
                SerialUSB.print(" C="); SerialUSB.println((int)c0);
                SerialUSB.println("   Monitor USB for VID=0x1A86/PID=0x55E0 (DFU = BLM success).");
                SerialUSB.flush();
                for (volatile uint32_t d = 0; d < 240000u; d++) {}
                sweepFire(0, w0, r0, c0);
                break;
            }
            case 'h': {
                // Wdog-overflow sweep: 32 combos (4 ROM_CFG × 8 WDOG_COUNT).
                // WDOG_CTRL = 0x06 (WDOG_INT_EN + WDOG_RST_EN) for all combos.
                // The chip resets via HARDWARE watchdog overflow (not software reset).
                // BLM=1 would confirm the datasheet wdog-overflow path works.
                uint8_t r0 = SWEEP_ROMCFG[0], c0 = SWEEP_COUNT[0];
                SerialUSB.print(">> WDOG_OVF SWEEP: 32 combos (W=0x06 always).");
                SerialUSB.print(" Firing combo 00: R=0x");
                if (r0<0x10) SerialUSB.print("0");
                SerialUSB.print((int)r0,HEX);
                SerialUSB.print(" C="); SerialUSB.println((int)c0);
                SerialUSB.println("   Monitor USB for VID=0x1A86/PID=0x55E0 (DFU = success).");
                SerialUSB.flush();
                for (volatile uint32_t d = 0; d < 240000u; d++) {}
                wdogOvfFire(0, r0, c0);
                break;
            }
            case 'i': {
                // Live register scan: iterate all combos, write registers, read BLM back.
                // No resets. If BLM becomes 1 live, we catch it here.
                static const uint8_t W[] = {0x00, 0x02, 0x04, 0x06};
                static const uint8_t R[] = {0x00, 0x40, 0x80, 0xC0};
                static const uint8_t C[] = {0, 64, 96, 127, 128, 150, 160, 191, 192, 255};
                uint8_t hit_wdog=0, hit_rom=0, hit_cnt=0;
                bool found = false;
                SerialUSB.println(">> LIVE SCAN: writing all combos, reading BLM after each...");
                SerialUSB.flush();
                for (uint8_t wi = 0; wi < 4 && !found; wi++) {
                    for (uint8_t ri = 0; ri < 4 && !found; ri++) {
                        for (uint8_t ci = 0; ci < 10 && !found; ci++) {
                            safeWrite8(&R8_RST_WDOG_CTRL, W[wi]);
                            safeWrite8(&R8_GLOB_ROM_CFG,  R[ri]);
                            R8_WDOG_COUNT = C[ci];
                            asm volatile("fence" ::: "memory");
                            uint8_t wc = R8_RST_WDOG_CTRL;
                            if (wc & 0x01u) {
                                hit_wdog = W[wi]; hit_rom = R[ri]; hit_cnt = C[ci];
                                found = true;
                            }
                        }
                    }
                }
                // Restore registers to safe state
                safeWrite8(&R8_RST_WDOG_CTRL, 0x00);
                safeWrite8(&R8_GLOB_ROM_CFG, 0x00);
                R8_WDOG_COUNT = 0;
                if (found) {
                    SerialUSB.print("*** BLM=1 LIVE! WDOG=0x"); SerialUSB.print((int)hit_wdog, HEX);
                    SerialUSB.print(" ROM=0x"); SerialUSB.print((int)hit_rom, HEX);
                    SerialUSB.print(" COUNT="); SerialUSB.println((int)hit_cnt);
                } else {
                    SerialUSB.println("   Scan done: BLM never became 1 (purely live / combinatorial).");
                }
                SerialUSB.flush();
                break;
            }
            case 'q': {
                SerialUSB.println(">> Abort sweep / plain software reset");
                SerialUSB.flush();
                for (volatile uint32_t d = 0; d < 120000u; d++) {}
                R8_GLOB_RESET_KEEP = 0x00;
                safeWrite8(&R8_RST_WDOG_CTRL, 0x01);
                while (1);
            }
            case 'v': {
                SerialUSB.println(">> Verify: setting WDOG_INT_EN + ROM_CODE_WE=0x40 + WDOG_COUNT=150 (no reset)");
                safeOr8(&R8_RST_WDOG_CTRL, RB_WDOG_INT_EN);
                safeOr8(&R8_GLOB_ROM_CFG, 0x40);
                R8_WDOG_COUNT = 150;
                SerialUSB.println(">> After writes:");
                printRegs();
                break;
            }
            default:
                break;
        }
    }
}
