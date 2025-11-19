#!/bin/bash

# kinetis-isp cross-compilation setup script
# Build dependencies for kinetis-isp tool

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

# Package version
readonly CONFUSE_VERSION="3.3"
readonly LIBFTDI_VERSION="1.4"

# URLs
readonly CONFUSE_URL="https://github.com/libconfuse/libconfuse/releases/download/v${CONFUSE_VERSION}/confuse-${CONFUSE_VERSION}.tar.gz"
readonly LIBFTDI_URL="https://www.intra2net.com/en/developer/libftdi/download/libftdi1-${LIBFTDI_VERSION}.tar.bz2"

# Yocto SDK configuration
readonly SDK_PATH="/usr/local/fullstack-perf-x86_64"
readonly ENVIRONMENT_SETUP="${SDK_PATH}/environment-setup-aarch64-oe-linux"

# =============================================================================
# Utility Functions
# =============================================================================

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

die() {
    log_error "$*"
    exit 1
}

create_cmake_toolchain() {
    local toolchain_file="$1"
    log_info "Creating CMake toolchain file: $toolchain_file"

    cat > "$toolchain_file" << 'EOF'
# CMake toolchain file for aarch64-oe-linux cross-compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSROOT $ENV{SDKTARGETSYSROOT})
set(CMAKE_FIND_ROOT_PATH $ENV{SDKTARGETSYSROOT})
# Extract just the compiler executable (first word from CC/CXX)
set(CMAKE_C_COMPILER aarch64-oe-linux-gcc)
set(CMAKE_CXX_COMPILER aarch64-oe-linux-g++)
# Add the flags separately
set(CMAKE_C_FLAGS_INIT "-fstack-protector-strong -pie -fPIE -D_FORTIFY_SOURCE=2 -Wa,--noexecstack -Wformat -Wformat-security -Werror=format-security")
set(CMAKE_CXX_FLAGS_INIT "-fstack-protector-strong -pie -fPIE -D_FORTIFY_SOURCE=2 -Wa,--noexecstack -Wformat -Wformat-security -Werror=format-security")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
}

build_libconfuse() {
    log_info "Building libconfuse ${CONFUSE_VERSION}..."

    pushd ~ >/dev/null

    local archive="confuse-${CONFUSE_VERSION}.tar.gz"
    if [[ ! -f "$archive" ]]; then
        log_info "Downloading libconfuse from $CONFUSE_URL"
        wget "$CONFUSE_URL" || die "Failed to download libconfuse"
    fi

    log_info "Extracting libconfuse..."
    tar -xzf "$archive"
    cd "confuse-${CONFUSE_VERSION}"

    log_info "Setting up Yocto environment..."
    set +u
    source "$ENVIRONMENT_SETUP" || die "Failed to source Yocto environment"
    set -u

    # Configure and build
    log_info "Configuring libconfuse..."
    ./configure \
      --host=aarch64-oe-linux \
      --prefix=/usr \
      --disable-examples \
      || die "Failed to configure libconfuse"
    
    log_info "Building libconfuse..."
    make || die "Failed to build libconfuse"

    log_info "Installing libconfuse..."
    make DESTDIR=$SDKTARGETSYSROOT install || die "Failed to install libconfuse"

    popd >/dev/null

    log_info "libconfuse ${CONFUSE_VERSION} built and installed successfully."
}

build_libftdi() {
    log_info "Building libftdi ${LIBFTDI_VERSION}..."
    
    pushd ~ >/dev/null

    local archive="libftdi1-${LIBFTDI_VERSION}.tar.bz2"
    if [[ ! -f "$archive" ]]; then
        log_info "Downloading libftdi from $LIBFTDI_URL"
        wget "$LIBFTDI_URL" || die "Failed to download libftdi"
    fi

    log_info "Extracting libftdi..."
    tar -xjf "$archive"
    cd "libftdi1-${LIBFTDI_VERSION}"

    local toolchain_file="toolchain-aarch64.cmake"
    create_cmake_toolchain "$toolchain_file"

    mkdir -p build
    cd build

    log_info "Setting up Yocto environment..."
    set +u
    source "$ENVIRONMENT_SETUP" || die "Failed to source Yocto environment"
    set -u

    log_info "Configuring libftdi..."
    cmake \
      -DCMAKE_TOOLCHAIN_FILE="../$toolchain_file" \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DBUILD_TESTS=OFF \
      -DEXAMPLES=OFF \
      .. \
      || die "Failed to configure libftdi"

    log_info "Building libftdi..."
    make || die "Failed to build libftdi"

    log_info "Installing libftdi..."
    make DESTDIR=$SDKTARGETSYSROOT install || die "Failed to install libftdi"

    popd >/dev/null

    log_info "libftdi ${LIBFTDI_VERSION} built and installed successfully."
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    if [[ -f "$ENVIRONMENT_SETUP" ]]; then
        log_info "Found Yocto SDK environment setup script."
    else
        die "Yocto SDK environment setup script not found at $ENVIRONMENT_SETUP"
    fi

    local tools=(wget tar cmake make)
    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null 2>&1 || die "Required tool '$tool' is not installed."
    done

    log_info "All prerequisites are met."
}

show_usage() {
    cat << EOF
Usage: $0 [options] [command]

Commands:
  all            Build and install all dependencies
  libconfuse     Build and install libconfuse
  libftdi        Build and install libftdi
  help           Show this help message

Options:
  -h, --help     Show this help message

Examples:
  $0 all
  $0 libconfuse
  $0 libftdi
EOF
}

# =============================================================================
# Main Script
# =============================================================================
main() {
  local command="${1:-all}"

  case "$command" in
    all)
      log_info "=== Starting full build process ==="
      check_prerequisites
      build_libconfuse
      build_libftdi
      log_info "=== Full build process completed ==="
      ;;
    libconfuse)
      check_prerequisites
      build_libconfuse
      ;;
    libftdi)
      check_prerequisites
      build_libftdi
      ;;
    help|-h|--help)
      show_usage
      exit 0
      ;;
    *)
      log_error "Unknown command: $command"
      show_usage
      exit 1
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi