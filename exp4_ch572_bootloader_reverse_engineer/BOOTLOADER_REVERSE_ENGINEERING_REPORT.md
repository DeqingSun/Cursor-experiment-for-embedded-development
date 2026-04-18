# CH572 Bootloader Reverse Engineering Report

**Target:** `bootloader_dumpedHex.hex`  
**Load Address:** `0x0003C000` (Intel HEX extended linear address `0x0003`, data at offset `0xC000`)  
**Binary Size:** 8164 bytes (spanning `0x3C000` – `0x3DFE3`)  
**Toolchain:** `riscv-wch-elf-objdump -D -b binary -m riscv:rv32 --adjust-vma=0x3C000`  
**Architecture:** RV32IMC + Zba/Zbb/Zbc/Zbs/Xw extensions  
**Datasheet Reference:** CH572DS1.PDF / CH572DS1.md

---

## Memory Map Context

| Region | Address Range | Description |
|--------|--------------|-------------|
| User Flash (default) | `0x00000000 – 0x0002FFFF` | User application code (192 KB default) |
| User Flash (alt offset) | `0x00008000 – 0x0003BFFF` | When `RB_ROM_CODE_OFS=1` |
| **Bootloader Flash** | **`0x0003C000 – 0x0003FFFF`** | **This binary – factory-protected** |
| System RAM | `0x20000000 – 0x20003FFF` | 16 KB SRAM |
| Peripheral Bus | `0x40000000+` | All hardware registers |

The CH572 hardware always begins execution from the bootloader at `0x3C000`. The user application is never executed directly from reset; the bootloader decides whether to enter DFU mode or perform a software reset that (under the right register conditions) causes the chip to run user code.

---

## Key Peripheral Registers Referenced

| Address | Register Name | Usage in Bootloader |
|---------|--------------|---------------------|
| `0x40001008` | `R8_CLK_SYS_CFG` | Clock config write (0x59 = PLL mode) |
| `0x4000100A` | `R8_HFCK_PWR_CTRL` | External 32 MHz crystal power control |
| `0x40001018` | `R16_PIN_ALTERNATE` | GPIO pin function remapping |
| `0x4000101A` | `R16_PIN_ALTERNATE_H` | GPIO high pin function remapping |
| `0x40001040` | `R8_SAFE_ACCESS_SIG` | Write `0x57` then `0xA8` to unlock protected registers |
| `0x40001041` | `R8_CHIP_ID` | Read chip ID (used in BLE connection response) |
| `0x40001044` | `R8_GLOB_ROM_CFG` / `R8_RESET_STATUS` | Flash erase/write enable + reset cause flags |
| `0x40001045` | `R8_GLOB_CFG_INFO` | Bit 5 = `RB_BOOT_LOADER` (1 = currently in bootloader) |
| **`0x40001046`** | **`R8_RST_WDOG_CTRL`** | **Central to boot decision — see below** |
| `0x40001047` | `R8_GLOB_RESET_KEEP` | Reset-stable storage register |
| `0x40001800` | `R32_FLASH_DATA` | Flash read/write data register |
| `0x40001806` | `R8_FLASH_CTRL` | Flash controller command register |
| `0x40001807` | `R8_FLASH_CFG` | Flash configuration register |
| `0x400010A0` | `R32_PA_DIR` | PA GPIO direction (set PA0/PA1 as inputs) |
| `0x400010A4` | `R32_PA_PIN` | PA GPIO pin input — **used for USB D+/D− detection** |
| `0x400010A8` | `R32_PA_OUT` | PA GPIO output data |
| `0x400010B4` | `R32_PA_PD_DRV` | PA pull-down / drive strength |
| `0x40002400` | USB controller base | USB peripheral setup for DFU |
| `0x4000240C` | USB endpoint register | Endpoint data/config |
| `0x40003400` | UART3 base | UART3 for ISP communication |
| `0x40008000` | BLE controller base | BLE peripheral (DFU over BLE) |
| `0x40008006` | BLE status register | Bits [2:0] = BLE connection state |

---

## R8_RST_WDOG_CTRL (0x40001046) — The Boot Decision Register

This register has dual-use bit 0, as noted in the datasheet:

