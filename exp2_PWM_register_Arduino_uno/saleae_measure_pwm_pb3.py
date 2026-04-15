#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import os
import re
import statistics
import sys
import tempfile
from dataclasses import dataclass
from typing import Iterable, Optional

try:
    from saleae import automation
except Exception as e:  # pragma: no cover
    automation = None  # type: ignore
    _IMPORT_ERROR = e


def _print_connect_help(address: str, port: int) -> None:
    print(
        "ERROR: couldn't connect to Logic 2 automation server.\n"
        "\n"
        "Fix:\n"
        "  - Open Logic 2\n"
        "  - Preferences → scroll down → enable “Automation”\n"
        f"  - Ensure it is listening on {address}:{port} (default port is 10430)\n"
        "\n"
        "Alternative:\n"
        "  - Re-run this script with --launch to auto-start Logic 2.\n",
        file=sys.stderr,
    )


@dataclass(frozen=True)
class PwmStats:
    periods_s: list[float]
    highs_s: list[float]
    lows_s: list[float]

    def _summary(self, xs: list[float]) -> str:
        if not xs:
            return "n=0"
        return (
            f"n={len(xs)} mean={statistics.mean(xs):.9f}s "
            f"stdev={statistics.pstdev(xs):.9f}s "
            f"min={min(xs):.9f}s max={max(xs):.9f}s"
        )

    def format_report(self) -> str:
        return "\n".join(
            [
                f"period: {self._summary(self.periods_s)}",
                f"high  : {self._summary(self.highs_s)}",
                f"low   : {self._summary(self.lows_s)}",
            ]
        )


def _parse_bool_cell(cell: str) -> int:
    s = cell.strip().lower()
    if s in {"1", "true", "t", "high", "h"}:
        return 1
    if s in {"0", "false", "f", "low", "l"}:
        return 0
    raise ValueError(f"Unrecognized digital cell value: {cell!r}")


def _find_time_and_channel_columns(fieldnames: list[str], channel: int) -> tuple[str, str]:
    time_candidates = [n for n in fieldnames if re.search(r"\btime\b", n, flags=re.I)]
    if not time_candidates:
        raise ValueError(f"Could not find a time column in: {fieldnames}")
    time_col = time_candidates[0]

    chan_re = re.compile(rf"(?:^|\b)channel\s*{channel}(?:\b|$)", flags=re.I)
    chan_candidates = [n for n in fieldnames if chan_re.search(n)]
    if not chan_candidates:
        raise ValueError(f"Could not find channel {channel} column in: {fieldnames}")
    chan_col = chan_candidates[0]
    return time_col, chan_col


def iter_samples_from_digital_csv(digital_csv_path: str, channel: int) -> Iterable[tuple[float, int]]:
    with open(digital_csv_path, "r", newline="") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError("digital.csv missing header row")
        time_col, chan_col = _find_time_and_channel_columns(reader.fieldnames, channel=channel)
        for row in reader:
            yield (float(row[time_col]), _parse_bool_cell(row[chan_col]))


def compute_pwm_stats(samples: Iterable[tuple[float, int]]) -> PwmStats:
    last_v: Optional[int] = None
    rising_edges: list[float] = []
    falling_edges: list[float] = []

    for t, v in samples:
        if last_v is None:
            last_v = v
            continue
        if v != last_v:
            if last_v == 0 and v == 1:
                rising_edges.append(t)
            elif last_v == 1 and v == 0:
                falling_edges.append(t)
            last_v = v

    highs: list[float] = []
    lows: list[float] = []

    fi = 0
    for r in rising_edges:
        while fi < len(falling_edges) and falling_edges[fi] <= r:
            fi += 1
        if fi >= len(falling_edges):
            break
        highs.append(falling_edges[fi] - r)
        fi += 1

    ri = 0
    for f in falling_edges:
        while ri < len(rising_edges) and rising_edges[ri] <= f:
            ri += 1
        if ri >= len(rising_edges):
            break
        lows.append(rising_edges[ri] - f)
        ri += 1

    periods: list[float] = []
    fi = 0
    for a, b in zip(rising_edges, rising_edges[1:]):
        while fi < len(falling_edges) and falling_edges[fi] <= a:
            fi += 1
        if fi < len(falling_edges) and falling_edges[fi] < b:
            dt = b - a
            if dt > 0:
                periods.append(dt)

    return PwmStats(periods_s=periods, highs_s=highs, lows_s=lows)


def _pick_device_id(manager: "automation.Manager", requested_id: Optional[str]) -> Optional[str]:
    if requested_id:
        return requested_id
    devices = manager.get_devices(include_simulation_devices=False)
    if not devices:
        return None
    return devices[0].device_id


