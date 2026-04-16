#!/usr/bin/env python3
"""
Build CH552 P3.3 Timer2 blink firmware, enter USB bootloader via CH559 jig, upload
with vnproch55x, then verify 1 s high / 1 s low on CH559 GPIO 25 within ±2 %.

Hardware (per jig README):
  - Matrix: CH552 P3.3 (PIN_CH552_P33_X) -> CH559 P25 (PIN_CH559_P25) for sampling.
  - Also close PIN_EXT_LED_10_X -> PIN_CH559_P25 so LED 10 mirrors the line for
    visual confirmation.

Requires: pyserial, CH559 jig USB, CH552 USB (bootloader), Arduino CLI + CH55xDuino
(installed by install_arduino_cli_and_ch55xduino.sh), vnproch55x from CH55xDuino
MCS51Tools package.
"""

from __future__ import annotations

import argparse
import glob
import os
import statistics
import subprocess
import sys
import time

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
JIG_LIB = os.path.join(SCRIPT_DIR, "library_and_example")
sys.path.insert(0, JIG_LIB)

from ch559_jig_code import CH559_jig  # noqa: E402

SKETCH_DIR = os.path.join(SCRIPT_DIR, "ch552_p33_timer2_blink")
SKETCH_NAME = "ch552_p33_timer2_blink"
FQBN = (
    "CH55xDuino:mcs51:ch552:clock=24internal,"
    "upload_method=usb,bootloader_pin=p15,usb_settings=user0"
)
TARGET_S = 1.0
TOLERANCE = 0.02
CH559_SAMPLE_PIN = 25  # firmware GPIO index for P25 (matrix Y to CH552 P3.3)


def _arduino_cli() -> str:
    p = os.path.join(SCRIPT_DIR, "arduino_cli", "bin", "arduino-cli")
    if os.path.isfile(p):
        return p
    return "arduino-cli"


def _arduino_config() -> str:
    return os.path.join(SCRIPT_DIR, "arduino_cli", "arduino-cli.yaml")


def find_vnproch55x() -> str | None:
    home = os.path.expanduser("~")
    roots = [
        os.path.join(home, "Library", "Arduino15", "packages", "CH55xDuino", "tools", "MCS51Tools"),
        os.path.join(home, ".arduino15", "packages", "CH55xDuino", "tools", "MCS51Tools"),
    ]
    if sys.platform == "darwin":
        sub = "macosx"
    elif sys.platform.startswith("linux"):
        sub = "linux"
    else:
        sub = "win"
    for root in roots:
        if not os.path.isdir(root):
            continue
        pattern = os.path.join(root, "*", sub, "vnproch55x")
        matches = glob.glob(pattern)
        if matches:
            matches.sort(key=os.path.getmtime, reverse=True)
            return matches[0]
    return None


def compile_sketch(build_dir: str) -> str:
    cli = _arduino_cli()
    cfg = _arduino_config()
    if not os.path.isfile(cli):
        raise FileNotFoundError(f"arduino-cli not found at {cli}")
    cmd = [
        cli,
        "--config-file",
        cfg,
        "compile",
        "--fqbn",
        FQBN,
        "--build-path",
        build_dir,
        SKETCH_DIR,
    ]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(
            "compile failed:\n" + (r.stderr or r.stdout or "")
        )
    hex_path = os.path.join(build_dir, SKETCH_NAME + ".ino.hex")
    if not os.path.isfile(hex_path):
        raise FileNotFoundError(f"expected hex at {hex_path}")
    return hex_path


def upload_hex(hex_path: str, tool: str) -> None:
    cmd = [tool, "-r", "2", hex_path]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        msg = r.stderr or r.stdout or ""
        raise RuntimeError(f"upload failed ({cmd}): {msg}")


def _median_ok(samples: list[float], label: str) -> None:
    if len(samples) < 8:
        raise RuntimeError(f"not enough {label} samples: {len(samples)}")
    med = statistics.median(samples)
    lo = TARGET_S * (1.0 - TOLERANCE)
    hi = TARGET_S * (1.0 + TOLERANCE)
    if not (lo <= med <= hi):
        raise RuntimeError(
            f"{label} median {med:.4f}s out of [{lo:.4f}, {hi:.4f}] "
            f"(n={len(samples)}, all={samples!r})"
        )
    print(f"  {label}: median={med:.4f}s (n={len(samples)}) OK")


def measure_blink_timing(jig: CH559_jig, timeout_per_edge: float) -> None:
    jig.initailize(1)
    jig.connect_pins(jig.PIN_CH552_P33_X, jig.PIN_CH559_P25, 1)
    jig.connect_pins(jig.PIN_EXT_LED_10_X, jig.PIN_CH559_P25, 1)
    if not jig.reboot_target():
        print("warning: reboot_target did not confirm (continuing)")

    time.sleep(0.3)
    last = jig.digital_pin_subscribe(CH559_SAMPLE_PIN, 1)
    if last is None:
        raise RuntimeError("digital_pin_subscribe failed")

    t_last = time.monotonic()
    high_dts: list[float] = []
    low_dts: list[float] = []
    # discard first interval (may be partial)
    first_edge = True

    while len(high_dts) < 12 or len(low_dts) < 12:
        v = jig.check_digital_pin_subscription(CH559_SAMPLE_PIN, timeout_per_edge)
        if v is None:
            raise RuntimeError(
                "timeout waiting for pin edge; check matrix wiring "
                "(P3.3->P25 and EXT_LED_10->P25)"
            )
        if v == last:
            continue
        now = time.monotonic()
        dt = now - t_last
        t_last = now
        if not first_edge:
            if last:
                high_dts.append(dt)
            else:
                low_dts.append(dt)
        first_edge = False
        last = v

    _median_ok(high_dts, "high")
    _median_ok(low_dts, "low")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--compile-only",
        action="store_true",
        help="only compile; do not use USB / jig",
    )
    ap.add_argument(
        "--build-dir",
        default=os.path.join(SKETCH_DIR, "build_ci"),
        help="arduino-cli --build-path",
    )
    ap.add_argument(
        "--vnproch55x",
        default="",
        help="path to vnproch55x (default: search CH55xDuino MCS51Tools)",
    )
    args = ap.parse_args()

    os.makedirs(args.build_dir, exist_ok=True)
    print("Compiling…")
    hex_path = compile_sketch(args.build_dir)
    print(f"  hex: {hex_path}")
    if args.compile_only:
        return 0

    tool = args.vnproch55x or find_vnproch55x()
    if not tool or not os.path.isfile(tool):
        raise FileNotFoundError(
            "vnproch55x not found; install CH55xDuino core or pass --vnproch55x PATH"
        )
    print(f"Using uploader: {tool}")

    jig = CH559_jig()
    if not jig.connect():
        print("CH559 jig not found (USB serial iSerial CH559 jig / CH559_JIG).")
        return 2
    try:
        if not jig.enter_bootloader_mode():
            print("enter_bootloader_mode failed")
            return 3
        jig.disconnect()
        time.sleep(0.4)

        print("Uploading…")
        upload_hex(hex_path, tool)
        time.sleep(0.5)

        if not jig.connect():
            print("could not reopen CH559 jig after upload")
            return 4

        print("Measuring P3.3 timing on CH559 pin 25 (±2 %)…")
        measure_blink_timing(jig, timeout_per_edge=3.0)
        print("PASS: timing within ±2 %.")
        return 0
    finally:
        jig.disconnect()


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as e:
        print(f"FAIL: {e}", file=sys.stderr)
        raise SystemExit(1)