| Bit | Name (Read) | Name (Write) | Description |
|-----|------------|-------------|-------------|
| 4 | `RB_WDOG_INT_FLAG` | `RB_WDOG_INT_FLAG` | Watchdog overflow flag (write 1 to clear) |
| 2 | `RB_WDOG_INT_EN` | `RB_WDOG_INT_EN` | Watchdog interrupt enable |
| 1 | `RB_WDOG_RST_EN` | `RB_WDOG_RST_EN` | Watchdog reset enable |
| **0** | **`RB_BOOT_LOAD_MAN`** | **`RB_SOFTWARE_RESET`** | **Read: manual boot flag. Write 1: trigger software reset** |

**Crucial Rule (from datasheet):**  
When `RB_SOFTWARE_RESET` is written as `1`, a software reset occurs. The chip restarts. On restart, **`RB_BOOT_LOAD_MAN = 1`** if and only if ALL of the following were true at reset time:
- `RB_WDOG_INT_EN = 1`  
- `RB_ROM_CODE_WE = 1` (bits [7:6] of `R8_GLOB_ROM_CFG`)  
- `RB_ROM_DATA_WE = 0`  
- `128 ≤ R8_WDOG_COUNT < 192`

Otherwise after reset, **`RB_BOOT_LOAD_MAN = 0`**.

The bootloader flash write function (`0x3D7F8`) always **clears** `RB_ROM_CODE_WE` back to 0 after completing a flash operation (see `0x3D8EA`: `andi a4,a4,16; sb a4,68(a5)`). This means that after a DFU firmware flash write, triggering `RB_SOFTWARE_RESET=1` results in `RB_BOOT_LOAD_MAN=0` on restart — the normal "boot to app" path.

---

## Bootloader Flowchart

