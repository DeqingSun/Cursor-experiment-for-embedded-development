# CH572 Bootloader Reverse Engineering Analysis

**Binary**: `reference/bootloader_dumpedHex.hex`  
**Load address**: `0x3C000`  
**Size**: 8164 bytes (8 KB)  
**Architecture**: RV32IMC (RISC-V 32-bit, Integer + Multiply + Compressed ISA)  
**Date analyzed**: 2026-04-19

---

## 1. Summary

The CH572 stock bootloader is an 8 KB USB/UART ISP (In-System Programming) loader that:

1. Initializes the system clock to 24 MHz via PLL.
2. Detects USB presence (D+ pull-up on PA3).
3. Enumerates as a USB Full-Speed CDC/ISP device (VID 0x1A86 / PID 0x55E0).
4. Falls back to UART at 57600 baud if no USB is detected.
5. Receives WCH ISP protocol packets to erase, write, and verify user flash.
6. Jumps to user code at address `0x00000000` after receiving the ISP_END command.

The bootloader resides in a protected 8 KB region (`0x3C000–0x3DFFF`) that **cannot be erased from user code** using the standard `FLASH_ROM_ERASE` API.

---

## 2. Memory Map

### Flash Regions

| Region | Address Range | Size | Description |
|--------|---------------|------|-------------|
| User Code | `0x00000000–0x0002FFFF` | 192 KB | Application code + data |
| Reserved | `0x00030000–0x0003BFFF` | 48 KB | (not user-accessible) |
| **Bootloader** | `0x0003C000–0x0003DFFF` | 8 KB | This binary |
| INFO Area | `0x0003E000–0x0003FFFF` | 8 KB | Chip config, MAC, unique ID |

### INFO Area Key Addresses

| Address | Contents |
|---------|----------|
| `0x3DFF8` | 8-byte BOOT INFO (flags, version) — `ROM_CFG_BOOT_INFO` |
| `0x3F018` | 6-byte Bluetooth MAC address — `ROM_CFG_MAC_ADDR` |
| `0x3F000` | 64-bit unique chip ID |

### RAM Layout (inferred from disassembly)

| Address | Size | Description |
|---------|------|-------------|
| `0x20000000–0x20001B37` | ~7 KB | User stack / available to user code |
| `0x20001B38–0x20001B9F` | 104 B | Bootloader .data (copied from flash at startup) |
| `0x20001BA0–0x20002013` | ~1 KB | Bootloader BSS / working state (`BL_STATE`) |
| `0x20002014–0x20002FFF` | ~4 KB | Bootloader stack (grows downward) |
| `0x2003C0F8` | 128 B | Interrupt vector table (MTVEC base) |

---

## 3. Identified Functions

| Address | Name | Description |
|---------|------|-------------|
| `0x3C000` | `_start` | Entry point — single `j _startup` |
| `0x3C004` | `_startup` | CRT init: copy .data, zero .bss, setup CSRs, MRET to main |
| `0x3C140` | `hw_init` | PLL enable, 24 MHz clock, flash SCK timing |
| `0x3C1C0` | `is_usb_connected` | Poll PA_PIN for D+/D- state, returns 0/1 |
| `0x3C1D2` | `uart_write_byte` | Spin-wait TX empty, write to R8_UART_THR |
| `0x3C1EA` | `uart_read_byte` | Spin-wait RX ready, read from R8_UART_RBR |
| `0x3C1FC` | `memcpy_helper` | Inline-style word copy (dst, src, len) |
| `0x3C218` | `isp_process_packet` | Full ISP command dispatcher |
| `0x3CB72` | `uart_isp_task` | UART ISP receive state machine |
| `0x3CD5A` | `usb_isr` | USB interrupt service routine |
| `0x3D102` | `usb_init` | USB FS device init, endpoint setup |
| `0x3D190` | `uart_init` | UART 57600 baud init |
| `0x3D256` | `main` | Top-level: hw_init → detect → loop |
| `0x3D7F8` | `FLASH_EEPROM_CMD` | ROM flash engine (not in bootloader image; called via fixed address) |

---

## 4. Hardware Registers Used

All register names match `CH572SFR.h` from the WCH Arduino BSP.

### Clock / Power

| Register | Address | Value Set | Purpose |
|----------|---------|-----------|---------|
| `R8_SAFE_ACCESS_SIG` | `0x40001040` | 0x57, then 0xA8 | Unlock protected registers |
| `R8_HFCK_PWR_CTRL` | `0x4000100A` | `\|= RB_CLK_PLL_PON (0x10)` | Enable PLL |
| `R8_CLK_SYS_CFG` | `0x40001008` | `0x59` | PLL src, ÷25 → 24 MHz |