def main(argv: list[str]) -> int:
    p = argparse.ArgumentParser(
        description="Capture Saleae digital channel and measure PWM timing on Arduino Uno PB3 (D11)."
    )
    p.add_argument("--launch", action="store_true", help="Launch Logic 2 automatically.")
    p.add_argument("--logic2-path", default=None, help="Optional Logic 2 path when using --launch.")
    p.add_argument("--address", default="127.0.0.1", help="Logic 2 automation server address")
    p.add_argument("--port", type=int, default=10430, help="Logic 2 automation server port")
    p.add_argument("--device-id", default=None, help="Saleae device id (serial). Omit to use first.")
    p.add_argument("--channel", type=int, default=0, help="Digital channel index (default: 0)")
    p.add_argument("--duration", type=float, default=2.0, help="Capture duration seconds")
    p.add_argument("--sample-rate", type=int, default=2_000_000, help="Digital sample rate Sa/s")
    p.add_argument("--threshold-volts", type=float, default=None, help="Digital threshold volts.")
    p.add_argument("--expected-high", type=float, default=0.0004096, help="Expected high time (s)")
    p.add_argument("--expected-low", type=float, default=0.0001024, help="Expected low time (s)")
    p.add_argument("--tolerance", type=float, default=0.10, help="Fractional tolerance (0.10 = 10%%)")
    args = p.parse_args(argv)

    if automation is None:  # pragma: no cover
        print(
            "ERROR: failed to import logic2-automation (saleae.automation).\n"
            "Try: python -m pip install logic2-automation\n"
            f"Import error: {_IMPORT_ERROR}",
            file=sys.stderr,
        )
        return 2

    try:
        if args.launch:
            with automation.Manager.launch(application_path=args.logic2_path, port=args.port) as manager:
                return _run_capture_and_report(manager, args)
        else:
            with automation.Manager.connect(address=args.address, port=args.port) as manager:
                return _run_capture_and_report(manager, args)
    except Exception as e:
        _print_connect_help(args.address, args.port)
        print(f"Details: {e}", file=sys.stderr)
        return 4


def _run_capture_and_report(manager: "automation.Manager", args: argparse.Namespace) -> int:
    app_info = manager.get_app_info()
    print(f"Connected to Logic2 app_version={app_info.app_version} api={app_info.api_version}")

    device_id = _pick_device_id(manager, args.device_id)
    if device_id is None:
        print("ERROR: no Saleae devices found. Connect a device or pass --device-id.", file=sys.stderr)
        return 3

    device_configuration = automation.LogicDeviceConfiguration(
        enabled_digital_channels=[args.channel],
        digital_sample_rate=args.sample_rate,
        digital_threshold_volts=args.threshold_volts,
    )
    capture_configuration = automation.CaptureConfiguration(
        capture_mode=automation.TimedCaptureMode(duration_seconds=args.duration)
    )

    with manager.start_capture(
        device_id=device_id,
        device_configuration=device_configuration,
        capture_configuration=capture_configuration,
    ) as capture:
        capture.wait()

        with tempfile.TemporaryDirectory(prefix="saleae_pwm_") as outdir:
            capture.export_raw_data_csv(directory=outdir, digital_channels=[args.channel])
            digital_csv = os.path.join(outdir, "digital.csv")
            if not os.path.exists(digital_csv):
                raise RuntimeError(f"Expected export file not found: {digital_csv}")
            stats = compute_pwm_stats(iter_samples_from_digital_csv(digital_csv, channel=args.channel))

    print(stats.format_report())

    def within(mean_value: float, expected: float, tol_frac: float) -> bool:
        return abs(mean_value - expected) <= (expected * tol_frac)

    failures: list[str] = []
    if stats.highs_s:
        if not within(statistics.mean(stats.highs_s), args.expected_high, args.tolerance):
            failures.append("high")
    else:
        failures.append("high(n=0)")

    if stats.lows_s:
        if not within(statistics.mean(stats.lows_s), args.expected_low, args.tolerance):
            failures.append("low")
    else:
        failures.append("low(n=0)")

    expected_period = args.expected_high + args.expected_low
    if stats.periods_s:
        if not within(statistics.mean(stats.periods_s), expected_period, args.tolerance):
            failures.append("period")
    else:
        failures.append("period(n=0)")

    if failures:
        print(f"FAIL: out of tolerance: {', '.join(failures)}", file=sys.stderr)
        return 1

    # Derived user-friendly numbers.
    f_hz = 1.0 / statistics.mean(stats.periods_s) if stats.periods_s else float("nan")
    duty = (
        statistics.mean(stats.highs_s) / statistics.mean(stats.periods_s)
        if stats.highs_s and stats.periods_s
        else float("nan")
    )
    print(f"Derived: f={f_hz:.3f} Hz duty={duty*100:.2f}%")
    print("PASS: PWM timing within tolerance")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

