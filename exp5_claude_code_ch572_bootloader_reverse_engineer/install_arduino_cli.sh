#!/usr/bin/env bash
set -euo pipefail

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

mkdir -p "$bin_dir"

if [[ -x "$cli_path" ]]; then
  echo "Arduino CLI already installed:"
  echo "  $cli_path"
  echo "Version:"
  "$cli_path" version
  exit 0
fi

tmp_dir="${install_dir}/.tmp"
mkdir -p "$tmp_dir"
tgz_path="${tmp_dir}/arduino-cli_latest_macOS_ARM64.tar.gz"

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

echo "Installing Arduino CLI into: $install_dir"
echo "Downloading: $url"
download
echo "Extracting into: $bin_dir"
extract

echo
echo "Installed: $cli_path"
echo "Version:"
"$cli_path" version

echo
echo "Usage:"
echo "  \"${cli_path}\" <command>"
echo "  export PATH=\"${bin_dir}:\$PATH\""
