#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd -P
)"

cli_root="${script_dir}/arduino_cli"
cli_bin="${cli_root}/bin/arduino-cli"

if [[ ! -x "$cli_bin" ]]; then
  echo "ERROR: Arduino CLI not found at: $cli_bin" >&2
  echo "Run: ${script_dir}/install_arduino_cli.sh" >&2
  exit 1
fi

# Keep all Arduino CLI state inside this repo folder.
data_dir="${cli_root}/data"
user_dir="${cli_root}/user"
downloads_dir="${cli_root}/downloads"
mkdir -p "$data_dir" "$user_dir" "$downloads_dir"

config_file="${cli_root}/arduino-cli.yaml"
if [[ ! -f "$config_file" ]]; then
  cat >"$config_file" <<EOF
board_manager:
  additional_urls: []
directories:
  data: ${data_dir}
  user: ${user_dir}
  downloads: ${downloads_dir}
EOF
fi

export ARDUINO_CLI_CONFIG_FILE="$config_file"
cli() {
  "$cli_bin" --config-file "$config_file" "$@"
}

echo "Using config: $ARDUINO_CLI_CONFIG_FILE"
echo "Updating index..."
# Arduino CLI may exit non-zero if any index can't be updated; proceed as long as
# the default Arduino index succeeds (required for arduino:avr).
cli core update-index || true

echo "Installing Arduino AVR core (for Uno)..."
cli core install arduino:avr

echo
echo "Installed cores:"
cli core list

echo
echo "Sanity check compile (Blink example) for arduino:avr:uno..."
tmp_sketch_dir="${cli_root}/.tmp/blink_sketch"
rm -rf "$tmp_sketch_dir"
mkdir -p "$tmp_sketch_dir"

build_dir="${cli_root}/.tmp/build"
build_cache_dir="${cli_root}/.tmp/build_cache"
rm -rf "$build_dir"
mkdir -p "$build_dir" "$build_cache_dir"

cat >"${tmp_sketch_dir}/blink_sketch.ino" <<'EOF'
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  digitalWrite(LED_BUILTIN, HIGH);
  delay(1000);
  digitalWrite(LED_BUILTIN, LOW);
  delay(1000);
}
EOF

cli compile --fqbn arduino:avr:uno --build-path "$build_dir" --build-cache-path "$build_cache_dir" "$tmp_sketch_dir"

echo
echo "Ready to upload."
echo "Next steps:"
echo "  1) Plug in the Uno via USB"
echo "  2) Find the port:"
echo "       \"$cli_bin\" board list"
echo "  3) Upload (replace <PORT>):"
echo "       \"$cli_bin\" upload -p <PORT> --fqbn arduino:avr:uno \"$tmp_sketch_dir\""
