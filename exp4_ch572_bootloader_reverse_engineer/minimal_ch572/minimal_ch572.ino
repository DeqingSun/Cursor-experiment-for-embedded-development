/*
 * CH572 Bootloader-in-RAM Experiment
 *
 * Bootloader ROM is at 0x3C000 (16 KB).  Its first 0xC0 bytes copy the body
 * (starting at 0x3C0C0) to native RAM 0x2003C000, then jump there.
 *
 * Key insight from an open-source project:
 *   The ROM code is RISC-V position-independent (PC-relative code + gp-relative
 *   globals).  We can copy the bootloader body to ANY RAM address and run it.
 *   By copying to 0x20000000 (low RAM) all addresses shift by -0x3C000:
 *     native RAM base  0x2003C000  →  our copy base  0x20000000
 *     native BSS       0x2003DBA0  →  our BSS        0x20001BA0
 *     native GP        0x2003E398  →  our GP         0x20002398
 *     native entry     0x2003D196  →  our entry      0x20001196
 *
 * Crucially, we PATCH the PA1 (USB D+) detection inside the RAM copy:
 *   ROM 0x3C1CC (= copy offset 0x10C = our RAM 0x2000010C):
 *     Original:  sltiu a0,a0,1   (0x00153513)  — checks if PA1 is high
 *     Patched:   c.li a0,1  (0x4505) + c.nop (0x0001) = 0x00014505
 *   → bootloader always thinks D+ is driven high → skips 10-s timer →
 *     enters USB DFU immediately and stays there indefinitely.
 *
 * Commands (send over USB-CDC, e.g. screen or minicom):
 *   r  — print current register snapshot
 *   d  — Method D: clean direct jump to ROM 0x3C000 (10-s DFU window)
 *   k  — Dry-run: copy + patch, then dump first bytes to verify (no jump)
 *   j  — Method J: copy bootloader to RAM, patch PA1, jump (indefinite DFU!)
 */

#include <SimpleUsbSerial.h>

// ── Helpers ──────────────────────────────────────────────────────────────────

__attribute__((section(".highcode")))
static void safeWrite8(volatile uint8_t *reg, uint8_t val)
{
    volatile uint32_t saved = __risc_v_disable_irq();
    asm volatile("fence.i");
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG1;
    R8_SAFE_ACCESS_SIG = SAFE_ACCESS_SIG2;
    asm volatile("fence.i");
    *reg = val;
    R8_SAFE_ACCESS_SIG = 0;
    __risc_v_enable_irq(saved);
    asm volatile("fence.i");
}

// ── Method D: direct jump to ROM bootloader ──────────────────────────────────
// No reset; bootloader gets a 10-second DFU window then resets back.

__attribute__((section(".highcode"), noinline))
void bootMethodD(void)
{
    // Disable all interrupts and USB peripheral
    *((volatile uint32_t *)0xE000E180) = 0xFFFFFFFF;
    *((volatile uint32_t *)0xE000E184) = 0xFFFFFFFF;
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    __asm volatile("fence.i" ::: "memory");
    R8_USB_INT_EN = 0x00;
    R8_USB_CTRL   = 0x00;
    R8_UDEV_CTRL  = RB_UD_PD_DIS;
    R16_PIN_ALTERNATE &= (uint16_t)~RB_UDP_PU_EN;  // pull D+ low

    // Brief settle so host sees disconnect
    for (volatile uint32_t i = 0; i < 48000; i++) __asm volatile("nop");

    // Jump to ROM bootloader entry point
    __asm volatile(
        "li t0, 0x3C000\n"
        "jr t0\n"
        ::: "t0", "memory"
    );
    __builtin_unreachable();
}

// ── Method J: copy bootloader to RAM, patch PA1 check + data-init call, jump ─
//
// Address map (ROM offset from 0x3C0C0  →  in our RAM copy at 0x20000000):
//   0x000  memcpy/memset helpers                   →  0x20000000
//   0x080  TRAMPOLINE entry ← we jump here         →  0x20000080  (= native 0x2003C080)
//            sets up clock, USB PHY (0x40001805/07), then calls main handler
//   0x0E6  auipc ra,0 + jalr ra,-182 (call 0x3C0F0) → 0x200000E6
//              ← PATCHED to two NOPs: skips data-init which would overwrite our copy
//   0x100  PA1 check function                      →  0x20000100  (= native 0x3C1C0)
//   0x10C  sltiu a0,a0,1  ← PATCHED to c.li a0,1  →  0x2000010C
//   0x1196 main handler                            →  0x20001196  (= native 0x3D256)
//   0x1B64 init data section (60 bytes)            →  0x20001B64
//   0x1BA0 BSS start (zeroed below)                →  0x20001BA0
//   0x2014 BSS end                                 →  0x20002014