```
Reset / Power-on
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│ STARTUP (0x3C000 → 0x3C004)                                     │
│  1. JAL to 0x3C004 (skip 1 padding instruction)                │
│  2. Setup GP = 0x2003E398, SP = 0x2003E800                     │
│  3. COPY SECTION 1: flash 0x3C0C0 → RAM 0x2003C000 (248 bytes) │
│  4. COPY SECTION 2: flash 0x3DC24 → RAM 0x2003DB64 (60 bytes)  │
│  5. ZERO BSS: RAM 0x2003DBA0 → 0x2003E014                      │
│  6. CSR 0xBC0 = 31 (WCH custom: interrupt threshold)           │
│  7. CSR 0x804 = 3  (WCH custom: interrupt config)              │
│  8. MSTATUS |= 0x88 (MIE + MPIE enable)                        │
│  9. MTVEC = 0x2003C0FB (vectored mode, table at 0x2003C0F8)    │
│ 10. MEPC  = 0x2003C080 (→ RAM copy of 0x3C140 code)           │
│ 11. MRET → begin executing from RAM (0x2003C080)              │
└─────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│ CLOCK & PERIPHERAL INIT (original flash: 0x3C140)              │
│  Read R8_HFCK_PWR_CTRL (0x4000100A) bit 4                      │
│   ├─ bit4=0 (32MHz crystal NOT running):                        │
│   │    Safe-access unlock (0x57, 0xA8 → 0x40001040)            │
│   │    Enable XT32M crystal, wait ~480 µs delay loop           │
│   └─ bit4=1: crystal already running, skip                      │
│                                                                  │
│  Safe-access unlock                                             │
│  Write R8_CLK_SYS_CFG (0x40001008) = 0x59 (PLL clock mode)    │
│  Write R8_FLASH_CTRL  (0x40001806) = 0x10                      │
│  Write R8_FLASH_CFG   (0x40001807) = 0x07                      │
│  Write R8_SAFE_ACCESS_SIG = 0x00 (lock)                         │
│  Write R8_GLOB_CFG_INFO spare bits                              │
│                                                                  │
│  Call: init_ble_params() @ 0x3C0F0                              │
│    (Copies BLE timing tables from flash 0x3FF4 region to RAM)   │
│                                                                  │
│  Call: main_bootloader() @ 0x3D256                              │
└─────────────────────────────────────────────────────────────────┘
       │
       ▼
══════════════════════════════════════════════════════════════════
          MAIN BOOTLOADER DECISION FUNCTION (0x3D256)
══════════════════════════════════════════════════════════════════
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ INITIALIZE state variables in RAM (0x20001Bxx region)         │
│  - Clear: connection state, DFU flags, sequence counters      │
│  - Set:   boot_active=1, bd_addr_valid=1                      │
└──────────────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ FLASH CONFIG READ (via flash_op() @ 0x3D7F8)                  │
│  Read 12 bytes from flash 0x3EFF4 → buffer @0x20001BE4        │
│  (This area holds BLE bonding/config data at end of          │
│   bootloader flash region)                                    │
└──────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────────────┐
│ CHECK: config[0] (word at 0x3EFF4) == 0xFFFFFFFF ?              │
│  (0xFFFFFFFF = erased flash = no valid config written)          │
└─────────────────────────────────────────────────────────────────────┘
       │                         │
  YES (== 0xFFFFFFFF)       NO (has data)
       │                         │
       ▼                         ▼
┌──────────────────┐    ┌──────────────────────────────────────────┐
│ CHECK config[1]  │    │ LOAD BLE CONFIG from flash area          │
│ AND config[2]    │    │ Read BLE pairing slots from flash        │
│ == 0xFFFFFFFF?   │    │ Extract: BLE device address, channel    │
│ (all 3 erased)   │    │  map, connection interval params        │
└──────────────────┘    └──────────────────────────────────────────┘
   │        │                         │
  YES      NO                         ▼
   │        │              ┌──────────────────────────────────────┐
   │        │              │ Extract validity bit from config word │
   │        │              │ (bit 0 after shift = app_valid flag) │
   │        │              └──────────────────────────────────────┘
   │        │                    │              │
   │        │               app_valid=1    app_valid=0
   │        │                    │              │
   │        │                    ▼              │
   │        │    ┌───────────────────────────┐  │
   │        │    │ Init UART3 for ISP        │  │
   │        │    │  @ 0x3D190               │  │
   │        │    │ (R8 UART3 @ 0x40003400)  │  │
   │        │    │ Configure baud rate,      │  │
   │        │    │  enable RX/TX            │  │
   │        │    └───────────────────────────┘  │
   │        │                    │              │
   │        └────────────────────┼──────────────┘
   │                             │
   │                             ▼
   │              ┌─────────────────────────────────────┐
   │              │ CHECK: "first_boot_done" flag in RAM │
   │              │  (var @ ~0x20001BCE)                │
   └──────────────┤                                     │
                  └─────────────────────────────────────┘
                          │               │
                   flag=0 (first run) flag≠0 (already init'd)
                          │               │
                          ▼               └──────────────┐
                ╔═══════════════════════════════════════╗  │
                ║  ★ KEY BOOT DECISION (0x3D59C/3D6C6) ║  │
                ║                                       ║  │
                ║  Read R8_RST_WDOG_CTRL (0x40001046)  ║  │
                ║  Check bit 0: RB_BOOT_LOAD_MAN       ║  │
                ╚═══════════════════════════════════════╝  │
                          │               │               │
                   bit0=1             bit0=0              │
              (Software reset      (Normal POR /          │
               was triggered        watchdog /            │
               WITH boot flag)      external reset)       │
                          │               │               │
                          ▼               ▼               │
              ┌──────────────┐  ┌─────────────────────┐  │
              │ FORCE BLE DFU│  │ USB D+ CHECK         │  │
              │ (stay in BL) │  │ (0x3D1F0)           │  │
              └──────────────┘  │                     │  │
                          │     │ Set PA0,PA1=input   │  │
                          │     │ Enable PA1 pull-down │  │
                          │     │ Read R32_PA_PIN      │  │
                          │     │ (0x400010A4)         │  │
                          │     │ Check bits [1:0]:    │  │
                          │     │  PA1=D+, PA0=D−     │  │
                          │     └─────────────────────┘  │
                          │            │        │         │
                          │      [1:0]==0b10  [1:0]≠0b10 │
                          │     (D+=1,D−=0)  (not USB)   │
                          │     USB connected             │
                          │            │        │         │
                          │            ▼        │         │
                          │   ┌──────────────┐  │         │
                          │   │ Loop 99×:    │  │         │
                          │   │ re-check     │  │         │
                          │   │ PA[1:0]==2?  │  │         │
                          │   └──────────────┘  │         │
                          │       │       │      │         │
                          │  99× confirmed  not consistent│
                          │       │         → return       │
                          │       ▼              │         │
                          │  ┌──────────────────┐│         │
                          │  │ JUMP to BLE DFU  ││         │
                          │  │ (= Force DFU     ││         │
                          │  │   via 0x3D102)   ││         │
                          │  └──────────────────┘│         │
                          │                      │         │
                          └──────────────────────┴─────────┘
                                               │
                                               ▼
                          ┌────────────────────────────────────┐
                          │  No USB, no manual boot flag       │
                          │  → enter main DFU loop (0x3D3CC)  │
                          │    with no active connection       │
                          │  → watchdog fires if enabled,      │
                          │    or loop indefinitely if not     │
                          └────────────────────────────────────┘
                                               │
          (falls into main DFU waiting loop) ──┤
                                               │
═══════════════════════════════════════════════════════════════════
              MAIN DFU LOOP (0x3D3CC) — Polling Loop
═══════════════════════════════════════════════════════════════════
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ SETUP USB peripheral (0x40002400)      │
                          │ Store magic value 0xAAAA on stack      │
                          │ Begin poll loop (0x3D410)              │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ POLL BLE (0x40008006 bits[2:0])        │
                          │   If BLE connected → dispatch BLE DFU │
                          │   handler (0x3CD5A)                   │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ POLL UART3 RX (R8 @ 0x40003405 bit0)  │
                          │   If UART3 byte ready → process ISP   │
                          │   command, route to flash_op()        │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ POLL USB endpoint (0x40002406 bit0)   │
                          │   If USB data → process DFU packet    │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ KICK WATCHDOG: write to R32_IWDG_KR   │
                          │ (0x40001000) to prevent reset         │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ TIMEOUT CHECK (0x3D690-0x3D6B0)       │
                          │  counter > 199 → check PA0 (D− line)  │
                          │  PA[0]=0 → no USB → return            │
                          └───────────────────────────────────────┘
                                               │
                                        [loop back]
                                               │
═══════════════════════════════════════════════════════════════════
         DFU COMPLETION PATH (after firmware write verified)
═══════════════════════════════════════════════════════════════════
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ BLE PAIRING / BONDING WRITE (0x3D4F8)  │
                          │  flash_op(cmd=2, addr=0x3EFF4, ...)   │
                          │  Write BLE keys/config to end of BL   │
                          │  flash region                         │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ FIRMWARE ERASE (0x3D4C8)               │
                          │  flash_op(cmd=1, addr=0x3E000)        │
                          │  Erase app-adjacent config sector     │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ FIRMWARE WRITE (0x3D7F8 cmd=2)         │
                          │  Write new user firmware to flash     │
                          │  NOTE: flash_op() CLEARS              │
                          │  RB_ROM_CODE_WE after each operation  │
                          │  (R8_GLOB_ROM_CFG & 0x10 only)       │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ FIRMWARE VERIFY (cmd=3/4)              │
                          │  Read back and compare CRC/data       │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ DISCONNECT PA pins:                    │
                          │  Clear R16_PIN_ALTERNATE_H bit 26     │
                          │  (0x4000101A) = 0 (disable USB pins)  │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ Safe-access UNLOCK (0x57,0xA8 → SIG)  │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ TRIGGER SOFTWARE RESET (0x3D574):     │
                          │  a4 = R8_RST_WDOG_CTRL                │
                          │  a4 |= 1  (RB_SOFTWARE_RESET = 1)    │
                          │  R8_RST_WDOG_CTRL = a4                │
                          │                                       │
                          │  *** BECAUSE RB_ROM_CODE_WE was       │
                          │  cleared by flash_op(), the           │
                          │  condition for RB_BOOT_LOAD_MAN=1    │
                          │  is NOT met. After reset:             │
                          │      RB_BOOT_LOAD_MAN = 0            │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ R8_SAFE_ACCESS_SIG = 0 (lock)         │
                          │ INFINITE LOOP (0x3D584: c.j 0x3D584)  │
                          │  ... waiting for hardware reset       │
                          └───────────────────────────────────────┘
                                               │
                          ┌────────────────────▼──────────────────┐
                          │ HARDWARE RESETS CHIP                   │
                          │ Bootloader runs again from 0x3C000    │
                          │ This time:                            │
                          │   RB_BOOT_LOAD_MAN = 0               │
                          │   USB likely not connected            │
                          │   Flash has valid user firmware       │
                          │ → Decision: no DFU needed             │
                          │ → Enters main loop with no commands   │
                          │ → (Watchdog fires if enabled →        │
                          │    reset → hardware ROM runs user app)│
                          └───────────────────────────────────────┘
```

