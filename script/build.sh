#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${1:-${PROJECT_DIR}/build}"
TOOLCHAIN_FILE="${PROJECT_DIR}/cmake/toolchain-aarch64-oe-linux.cmake"

if [[ "$BUILD_DIR" != /* ]]; then
    BUILD_DIR="$(pwd)/$BUILD_DIR"
fi

echo "[INFO] Using build directory: $BUILD_DIR"

if [ ! -f "$TOOLCHAIN_FILE" ]; then
  echo "Error: Toolchain file not found at $TOOLCHAIN_FILE"
  exit 1
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

set +u
source /usr/local/fullstack-perf-x86_64/environment-setup-aarch64-oe-linux
set -u

cmake \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
  -DBUILD_TESTING=OFF \
  "$PROJECT_DIR"
make 

export STRIP=/usr/local/fullstack-perf-x86_64/sysroots/x86_64-qtisdk-linux/usr/libexec/aarch64-oe-linux/gcc/aarch64-oe-linux/9.3.0/strip
$STRIP nxp-isp-0.1.1