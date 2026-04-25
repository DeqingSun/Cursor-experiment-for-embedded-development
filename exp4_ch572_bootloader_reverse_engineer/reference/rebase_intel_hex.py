#!/usr/bin/env python3
"""
Rebase Intel HEX so linear addresses in [ORIGIN, ...) map to [0, ...).

Default ORIGIN is 0x0003_0000 + 0xC000 == 0x0003C000 (matches bootloader_dumpedHex.hex).

Usage:
  python3 rebase_intel_hex.py [input.hex] [output.hex]
  python3 rebase_intel_hex.py --origin 0x3c000 in.hex out.hex
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def _parse_line(line: str) -> tuple[int, int, int, bytes] | None:
    line = line.strip()
    if not line.startswith(":"):
        return None
    try:
        raw = bytes.fromhex(line[1:])
    except ValueError as e:
        raise ValueError(f"bad hex line: {line!r}") from e
    if len(raw) < 5:
        raise ValueError(f"line too short: {line!r}")
    count = raw[0]
    addr_hi, addr_lo = raw[1], raw[2]
    addr = (addr_hi << 8) | addr_lo
    rectype = raw[3]
    data = raw[4 : 4 + count]
    csum = raw[4 + count]
    body = raw[: 4 + count]
    if (sum(body) + csum) & 0xFF:
        raise ValueError(f"checksum mismatch: {line!r}")
    return addr, rectype, count, data


def _checksum(body: bytes) -> int:
    return (-sum(body)) & 0xFF


def _emit_data(f, addr_lo: int, data: bytes) -> None:
    """Emit one Intel HEX data record (16-bit address only)."""
    count = len(data)
    body = bytes([count, (addr_lo >> 8) & 0xFF, addr_lo & 0xFF, 0x00]) + data
    f.write(f":{body.hex().upper()}{_checksum(body):02X}\n")


def parse_intel_hex(path: Path) -> list[tuple[int, bytes]]:
    """Return list of (linear_address, data_bytes) for each data record."""
    ela = 0
    out: list[tuple[int, bytes]] = []
    with path.open(encoding="ascii", errors="replace") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            parsed = _parse_line(line)
            if parsed is None:
                continue
            addr, rectype, count, data = parsed
            if rectype == 0x00:
                linear = (ela << 16) | addr
                out.append((linear, data))
            elif rectype == 0x01:
                break
            elif rectype == 0x02:
                if count != 2:
                    raise ValueError(f"line {lineno}: bad extended segment address length")
                esa = (data[0] << 8) | data[1]
                ela = esa << 4
            elif rectype == 0x03:
                # Start Segment Address — not used for data placement here
                pass
            elif rectype == 0x04:
                if count != 2:
                    raise ValueError(f"line {lineno}: bad extended linear address length")
                ela = (data[0] << 8) | data[1]
            elif rectype == 0x05:
                # Start Linear Address — entry point; caller may adjust separately
                pass
            else:
                raise ValueError(f"line {lineno}: unsupported record type 0x{rectype:02X}")
    return out


def write_intel_hex_from_image(path: Path, image: bytes, chunk: int = 16) -> None:
    """Write linear image starting at 0 using data records + EOF."""
    with path.open("w", encoding="ascii", newline="\n") as f:
        pos = 0
        while pos < len(image):
            block = image[pos : pos + chunk]
            _emit_data(f, pos, block)
            pos += len(block)
        f.write(":00000001FF\n")


def rebase_records(
    records: list[tuple[int, bytes]],
    origin: int,
    pad: int = 0xFF,
) -> bytes:
    """Build a dense byte image from relocated records; gaps filled with `pad`."""
    if not records:
        return b""
    new_addrs: list[tuple[int, bytes]] = []
    for linear, data in records:
        if linear < origin:
            raise ValueError(f"record at 0x{linear:X} is below origin 0x{origin:X}")
        na = linear - origin
        new_addrs.append((na, data))
    end = max(na + len(data) for na, data in new_addrs)
    buf = bytearray([pad & 0xFF] * end)
    for na, data in new_addrs:
        n = len(data)
        empty = bytes([pad & 0xFF]) * n
        if buf[na : na + n] != empty and buf[na : na + n] != data:
            overlap = bytes(buf[na : na + n])
            if overlap != data:
                raise ValueError(
                    f"overlapping differing data at 0x{na + origin:X} "
                    f"(rebased 0x{na:X})"
                )
        buf[na : na + n] = data
    return bytes(buf)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "input",
        nargs="?",
        default="bootloader_dumpedHex.hex",
        type=Path,
        help="input Intel HEX (default: bootloader_dumpedHex.hex)",
    )
    ap.add_argument(
        "output",
        nargs="?",
        default="bootloader_dumpedHex_from0.hex",
        type=Path,
        help="output Intel HEX (default: bootloader_dumpedHex_from0.hex)",
    )
    ap.add_argument(
        "--origin",
        type=lambda x: int(x, 0),
        default=0x0003C000,
        help="subtract this linear address from all data records (default: 0x3C000)",
    )
    ap.add_argument(
        "--pad",
        choices=("ff", "00"),
        default="ff",
        help="fill byte for gaps between records (default: ff)",
    )
    args = ap.parse_args()

    records = parse_intel_hex(args.input)
    if not records:
        print("no data records found", file=sys.stderr)
        return 1

    first = min(l for l, _ in records)
    last = max(l + len(d) for l, d in records) - 1
    print(f"input range: 0x{first:X} .. 0x{last:X} ({last - first + 1} bytes covered)")

    pad_byte = 0xFF if args.pad == "ff" else 0x00
    if args.origin > first:
        print(
            f"warning: origin 0x{args.origin:X} is above first record 0x{first:X}",
            file=sys.stderr,
        )

    buf = rebase_records(records, args.origin, pad_byte)
    write_intel_hex_from_image(args.output, buf)
    print(f"wrote 0x{len(buf):X} bytes to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