---

## Summary: When Does the Bootloader Stay vs. Boot App?

### STAYS IN BOOTLOADER (DFU mode) — Any of these conditions:

| # | Condition | Where Checked | Details |
|---|-----------|--------------|---------|
| 1 | `RB_BOOT_LOAD_MAN = 1` | `0x3D5A0`, `0x3D6CA` | Bit 0 of `R8_RST_WDOG_CTRL` (0x40001046). Set when a software reset was triggered while `RB_ROM_CODE_WE=1`, `RB_WDOG_INT_EN=1`, `RB_ROM_DATA_WE=0`, and `128 ≤ WDOG_COUNT < 192` |
| 2 | USB D+ line detected | `0x3D1F0`, `0x3C1C0` | `R32_PA_PIN` (0x400010A4) bits [1:0] == 0b10 (D+=high, D−=low), confirmed 99 consecutive times. Likely a USB-UART programmer cable holding D+ high |
| 3 | Flash is completely erased AND RB_BOOT_LOAD_MAN=1 | `0x3D5E4` | Virgin/erased device with boot flag → BLE DFU |
| 4 | BLE host connects | Main loop `0x3D620-0x3D634` | BLE controller at 0x40008000 has connection (`0x40008006 & 7 ≠ 0`) → starts BLE DFU |
| 5 | UART3 ISP command received | Main loop `0x3D638-0x3D664` | UART3 RX flag (`0x40003405` bit 0 set) while waiting → starts ISP session |