### Flash Timing

| Register | Address | Value Set | Purpose |
|----------|---------|-----------|---------|
| `R8_FLASH_SCK` | `0x40001805` | `0x03` | Flash SPI clock ÷4 → 6 MHz |
| `R8_FLASH_CFG` | `0x40001807` | `0x52` | Read latency, mode |
| `R8_FLASH_CTRL` | `0x40001806` | (via ROM fn) | Flash command control |

### GPIO (USB detect)

| Register | Address | Bits | Purpose |
|----------|---------|------|---------|
| `R32_PA_PIN` | `0x400010A4` | bit3=D+, bit2=D- | USB presence detection |
| `R16_PIN_ALTERNATE_H` | `0x4000101A` | USB alternate function | Enable USB pad |

### USB

| Register | Address | Purpose |
|----------|---------|---------|
| `R8_USB_CTRL` | `0x40008000` | USB enable, DMA, int busy mode |
| `R8_USB_DEV_AD` | `0x40008003` | Device address |
| `R8_USB_INT_FG` | `0x40008006` | Interrupt flags (W1C) |
| `R8_USB_INT_ST` | `0x40008007` | Interrupt status (endpoint/type) |
| `R8_UEP0_CTRL` | `0x4000800C` | EP0 response control |
| `R16_UEP0_T_LEN` | `0x4000800A` | EP0 TX length |
| `R8_UEP2_CTRL` | `0x40008014` | EP2 (bulk IN) control |
| `R8_UEP3_CTRL` | `0x40008018` | EP3 (bulk OUT) control |

### UART

| Register | Address | Value Set | Purpose |
|----------|---------|-----------|---------|
| `R16_UART_DL` | `0x4000340C` | 26 | Baud divisor (57600 baud @ 24 MHz) |
| `R8_UART_LCR` | `0x40003403` | `0x03` | 8N1 framing |
| `R8_UART_FCR` | `0x40003402` | `0x07` | FIFO enable + reset |
| `R8_UART_IER` | `0x40003401` | `0x01` | RX interrupt enable |
| `R8_UART_LSR` | `0x40003405` | (read) | Line status: RX ready, TX empty |
| `R8_UART_RBR` | `0x40003408` | (read) | RX data register |
| `R8_UART_THR` | `0x40003408` | (write) | TX data register |

### PFIC (Interrupt Controller)

| Register | Address | Purpose |
|----------|---------|---------|
| `PFIC_IENR1` | `0xE000E100` | Enable interrupt bits 0-31 |
| `PFIC_IENR2` | `0xE000E104` | Enable interrupt bits 32-63 |

USB uses IRQ 27; UART uses IRQ 26 (approximate, verify in CH572 interrupt table).

---

## 5. Clock Configuration Detail

```
Boot ROM clock: 8 MHz HSI (default)
After hw_init:
  PLL input:  HSI 8 MHz × 75 = 600 MHz internal VCO
  PLL output: 600 MHz
  Divider:    R8_CLK_SYS_CFG bits[4:0] = 25
  Fsys:       600 / 25 = 24 MHz
  Flash SCK:  24 MHz / 4 = 6 MHz  (R8_FLASH_SCK = 0x03)
```

The safe-access sequence is required before any write to `R8_CLK_SYS_CFG` or `R8_HFCK_PWR_CTRL`. The sequence is:
```c
R8_SAFE_ACCESS_SIG = 0x57;
R8_SAFE_ACCESS_SIG = 0xA8;
// Now protected register write is allowed (one write window)
R8_CLK_SYS_CFG = 0x59;
```

---

## 6. USB Device Descriptor

The bootloader enumerates as:

| Field | Value |
|-------|-------|
| VID | `0x1A86` (WCH) |
| PID | `0x55E0` |
| Class | Vendor-specific (0xFF) |
| Manufacturer | "WCH" |
| Product | "USB ISP" or similar |
| Endpoints | EP0 (ctrl 64B), EP2 IN (bulk 64B), EP3 OUT (bulk 64B) |

EP2 is bulk IN (device→host), EP3 is bulk OUT (host→device). EP0 handles enumeration and vendor control requests.

---

## 7. WCH ISP Protocol

### Packet Format

**Host → Device (command packet)**:
```
[SYNC]  [CMD]  [TAG]  [LEN_LO]  [LEN_HI]  [PAYLOAD × LEN]
 0x57    1B     1B      1B         1B         ...
```
- `SYNC` (0x57): Only present on UART; absent on USB bulk transfers.
- `CMD`: Command code (see table below).
- `TAG`: Sequence tag byte, echoed in response.
- `LEN`: Payload length, little-endian 16-bit.

