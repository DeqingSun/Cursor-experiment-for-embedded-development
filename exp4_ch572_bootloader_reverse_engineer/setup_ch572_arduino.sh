#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd -P
)"

CH32_PACKAGE_JSON_URL="https://github.com/DeqingSun/arduino_core_ch32/releases/download/initBinStorage/package_ch32v_index_release.json"

cli_root="${script_dir}/arduino_cli"
cli_bin="${cli_root}/bin/arduino-cli"

if [[ ! -x "$cli_bin" ]]; then
  echo "ERROR: Arduino CLI not found at: $cli_bin" >&2
  echo "Run: ${script_dir}/install_arduino_cli.sh" >&2
  exit 1
fi

data_dir="${cli_root}/data"
user_dir="${cli_root}/user"
downloads_dir="${cli_root}/downloads"
mkdir -p "$data_dir" "$user_dir" "$downloads_dir"

config_file="${cli_root}/arduino-cli.yaml"
cat >"$config_file" <<EOF
board_manager:
  additional_urls:
    - ${CH32_PACKAGE_JSON_URL}
directories:
  data: ${data_dir}
  user: ${user_dir}
  downloads: ${downloads_dir}
EOF

export ARDUINO_CLI_CONFIG_FILE="$config_file"
cli() {
  "$cli_bin" --config-file "$config_file" "$@"
}

echo "Using config: $ARDUINO_CLI_CONFIG_FILE"
echo "Updating package index (Arduino + CH32V)..."
cli core update-index || true

echo "Installing WCH CH32V core (CH572_EVT / WCH-ISP)..."
cli core install WCH:ch32v

echo
echo "Installed cores:"
cli core list

echo
echo "CH572 board FQBN options (for compile scripts):"
cli board details -b WCH:ch32v:CH572_EVT 2>/dev/null | head -n 40 || true

echo
echo "Sanity check: compile minimal_ch572 sketch..."
sketch_dir="${script_dir}/minimal_ch572"
build_dir="${cli_root}/.tmp/build_minimal_ch572"
rm -rf "$build_dir"
mkdir -p "$build_dir"

if [[ ! -f "${sketch_dir}/minimal_ch572.ino" ]]; then
  echo "ERROR: Sketch not found at: ${sketch_dir}/minimal_ch572.ino" >&2
  exit 1
fi

FQBN_DEFAULT="WCH:ch32v:CH572_EVT:pnum=CH572,upload_method=ispMethod,opt=osstd"
cli compile --fqbn "$FQBN_DEFAULT" --build-path "$build_dir" "$sketch_dir"

echo
echo "Setup complete. Build output: $build_dir"
