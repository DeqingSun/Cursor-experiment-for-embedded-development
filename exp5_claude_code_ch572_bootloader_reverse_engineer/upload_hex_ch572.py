#!/usr/bin/env python3
"""
Upload a .hex to CH572 via WCH-ISP (wchisp from the Arduino CH32V package).

1) Runs reference/reboot.py to pulse the ch55xRebootTool (1200 baud) so the target enters bootloader.
2) Runs wchisp flash on the hex (USB; no serial port argument).

Only argument: path to the Intel HEX file.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from pathlib import Path


def _find_wchisp(script_dir: Path) -> Path:
    tools_root = script_dir / "arduino_cli" / "data" / "packages" / "WCH" / "tools" / "wchisp"
    if not tools_root.is_dir():
        raise FileNotFoundError(
            f"wchisp tool directory not found at {tools_root}. Run setup_ch572_arduino.sh."
        )
    candidates: list[Path] = []
    for version_dir in sorted(tools_root.iterdir()):
        if not version_dir.is_dir():
            continue
        exe = version_dir / "wchisp"
        if exe.is_file():
            candidates.append(exe)
    if not candidates:
        raise FileNotFoundError(f"No wchisp binary under {tools_root}")
    # Prefer the lexicographically last version folder (newest tag from index).
    return candidates[-1]


def main() -> int:
    parser = argparse.ArgumentParser(description="Reboot CH572 via ch55xRebootTool, then flash HEX with wchisp.")
    parser.add_argument(
        "hex_file",
        type=Path,
        help="Intel HEX file to flash",
    )
    args = parser.parse_args()
    hex_path = args.hex_file.resolve()
    if not hex_path.is_file():
        print(f"ERROR: HEX file not found: {hex_path}", file=sys.stderr)
        return 2
    if hex_path.suffix.lower() not in (".hex",):
        print("ERROR: Expected a .hex file.", file=sys.stderr)
        return 2

    script_dir = Path(__file__).resolve().parent
    reboot_py = script_dir / "reference" / "reboot.py"
    if not reboot_py.is_file():
        print(f"ERROR: reboot.py not found at {reboot_py}", file=sys.stderr)
        return 2

    print(f"Running {reboot_py} ...", flush=True)
    r = subprocess.run([sys.executable, str(reboot_py)], check=False)
    if r.returncode != 0:
        print(f"WARNING: reboot.py exited with code {r.returncode}", file=sys.stderr)

    # Allow USB re-enumeration before ISP.
    time.sleep(0.7)

    wchisp = _find_wchisp(script_dir)
    cmd = [str(wchisp), "--retry", "2", "flash", str(hex_path)]
    print("Running:", " ".join(cmd), flush=True)
    flash = subprocess.run(cmd, check=False)
    return flash.returncode


if __name__ == "__main__":
    raise SystemExit(main())