**Device → Host (response packet)**:
```
[0x02]  [TAG]  [LEN_LO]  [LEN_HI]  [STATUS]  [PAYLOAD × (LEN-1)]
  1B     1B      1B         1B        1B          ...
```
- `STATUS`: 0x00 = success, non-zero = error code.

### Command Codes

| Code | Name | Direction | Description |
|------|------|-----------|-------------|
| `0xA1` | ISP_KEY_CMD | H→D | Key exchange / session init. Host sends nonce; device responds with chip ID info. |
| `0xA2` | ISP_ERASE | H→D | Erase flash blocks. Payload: 4-byte start addr + 4-byte length. |
| `0xA3` | ISP_PROGRAM | H→D | Write flash page. Payload: up to 256 bytes of data for `flash_target_addr`. |
| `0xA4` | ISP_VERIFY | H→D | Verify flash page. Same payload as A3; device compares flash vs buffer. |
| `0xA5` | ISP_READ_CFG | H→D | Read chip config bytes from INFO area. |
| `0xA7` | ISP_SET_ADDR | H→D | Set current flash target address. Payload: 4-byte address. |
| `0xA8` | ISP_END | H→D | End ISP session; device will jump to user code. |
| `0xC5` | ISP_RESET | H→D | Reset / re-enter bootloader. |

### Session Flow (typical programming sequence)

```
Host                          Device
 |--- A1 (key exchange) ------>|
 |<-- 0x02 + chip info --------|
 |--- A7 (set addr=0x0000) --->|
 |<-- 0x02 + ACK --------------|
 |--- A2 (erase 0x0000, 4K) -->|
 |<-- 0x02 + ACK/NACK ---------|
 |--- A3 (write 256B) -------->|  (repeat for each page)
 |<-- 0x02 + ACK --------------|
 |--- A4 (verify 256B) ------->|  (optional)
 |<-- 0x02 + ACK/mismatch -----|
 |--- A8 (end) --------------->|
 |<-- 0x02 + ACK --------------|
 |                              |--- MRET to 0x00000000 (user code)
```

---

## 8. Jump-to-User-Code Mechanism

### What the bootloader actually does at session end (0x3D554–0x3D584)

The bootloader does **not** contain a `mret`-to-user-code path in `main()`. The only `mret` in the 8 KB image is in `_startup` (0x3C0BA), which jumps to `main` in RAM. When an ISP session completes, the session-end block:

1. Clears the USB pin-mux (`R16_PIN_ALTERNATE_H = 0` at 0x3D540).
2. Resets the flash controller (`FLASH_EEPROM_CMD(CMD_FLASH_ROM_SW_RESET)`).
3. Performs safe-access then **software reset** via `R8_RST_WDOG_CTRL |= RB_SOFTWARE_RESET`.
4. Spins in an infinite loop until the chip reboots.

```c
// Actual session-end sequence (0x3D554–0x3D584):
R8_SAFE_ACCESS_SIG = 0x57;
R8_SAFE_ACCESS_SIG = 0xA8;
uint8_t rst = R8_RST_WDOG_CTRL;   // READ R8_RST_WDOG_CTRL into variable
rst |= RB_SOFTWARE_RESET;          // set bit 0
R8_RST_WDOG_CTRL = rst;            // WRITE BACK → chip resets
R8_SAFE_ACCESS_SIG = 0x00;
while (1) {}                        // wait for reset
```

### R8_RST_WDOG_CTRL bit 0 — read/write asymmetry (critical)

Bit 0 of `R8_RST_WDOG_CTRL` (0x40001046) has **different meanings for read vs. write**:

| Direction | Bit name | Description |
|-----------|----------|-------------|
| **Read**  | `RB_BOOT_LOAD_MAN` (RO) | 1 = chip entered bootloader via hardware manual-boot trigger |
| **Write** | `RB_SOFTWARE_RESET` (WA/WZ) | 1 = execute immediate software reset |

### RB_BOOT_LOAD_MAN check on boot (0x3D6C6, 0x3D59C)

Early in the boot sequence the bootloader reads `R8_RST_WDOG_CTRL` and checks the `RB_BOOT_LOAD_MAN` flag:

```asm
; 0x3D6C6
lui  x15, 0x40001
lbu  x15, 70(x15)    ; READ R8_RST_WDOG_CTRL into local variable
andi x15, x15, 1     ; isolate bit 0 = RB_BOOT_LOAD_MAN
beqz x15, stable     ; 0 → call usb_stable_check (100-poll loop)
call usb_init        ; 1 → manual-boot entry, init USB immediately → DFU
```