#define ISPROM_ROM_SRC      0x3C0C0u      // bootloader body start in ROM
#define ISPROM_RAM_DST      0x20000000u   // where we copy it
#define ISPROM_SIZE         0x2000u       // bytes to copy
#define ISPROM_PATCH_ADDR   0x2000010Cu   // PA1 check: sltiu → c.li a0,1; c.nop
#define ISPROM_PATCH_VAL    0x00014505u   // c.li a0,1 (0x4505) + c.nop (0x0001)
#define ISPROM_BSS_START    0x20001BA0u
#define ISPROM_BSS_SIZE     0x474u
// Entry points (string macros needed for inline asm literals)
// Trampoline (offset 0x80):  sets up clock, copies USB descriptors, calls main handler.
//   This is equivalent to what the ROM does after its own self-copy (jump to 0x2003C080).
//   Preferred entry: runs full initialization sequence.
// Main handler (offset 0x1196): skips initialization, may miss USB descriptor setup.
#define ISPROM_GP_STR           "0x20002398"  // shifted global pointer
#define ISPROM_TRAMPOLINE_STR   "0x20000080"  // trampoline (full init, preferred)
#define ISPROM_MAINHANDLER_STR  "0x20001196"  // main handler only (skip init)

// NOTE: bootMethodJ must NOT have .highcode — it writes to 0x20000000 which
// overlaps our app's RAM (globals, .highcode section, SerialUSB state).
// Running from FLASH means our code isn't at that address.
// IMPORTANT: Do NOT disable R8_USB_CTRL (USB core). The bootloader's init
// (at 0x3D6E2 via 0x3D7F8) uses an I2C-like bus at 0x40001806 that only
// responds when the USB PHY is still powered. Setting R8_USB_CTRL=0 powers
// down the PHY and causes that spin-loop to hang forever → fast reset.
// Instead, just remove the D+ pull-up so the host sees a disconnect, and
// clear PFIC/MIE so no USB IRQ fires during the copy.
__attribute__((noinline))
void bootMethodJ(void)
{
    // 1. Tear down USB + pull D+ low so the host sees a disconnect.
    //    CRITICAL ORDER: USB_CTRL=0 FIRST (disables RB_UC_DEV_PU_EN pull-up from controller),
    //    THEN R16_PIN_ALTERNATE clear (disables GPIO D+ pull-up). Both sources must be cleared.
    *((volatile uint32_t *)0xE000E180) = 0xFFFFFFFF;  // PFIC IRER[0] — disable IRQs first
    *((volatile uint32_t *)0xE000E184) = 0xFFFFFFFF;  // PFIC IRER[1]
    __asm volatile("csrrci zero, mstatus, 8" ::: "memory");
    R8_USB_INT_EN = 0x00;
    R8_USB_CTRL   = 0x00;       // clears RB_UC_DEV_PU_EN → USB controller D+ pull-up off
    R8_UDEV_CTRL  = RB_UD_PD_DIS;
    R16_PIN_ALTERNATE &= (uint16_t)~RB_UDP_PU_EN;  // GPIO D+ pull-up off → D+ goes low
    for (volatile uint32_t i = 0; i < 48000u; i++) __asm volatile("nop");  // 1ms settle

    // 1b. Feed the IWDG and clear any pending system-WDT overflow flag before jumping.
    //     The ROM startup (0x3C000-0x3C0BF) which we skip normally does these housekeeping
    //     steps.  Without them the IWDG (if started by the BSP) would fire at ~0.8s.
    //     IWDG key 0xAAAA reloads the counter (harmless if IWDG not started).
    //     System-WDT ctrl: RB_WDOG_INT_FLAG=0x10 (R/W1 to clear), RB_WDOG_RST_EN=0x02
    //     (already 0 per printRegs), so we just write 0x10 to clear the overflow flag.
    //     Correct addresses from CH572SFR.h:
    //       0x40001000 = R32_IWDG_KR   (IWDG key register, no safe-access needed)
    //       0x40001040 = R8_SAFE_ACCESS_SIG
    //       0x40001046 = R8_RST_WDOG_CTRL
    *(volatile uint32_t *)0x40001000u = 0xAAAAu;  // IWDG feed (reload counter)
    *(volatile uint8_t  *)0x40001040u = 0x57u;    // safe-access SIG1
    *(volatile uint8_t  *)0x40001040u = 0xA8u;    // safe-access SIG2
    *(volatile uint8_t  *)0x40001046u = 0x10u;    // clear RB_WDOG_INT_FLAG (R/W1)
    *(volatile uint8_t  *)0x40001040u = 0x00u;    // close safe-access window

    // 2. Copy bootloader body to low RAM. This overwrites our app's global
    //    variables and .highcode section — that's OK since USB is already gone.
    //    Manual word-copy avoids calling library memcpy which may be in .highcode.
    {
        volatile uint32_t *dst = (volatile uint32_t *)ISPROM_RAM_DST;
        const volatile uint32_t *src = (const volatile uint32_t *)ISPROM_ROM_SRC;
        for (uint32_t i = 0; i < ISPROM_SIZE / 4; i++) dst[i] = src[i];
    }

    // 3. Patch PA1 check: sltiu a0,a0,1  →  c.li a0,1 ; c.nop
    *(volatile uint32_t *)ISPROM_PATCH_ADDR = ISPROM_PATCH_VAL;

    // 3b. Patch out the data-init call in the trampoline (ROM 0x3C1A6-0x3C1AD).
    //     Original:  auipc ra,0  (0x00000097) + jalr ra,-182 (0xF4A080E7) → calls 0x3C0F0
    //     0x3C0F0 copies user-flash data over 0x200000F8-0x20001B63 (our code!) → fatal.
    //     Replace both 4-byte instructions with NOP (addi zero,zero,0 = 0x00000013).
    //     The auipc+jalr for the MAIN HANDLER call (at offset +8) are left intact.
    //     Trampoline offset 0xE6: ROM 0x3C1A6 - 0x3C0C0 = 0xE6  → RAM 0x200000E6.
    //     IMPORTANT: 0xE6 is 2-byte aligned but NOT 4-byte aligned. RISC-V does not support
    //     unaligned 32-bit data writes (alignment fault). Use two uint16_t writes instead.
    *(volatile uint16_t *)0x200000E6u = 0x0013u;  // nop low  (was auipc ra,0 low half)
    *(volatile uint16_t *)0x200000E8u = 0x0000u;  // nop high (was auipc ra,0 high half)
    *(volatile uint16_t *)0x200000EAu = 0x0013u;  // nop low  (was jalr ra,-182 low half)
    *(volatile uint16_t *)0x200000ECu = 0x0000u;  // nop high (was jalr ra,-182 high half)

    // 4. Zero BSS (manual loop, same reason as above)
    {
        volatile uint32_t *p = (volatile uint32_t *)ISPROM_BSS_START;
        for (uint32_t i = 0; i < ISPROM_BSS_SIZE / 4; i++) p[i] = 0;
    }

    // 5. Flush instruction cache so CPU sees the newly written RAM code
    __asm volatile("fence.i" ::: "memory");

    // 6. Jump to the TRAMPOLINE. Use minimal CSR setup to avoid triggering
    //    exceptions from WCH-specific CSRs. Just update GP, SP, and jump.
    //    The trampoline itself will initialize USB PHY and other hardware.
    __asm volatile(
        ".option arch, +zicsr\n"
        "la   gp, " ISPROM_GP_STR          "\n"   // shifted GP for our copy
        "li   sp, 0x2003E800\n"                    // native bootloader stack top
        "li   t0, " ISPROM_TRAMPOLINE_STR  "\n"   // 0x20000080
        "jr   t0\n"
        ::: "gp", "sp", "t0", "memory"
    );
    __builtin_unreachable();
}

