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
        R8_GLOB_RESET_KEEP = 0x00;  // clear marker
    }

    SerialUSB.println("=========================");
    SerialUSB.println("Cmds: r 1-9 a=diagnostic b=APPJumpBoot(!) v=verify");
    SerialUSB.flush();
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
