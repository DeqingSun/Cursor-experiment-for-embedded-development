#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd -P
)"

cli_root="${script_dir}/arduino_cli"
cli_bin="${cli_root}/bin/arduino-cli"
config_file="${cli_root}/arduino-cli.yaml"

if [[ ! -x "$cli_bin" ]]; then
  echo "ERROR: Arduino CLI not found at: $cli_bin" >&2
  echo "Run: ${script_dir}/install_arduino_cli.sh" >&2
  exit 1
fi

if [[ ! -f "$config_file" ]]; then
  echo "ERROR: Arduino CLI config not found at: $config_file" >&2
  echo "Run: ${script_dir}/setup_arduino_uno.sh" >&2
  exit 1
fi

cli() {
  "$cli_bin" --config-file "$config_file" "$@"
}

fqbn="arduino:avr:uno"
sketch_dir="${script_dir}/blink_pin13"
compile_only="false"
port="${PORT:-}"

if [[ ! -f "${sketch_dir}/blink_pin13.ino" ]]; then
  echo "ERROR: Sketch not found at: ${sketch_dir}/blink_pin13.ino" >&2
  exit 1
fi

usage() {
  cat <<EOF
Usage:
  $0 [--compile-only] [--port <PORT>]

Options:
  --compile-only       Only compile (no upload).
  --port <PORT>        Serial port (e.g. /dev/cu.usbmodem1101).

Environment:
  PORT=<PORT>          Alternative way to specify port.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --compile-only)
      compile_only="true"
      shift
      ;;
    --port)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --port requires a value." >&2
        usage >&2
        exit 2
      fi
      port="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${port}" ]]; then
  # Best-effort autodetect from `arduino-cli board list` table output.
  # Prefer typical macOS Uno ports: /dev/cu.usbmodem* or /dev/cu.usbserial*
  port="$(
    cli board list 2>/dev/null \
      | awk '{print $1}' \
      | grep -E '^/dev/(cu|tty)\.(usbmodem|usbserial)' \
      | head -n 1 \
      || true
  )"
fi

if [[ "${compile_only}" == "false" && -z "${port}" ]]; then
  echo "ERROR: Serial port not provided and could not be auto-detected." >&2
  echo "Run this to see ports:" >&2
  echo "  \"$cli_bin\" --config-file \"$config_file\" board list" >&2
  echo "Then re-run with a port, e.g.:" >&2
  echo "  \"$0\" --port /dev/cu.usbmodem1101" >&2
  exit 1
fi

build_dir="${cli_root}/.tmp/build_blink_pin13"
rm -rf "$build_dir"
mkdir -p "$build_dir"

echo "Compiling (${fqbn})..."
cli compile --fqbn "$fqbn" --build-path "$build_dir" "$sketch_dir"

if [[ "${compile_only}" == "true" ]]; then
  echo "Compile-only done."
  exit 0
fi

echo "Uploading to: ${port}"
cli upload -p "$port" --fqbn "$fqbn" --input-dir "$build_dir" "$sketch_dir"

echo "Done."