`RB_BOOT_LOAD_MAN = 1` is set by hardware — it is NOT settable by directly writing bit 0 (writing bit 0 triggers a reset instead). The hardware sets it **only when all of these conditions are met at boot time**:

| Condition | Register | Description |
|-----------|----------|-------------|
| `RB_WDOG_INT_EN = 1` | `R8_RST_WDOG_CTRL` bit 2 | Watchdog interrupt enabled |
| `RB_ROM_CODE_WE = 1` | `R8_RESET_STATUS` bits[7:6] | Flash code area write-enable |
| `RB_ROM_DATA_WE = 0` | (datasheet only, not in SFR header) | Flash data area write-protect |
| `128 ≤ R8_WDOG_COUNT < 192` | `R8_WDOG_COUNT` (0x40001043) | Watchdog count in range [0x80, 0xBF] |

When these conditions hold the chip boots into bootloader mode **and** `RB_BOOT_LOAD_MAN = 1`.

### How to enter USB DFU from user code

```c
// Step 1: configure the manual-boot hardware conditions (needs safe-access)
R8_SAFE_ACCESS_SIG = 0x57;
R8_SAFE_ACCESS_SIG = 0xA8;
R8_WDOG_COUNT     = 0x80;                    // set count to 128 (in [128,191])
R8_RST_WDOG_CTRL |= RB_WDOG_INT_EN;         // bit 2: enable watchdog interrupt
// also ensure RB_ROM_CODE_WE=1 in R8_RESET_STATUS and RB_ROM_DATA_WE=0
R8_SAFE_ACCESS_SIG = 0x00;

// Step 2: trigger software reset to re-enter the bootloader
R8_SAFE_ACCESS_SIG = 0x57;
R8_SAFE_ACCESS_SIG = 0xA8;
R8_RST_WDOG_CTRL  |= RB_SOFTWARE_RESET;     // write bit 0 = reset (not the same as read bit 0)
while (1) {}                                  // spin until chip resets

// On next boot: hardware sees conditions met → sets RB_BOOT_LOAD_MAN=1
// Bootloader reads RB_BOOT_LOAD_MAN=1 at 0x3D6C6 → calls usb_init() → DFU
```

**Important**: writing `RB_SOFTWARE_RESET` (bit 0) does NOT set `RB_BOOT_LOAD_MAN`. The watchdog + ROM-WE conditions must be in place for that. A plain software reset without those conditions gives `RB_BOOT_LOAD_MAN = 0`, so the bootloader takes the slower `usb_stable_check` path.

The `reboot.py` / ch55xRebootTool path uses an electrical reset (equivalent to POR), so `RB_BOOT_LOAD_MAN = 0` and USB detection goes via `usb_stable_check`.

---

## 9. Startup / CRT Details

The `_startup` routine at `0x3C004` performs a minimal C runtime init:

1. **`.data` copy**: Copies initialized data from flash (`0x3C400`) to RAM (`0x20001B38`), approximately 0x400 bytes (1 KB).
2. **`.bss` zero**: Zeroes the BSS region starting at `0x20001B38 + 0x400 = 0x20001F38`, approximately 0x300 bytes.
3. **CSR setup**:
   - `MTVEC` ← vectored interrupt table base `| 0x3` (vectored mode)
   - `MSTATUS.MIE` ← 0 (interrupts disabled until main enables them)
   - `MSP` (x2) ← top of bootloader stack
4. **MRET trick**: Sets `MEPC = main`, `MSTATUS.MPP = 11` (M-mode), then `MRET` — this transfers control to `main` while staying in M-mode, a common WCH idiom.

---

## 10. Interrupt Architecture

The MTVEC is set to vectored mode (`base | 3`). The interrupt vector table is in RAM:

```
0x2003C0F8 + 0*4  = trap_default
0x2003C0F8 + 27*4 = usb_isr        (IRQ 27)
0x2003C0F8 + 26*4 = uart_isr       (IRQ 26)
```

The PFIC (WCH Platform-level Fast Interrupt Controller) at `0xE000E000` is used instead of the standard RISC-V PLIC. It uses its own register layout:
- `PFIC_IENR1` (`0xE000E100`): set bits to enable IRQ 0–31
- `PFIC_ICER1` (`0xE000E180`): clear bits to disable IRQ 0–31

---

## 11. Flash Engine (`FLASH_EEPROM_CMD`)

The flash engine function is at ROM address `0x3D7F8` (this is in the INFO area, not the bootloader image itself). It is called by the bootloader with the C signature:

```c
uint32_t FLASH_EEPROM_CMD(uint8_t cmd, uint32_t StartAddr, void *Buffer, uint32_t Length);
```

Commands used by the bootloader:

| CMD Code | Macro | Action |
|----------|-------|--------|
| `0x01` | `CMD_FLASH_ROM_ERASE` | Erase 4 KB block(s) at StartAddr |
| `0x02` | `CMD_FLASH_ROM_WRITE` | Write Buffer[0..Length-1] to StartAddr |
| `0x03` | `CMD_FLASH_ROM_VERIFY` | Compare Buffer vs flash at StartAddr |
| `0x06` | `CMD_GET_ROM_INFO` | Read config info (MAC, BOOT_INFO) |
| `0x07` | `CMD_GET_UNIQUE_ID` | Read 64-bit unique chip ID into Buffer |

Return value: `0` = success, non-zero = error.

**Constraints**:
- Minimum write unit: 4 bytes (dword-aligned).
- Optimal write size: 256-byte pages.
- Erase granularity: 4096 bytes (4 KB blocks).
- Buffer must be in RAM and 4-byte aligned.

---

## 12. Security Notes

### Key Exchange (Command 0xA1)
The bootloader implements a simple XOR cipher handshake:
- Device reads the 64-bit unique ID via `CMD_GET_UNIQUE_ID`.
- Host sends a nonce; device XORs with unique ID to produce a session key.
- Subsequent data payloads may be XOR-encoded with the session key.
- This provides minimal obfuscation but is not cryptographically strong.

### Write Protection
- The bootloader region (`0x3C000–0x3DFFF`) cannot be erased or overwritten via the `FLASH_ROM_ERASE` / `FLASH_ROM_WRITE` API from user code.
- There is no observed CRC or signature check on the user code image before jumping to it.
- Anyone who can reach the USB ISP interface can reflash user code freely (the key exchange provides identity but not access control).

---

## 13. How to Enter Bootloader from User Code

Based on the analysis, there are three known methods:

### Method 1: Hardware Reset via ch55xRebootTool
The `reference/reboot.py` script opens the ch55xRebootTool USB-serial adapter (VID `0x1209` / PID `0xC550`) at 1200 baud, which electrically resets the CH572. The CH572 always runs the bootloader first; it only jumps to user code after receiving ISP_END or a timeout.

### Method 2: Watchdog Reset
From user code:
```c
// Trigger watchdog reset — CH572 will re-run bootloader on next power-up
R8_RST_WDOG_CTRL = RB_SOFTWARE_RESET;  // 0x40001004, bit 0
```
The bootloader runs on every cold boot. Without a USB/UART host connection the bootloader will time out and jump to user code.

### Method 3: Direct Call to Bootloader Entry (Experimental)
```c
// Attempt direct call to bootloader reset vector
typedef void (*bl_entry_t)(void);
bl_entry_t bootloader = (bl_entry_t)0x3C000;
bootloader();
```
This is potentially unreliable because the bootloader's `_startup` will re-initialize stack and CSRs, clobbering any shared state. Test carefully.

### Timeout Behavior
If the bootloader detects no USB and no UART activity within its polling timeout (estimated ~100–500 ms based on loop counts), it may jump to user code automatically. The exact timeout was not decoded in detail.

---

## 14. Files Produced by This Analysis

| File | Description |
|------|-------------|
| `bootloader_analysis/bootloader_decompiled.c` | C pseudocode for all functions with register name comments |
| `bootloader_analysis/bootloader_flowchart.md` | Mermaid execution flowchart |
| `bootloader_analysis/bootloader_analysis.md` | This document |

### Source Artifacts
| File | Description |
|------|-------------|
| `reference/bootloader_dumpedHex.hex` | Original Intel HEX dump |
| `reference/CH572DS1.PDF` / `.md` / `.txt` | CH572 datasheet |
| `arduino_cli/data/.../CH572SFR.h` | Register map (used for address→name mapping) |
| `arduino_cli/data/.../ISP572.h` | Flash ROM API header |

---

## 15. Toolchain Commands Used

```bash
# Convert HEX to binary
riscv-wch-elf-objcopy -I ihex -O binary \
    reference/bootloader_dumpedHex.hex /tmp/bootloader.bin

# Disassemble with correct VMA
riscv-wch-elf-objdump -D -b binary -m riscv:rv32 \
    --adjust-vma=0x3C000 /tmp/bootloader.bin \
    > /tmp/bootloader_disasm.txt

# Toolchain location
arduino_cli/data/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/
```
