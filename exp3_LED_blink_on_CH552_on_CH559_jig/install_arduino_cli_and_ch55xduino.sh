#!/usr/bin/env bash
set -euo pipefail

# Installs Arduino CLI under ./arduino_cli (same layout as exp1_LED_blink_on_Arduino_uno)
# and registers the CH55xDuino third-party board index, then installs core CH55xDuino:mcs51.
#
# Reference: exp1_LED_blink_on_Arduino_uno/install_arduino_cli.sh and setup_arduino_uno.sh

script_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd -P
)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: This installer currently supports macOS only." >&2
  exit 1
fi

arch="$(uname -m)"
if [[ "$arch" != "arm64" ]]; then
  echo "ERROR: This script is for macOS ARM64 (Apple Silicon). Detected: $arch" >&2
  exit 1
fi

install_dir="${script_dir}/arduino_cli"
bin_dir="${install_dir}/bin"
cli_path="${bin_dir}/arduino-cli"
url="https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_macOS_ARM64.tar.gz"

ch55xduino_index_url="https://raw.githubusercontent.com/DeqingSun/ch55xduino/ch55xduino/package_ch55xduino_mcs51_index.json"

mkdir -p "$bin_dir"

download() {
  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --retry-delay 2 -o "$tgz_path" "$url"
    return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -O "$tgz_path" "$url"
    return 0
  fi
  echo "ERROR: Need curl or wget to download Arduino CLI." >&2
  return 1
}

extract() {
  rm -f "$cli_path"
  tar -xzf "$tgz_path" -C "$bin_dir"

  if [[ -f "$cli_path" ]]; then
    chmod +x "$cli_path" || true
    return 0
  fi

  found="$(
    find "$bin_dir" -maxdepth 2 -type f -name "arduino-cli*" 2>/dev/null | head -n 1 || true
  )"
  if [[ -n "$found" && -f "$found" ]]; then
    mv -f "$found" "$cli_path"
    chmod +x "$cli_path" || true
    return 0
  fi

  echo "ERROR: Extraction succeeded but arduino-cli binary not found in ${bin_dir}." >&2
  return 1
}

if [[ ! -x "$cli_path" ]]; then
  tmp_dir="${install_dir}/.tmp"
  mkdir -p "$tmp_dir"
  tgz_path="${tmp_dir}/arduino-cli_latest_macOS_ARM64.tar.gz"

  echo "Installing Arduino CLI into: $install_dir"
  echo "Downloading: $url"
  download
  echo "Extracting into: $bin_dir"
  extract

  echo
  echo "Installed: $cli_path"
  echo "Version:"
  "$cli_path" version
else
  echo "Arduino CLI already present:"
  echo "  $cli_path"
  "$cli_path" version
fi

data_dir="${install_dir}/data"
user_dir="${install_dir}/user"
downloads_dir="${install_dir}/downloads"
mkdir -p "$data_dir" "$user_dir" "$downloads_dir"

config_file="${install_dir}/arduino-cli.yaml"
if [[ ! -f "$config_file" ]]; then
  cat >"$config_file" <<EOF
board_manager:
  additional_urls:
    - ${ch55xduino_index_url}
directories:
  data: ${data_dir}
  user: ${user_dir}
  downloads: ${downloads_dir}
EOF
else
  if ! grep -qF "package_ch55xduino_mcs51_index.json" "$config_file" 2>/dev/null; then
    echo "Adding CH55xDuino board index URL to existing config..."
    "$cli_path" --config-file "$config_file" config add board_manager.additional_urls "$ch55xduino_index_url"
  fi
fi

export ARDUINO_CLI_CONFIG_FILE="$config_file"
cli() {
  "$cli_path" --config-file "$config_file" "$@"
}

echo
echo "Using config: $config_file"
echo "Updating board / platform index..."
cli core update-index || true

echo
echo "Installing CH55xDuino MCS51 core (CH55xDuino:mcs51)..."
cli core install CH55xDuino:mcs51

echo
echo "Installed cores:"
cli core list

echo
echo "Sanity check: compile Blink for CH55xDuino:mcs51:ch552..."
tmp_sketch_dir="${install_dir}/.tmp/ch552_blink_sketch"
rm -rf "$tmp_sketch_dir"
mkdir -p "$tmp_sketch_dir"

build_dir="${install_dir}/.tmp/build_ch552_blink"
rm -rf "$build_dir"
mkdir -p "$build_dir"

cat >"${tmp_sketch_dir}/ch552_blink_sketch.ino" <<'EOF'
#define LED_BUILTIN 33

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

cli compile --fqbn CH55xDuino:mcs51:ch552 --build-path "$build_dir" "$tmp_sketch_dir"

echo
echo "Done."
echo "Arduino CLI: ${cli_path}"
echo "Config:      ${config_file}"
echo "Add to PATH: export PATH=\"${bin_dir}:\$PATH\""
