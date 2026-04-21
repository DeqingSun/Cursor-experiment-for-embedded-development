#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

ARDUINO_PACKAGES="${ARDUINO_PACKAGES:-../arduino_cli/data/packages}"
TOOLBIN="${TOOLBIN:-${ARDUINO_PACKAGES}/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin}"
GDB="${GDB:-${TOOLBIN}/riscv-wch-elf-gdb}"
export GDB

if [[ ! -x "$GDB" ]]; then
  GDB="${HOME}/Library/Arduino15/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/riscv-wch-elf-gdb"
fi

if [[ ! -x "$GDB" ]]; then
  echo "ERROR: riscv-wch-elf-gdb not found. Set TOOLBIN or GDB." >&2
  exit 1
fi

if [[ ! -f build/ch572_pa11_blink.elf ]]; then
  echo "ERROR: build/ch572_pa11_blink.elf missing. Run make first." >&2
  exit 1
fi

echo "Using: $GDB"
exec "$GDB" -q -batch -x gdb_dump_ram_8k.gdb