### BOOTS TO USER APPLICATION — All of these must be true:

| Condition | Description |
|-----------|-------------|
| `RB_BOOT_LOAD_MAN = 0` | Bit 0 of `R8_RST_WDOG_CTRL` is clear (normal reset, not software reset with boot flag) |
| USB D+ NOT consistently detected | `R32_PA_PIN` bits [1:0] ≠ 0b10 for 99 consecutive samples |
| No BLE/UART ISP activity in main loop | No DFU traffic within timeout window |
| DFU was completed (if applicable) | Flash write clears `RB_ROM_CODE_WE` → next software reset gives `RB_BOOT_LOAD_MAN=0` |

**The "jump to user app" mechanism:** After the software reset at `0x3D574` (with `RB_BOOT_LOAD_MAN=0`), the bootloader re-runs, finds no DFU conditions, and the chip's hardware arbitration (based on reset flags and chip state) allows normal user code execution. The bootloader does not explicitly `jalr` to `0x0000`; instead it relies on the reset/power-on hardware path to load the user vector table from `0x00000000`.

---

## DFU Protocol Subsystems

### BLE DFU Init (0x3D102)
- Clears USB-related registers in PA port (`R32_USB_STATUS` area at `0x400010A0`)
- Initializes BLE controller (`0x40008000`):
  - Sets BLE buffer address in `0x40008010` (= `0x20001E8C`)
  - Sets BLE RX buffer in `0x40008018`
  - Configures `R8_BLE_CTRL_0x40008001 = 0x80` (reset)
  - Sets BLE mode (`0x40008006 = 0xFF`)
  - Enables BLE (`0x40008001 |= 1`)
  - Disables advertisement start flags

### UART3 ISP Init (0x3D190)
- Writes baud rate to `0x4000340C` (UART3 baud = 26, ≈ ~921600 bps at 24 MHz)
- Sets data format in `0x40003402` (`-127` = 8N1 config)
- Configures mode in `0x40003403`
- Enables channel `0x40003401 = 0x45`
- Enables UART3 module (`0x40003400 |= 0x08`)
- Remaps PA pins via `R16_PIN_ALTERNATE_H` (0x4000101A) bits to UART3 function

### Flash Operation Function (0x3D7F8)
Dispatcher taking: `a0=cmd, a1=addr, a2=buf, a3=len`

| Command | Operation | Notes |
|---------|-----------|-------|
| 1 | Erase sector (4 KB or 64 KB) | Chooses size based on alignment |
| 2 | Write flash | Word-aligned, 4 bytes at a time |
| 3 | Verify flash (read + compare) | Used for post-write verification |
| 4 | Erase page (smaller unit) | — |
| 9 | Flash erase (alternate) | — |
| 12 | Flash read (word) | `bltu a4, a5, 0x3D9B0` handler |
| 13 | Flash read (byte) | `0x3D9F6` handler |

Before any flash op: saves NVIC ISER0/1, unlocks safe access, sets `RB_ROM_CODE_WE=11`.  
After any flash op: restores NVIC, **clears `RB_ROM_CODE_WE` back to bit4-only state**.

---

## Interrupt Vector Table

At runtime, `MTVEC = 0x2003C0FB` (base `0x2003C0F8`, vectored mode=3).  
The vector table area in flash at `0x3DC60`–`0x3DFXX` contains WCH-format vectored interrupt entries (pairs of `C.J` + `C.BNEZ` instructions, each 4 bytes per IRQ channel).

