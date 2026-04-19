#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd -P
)"

cli_root="${script_dir}/arduino_cli"
cli_bin="${cli_root}/bin/arduino-cli"
config_file="${cli_root}/arduino-cli.yaml"
sketch_dir="${script_dir}/minimal_ch572"

if [[ ! -x "$cli_bin" ]]; then
  echo "ERROR: Arduino CLI not found at: $cli_bin" >&2
  echo "Run: ${script_dir}/install_arduino_cli.sh" >&2
  exit 1
fi

if [[ ! -f "$config_file" ]]; then
  echo "ERROR: Arduino CLI config not found at: $config_file" >&2
  echo "Run: ${script_dir}/setup_ch572_arduino.sh" >&2
  exit 1
fi

if [[ ! -f "${sketch_dir}/minimal_ch572.ino" ]]; then
  echo "ERROR: Sketch not found at: ${sketch_dir}/minimal_ch572.ino" >&2
  exit 1
fi

cli() {
  "$cli_bin" --config-file "$config_file" "$@"
}

# Board CH572_EVT, upload method WCH-ISP (ispMethod), part CH572, default optimization.
fqbn="WCH:ch32v:CH572_EVT:pnum=CH572,upload_method=ispMethod,opt=osstd"
build_dir="${cli_root}/.tmp/build_minimal_ch572"
rm -rf "$build_dir"
mkdir -p "$build_dir"

echo "Compiling (${fqbn})..."
cli compile --fqbn "$fqbn" --build-path "$build_dir" "$sketch_dir"

hex_path="${build_dir}/minimal_ch572.ino.hex"
if [[ -f "$hex_path" ]]; then
  echo "HEX: $hex_path"
else
  echo "WARNING: Expected HEX not found at $hex_path (check build directory listing)." >&2
  ls -la "$build_dir" >&2 || true
fi

echo "Done."
