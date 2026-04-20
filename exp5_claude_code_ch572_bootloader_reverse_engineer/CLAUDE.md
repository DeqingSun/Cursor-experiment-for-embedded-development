# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This repo is consists for serveral independent experiments. This exp5 is focuse on reverse engineer the dumped stock bootloader firmware and looking for way to jump from user code to bootloader and start DFU, without need to erase the first sector.

## Build & Flash Commands

```bash

# Compile the sketch
./compile_minimal_ch572.sh
# Output: arduino_cli/.tmp/build_minimal_ch572/minimal_ch572.ino.hex

# Flash to CH572 (requires ch55xRebootTool hardware connected via USB)
python3 upload_hex_ch572.py arduino_cli/.tmp/build_minimal_ch572/minimal_ch572.ino.hex
```

**Platform constraint:** 

## Architecture

### Toolchain

- **Arduino CLI** lives locally at `arduino_cli/bin/arduino-cli` (excluded from git via `.gitignore`)
- **Board FQBN:** `WCH:ch32v:CH572_EVT:pnum=CH572,upload_method=ispMethod,opt=osstd`
- **Compiler:** `riscv-wch-elf-g++` from `arduino_cli/data/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/riscv-wch-elf-g++`
- **Archetecture for GCC compile:** `-march=rv32imc_zba_zbb_zbc_zbs_xw`
- **Other GCC binary"** in `arduino_cli/data/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/`
- **Flash programmer:** `wchisp` (extracted from the Arduino CH32V package, auto-located by `upload_hex_ch572.py` by scanning version directories)

### Flash Workflow

The two-step upload process in `upload_hex_ch572.py`:
1. `reference/reboot.py` opens ch55xRebootTool (USB VID `0x1209`, PID `0xC550`) at 1200 baud — this triggers the CH572 to enter its USB bootloader
2. After 0.7s for re-enumeration, `wchisp` flashes the hex directly over USB (no serial port needed)

### Check if target is in DFU

The target show as a USB device with Device VendorID/ProductID: 0x1A86/0x55E0

### CH572 Memory Map

- User flash: `0x00000000–0x0002FFFF` (192 KB)
- Bootloader: `0x0003C000–0x0003FFFF` (8 KB, dumped in `reference/bootloader_dumpedHex.hex`)

## Reference Material

- `reference/CH572DS1.PDF` / `.md` / `.txt` — CH572 datasheet
- `reference/bootloader_dumpedHex.hex` — extracted 8 KB bootloader binary (load address `0x3C000`)
- `reference/ch572_dump_boot/ch572_dump_boot.ino` — sketch used to dump bootloader via `FLASH_ROM_READ()`