---

## Key Data Structures in RAM

| RAM Address | Description |
|------------|-------------|
| `0x2003E800` | Stack top (SP at start) |
| `0x2003E398` | Global pointer (GP) |
| `0x2003C000`–`0x2003C0F7` | Code copied from flash 0x3C0C0 (main bootloader logic) |
| `0x2003C0F8` | Interrupt vector table base |
| `0x2003DB64`–`0x2003DBA0` | Initialized data (USB descriptors etc., from flash 0x3DC24) |
| `0x2003DBA0`–`0x2003E014` | BSS (zero-initialized) |
| `0x20001B98`–`0x20001B9F` | BLE key material |
| `0x20001BA0` | BLE DFU state slot 0 |
| `0x20001BB4` | Min connection interval |
| `0x20001BBC`–`0x20001BC3` | AES/encryption key bytes |
| `0x20001BC5` | `ble_active` flag |
| `0x20001BC6` | `uart_mode` flag |
| `0x20001BD0` | `boot_active` flag |
| `0x20001BE0`–`0x20001BEE` | DFU state machine variables |
| `0x20001BF0` | BLE RX buffer base |
| `0x20001E8C`–`0x20001EFF` | BLE pairing/bonding data buffer |
| `0x20001F10` | Current BLE connection handle area |
| `0x20002014` | BSS end marker |

---

## Complete Decision Tree (Compact)

```
Power-on / Any Reset
  └─> Bootloader runs from 0x3C000
       ├─ Clock init (32MHz crystal + PLL)
       ├─ Data copy (flash→RAM)
       ├─ Read BLE config from flash 0x3EFF4
       │
       ├─ [Flash all 0xFF? = virgin device]
       │    └─> Check RB_BOOT_LOAD_MAN (R8_RST_WDOG_CTRL[0])
       │         ├─ =1  ──→ BLE DFU mode (0x3D102) → DFU Loop
       │         └─ =0  ──→ USB check (0x3D1F0)
       │                      ├─ USB detected 99× ──→ BLE DFU mode → DFU Loop
       │                      └─ No USB ──────────→ DFU waiting loop (idle)
       │
       └─ [Flash has data = app config exists]
            └─ Check RB_BOOT_LOAD_MAN (R8_RST_WDOG_CTRL[0])
                 ├─ =1  ──→ BLE DFU mode (0x3D102) → DFU Loop
                 └─ =0  ──→ USB check (0x3D1F0)
                               ├─ USB detected 99× ──→ BLE DFU mode → DFU Loop
                               └─ No USB ──→ UART3 ISP init (if app_valid)
                                              └─> DFU Loop (idle, polling)
                                                    ├─ BLE connects → BLE DFU
                                                    ├─ UART3 data → ISP DFU
                                                    ├─ DFU done → SW Reset
                                                    │    └─> (RB_BOOT_LOAD_MAN=0)
                                                    │         Chip boots user app
                                                    └─ Timeout → [loop / WD reset]
```

---

## Assigning the Boot-Flag: How to Force Bootloader Mode from User Code

From user application code, to trigger DFU next reset:

```c
// In user application — force bootloader on next reset
// Requirements: WDOG_INT_EN=1, ROM_CODE_WE=1, ROM_DATA_WE=0, 128≤WDOG_COUNT<192

// 1. Unlock safe access
R8_SAFE_ACCESS_SIG = 0x57;
R8_SAFE_ACCESS_SIG = 0xA8;

// 2. Enable watchdog interrupt (required for RB_BOOT_LOAD_MAN=1 condition)
R8_RST_WDOG_CTRL |= (1 << 2);  // RB_WDOG_INT_EN = 1

// 3. Enable flash code write (required condition)
R8_GLOB_ROM_CFG |= (3 << 6);   // RB_ROM_CODE_WE = 11b

// 4. Set watchdog counter to a value in [128, 192)
R8_WDOG_COUNT = 150;

// 5. Trigger software reset WITH boot flag
R8_RST_WDOG_CTRL |= 1;   // RB_SOFTWARE_RESET = 1 → resets chip
                           // On restart: RB_BOOT_LOAD_MAN = 1
                           // → Bootloader enters BLE DFU mode
```

---

*Report generated by reverse engineering `bootloader_dumpedHex.hex` using `riscv-wch-elf-objdump` and cross-referencing the CH572DS1 datasheet.*