// ── Diagnostics ──────────────────────────────────────────────────────────────

static void printRegs(void)
{
    SerialUSB.println("=== Regs ===");
    SerialUSB.print("  WDOG_CTRL=0x"); SerialUSB.print(R8_RST_WDOG_CTRL, HEX);
    SerialUSB.print("  BLM=");        SerialUSB.print(R8_RST_WDOG_CTRL & 0x01);
    SerialUSB.print("  ROM_CFG=0x");  SerialUSB.print(R8_GLOB_ROM_CFG, HEX);
    SerialUSB.print("  RFLAG=");      SerialUSB.println(R8_GLOB_ROM_CFG & 0x07);
    SerialUSB.print("  RESET_KEEP=0x"); SerialUSB.println(R8_GLOB_RESET_KEEP, HEX);
    SerialUSB.println("Cmds: r d k w j");
    SerialUSB.flush();
}

// ── Arduino entry points ──────────────────────────────────────────────────────

void setup() { SerialUSB.begin(); }

void loop()
{
    static uint32_t lastPrint = 0;
    if (millis() - lastPrint > 5000) { lastPrint = millis(); printRegs(); }

    if (SerialUSB.available()) {
        char c = SerialUSB.read();
        switch (c) {
            case 'r':
                printRegs();
                break;
            case 'd':
                SerialUSB.println(">> Method D: direct ROM jump (10-s DFU window)");
                SerialUSB.flush(); delay(50);
                bootMethodD();
                break;
            case 'k': {
                // Read from ROM source WITHOUT copying (copy would corrupt our RAM state).
                // Shows what the bootloader code looks like and validates our address math.
                SerialUSB.println(">> ROM inspection (no copy — reading ROM source directly):");

                // Entry point: first 8 bytes of copy source = ROM 0x3C0C0
                SerialUSB.print("  ROM[0x3C0C0]+0 (copy start): ");
                for (int i = 0; i < 8; i++) {
                    uint8_t v = *(volatile uint8_t *)(ISPROM_ROM_SRC + i);
                    if (v < 0x10) SerialUSB.print("0");
                    SerialUSB.print(v, HEX); SerialUSB.print(" ");
                }
                SerialUSB.println();

                // Trampoline: ROM 0x3C140 = offset 0x80 (copied to RAM 0x20000080)
                SerialUSB.print("  ROM[0x3C140]+0x80 (trampoline): ");
                for (int i = 0; i < 8; i++) {
                    uint8_t v = *(volatile uint8_t *)(ISPROM_ROM_SRC + 0x80 + i);
                    if (v < 0x10) SerialUSB.print("0");
                    SerialUSB.print(v, HEX); SerialUSB.print(" ");
                }
                SerialUSB.print(" (expect: 41 11 06 c6 b7 01 40 40)");
                SerialUSB.println();

                // PA1 check: ROM 0x3C1CC = offset 0x10C (patched to RAM 0x2000010C)
                SerialUSB.print("  ROM[0x3C1C0]+0x100 (PA1 fn, 12 bytes): ");
                for (int i = 0; i < 12; i++) {
                    uint8_t v = *(volatile uint8_t *)(ISPROM_ROM_SRC + 0x100 + i);
                    if (v < 0x10) SerialUSB.print("0");
                    SerialUSB.print(v, HEX); SerialUSB.print(" ");
                }
                SerialUSB.print(" (at +0xC want: 13 35 15 00 = sltiu a0,a0,1)");
                SerialUSB.println();

                // also check     ram:0003c1cc 13 35 15 00     sltiu      a0,a0,0x1
                SerialUSB.print("  RAM[0x3c1cc]+0x10C (PA1 fn, 4 bytes): ");
                for (int i = 0; i < 4; i++) {
                    uint8_t v = *(volatile uint8_t *)(ISPROM_ROM_SRC + 0x10C + i);
                    if (v < 0x10) SerialUSB.print("0");
                    SerialUSB.print(v, HEX); SerialUSB.print(" ");
                }
                SerialUSB.println();

                // Main handler: ROM 0x3D256 = offset 0x1196
                SerialUSB.print("  ROM[0x3D256]+0x1196 (main hdlr): ");
                for (int i = 0; i < 8; i++) {
                    uint8_t v = *(volatile uint8_t *)(ISPROM_ROM_SRC + 0x1196 + i);
                    if (v < 0x10) SerialUSB.print("0");
                    SerialUSB.print(v, HEX); SerialUSB.print(" ");
                }
                SerialUSB.println();
                SerialUSB.flush();
                break;
            }
            case 'w': {
                // Diagnostic: test IWDG feed + safe-access write WITHOUT calling bootMethodJ.
                // If device survives → writes are safe. If crashes → writes cause issues.
                SerialUSB.print("WDOG_CTRL before: 0x");
                SerialUSB.println(R8_RST_WDOG_CTRL, HEX);
                SerialUSB.print("IWDG_CFG: 0x");
                SerialUSB.println(R32_IWDG_CFG, HEX);
                SerialUSB.flush();
                *(volatile uint32_t *)0x40001000u = 0xAAAAu;   // IWDG feed
                *(volatile uint8_t  *)0x40001040u = 0x57u;     // SIG1
                *(volatile uint8_t  *)0x40001040u = 0xA8u;     // SIG2
                *(volatile uint8_t  *)0x40001046u = 0x10u;     // clear INT_FLAG
                *(volatile uint8_t  *)0x40001040u = 0x00u;     // close safe-access
                SerialUSB.print("WDOG_CTRL after:  0x");
                SerialUSB.println(R8_RST_WDOG_CTRL, HEX);
                SerialUSB.println("Done.");
                SerialUSB.flush();
                break;
            }
            case 'j':
                SerialUSB.println(">> Method J starting...");
                SerialUSB.flush(); delay(50);
                bootMethodJ();
                break;
            default:
                break;
        }
    }
}
