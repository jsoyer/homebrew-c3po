#!/bin/bash
# Build a standalone Strawberry Music Player DMG with all dependencies bundled
# This creates a DMG that doesn't require any Homebrew formula dependencies
set -e

# Configuration
STRAWBERRY_VERSION="1.2.17"
LIBGPOD_VERSION="0.8.3"
ARCH="arm64"
BUILD_DIR="${BUILD_DIR:-$(pwd)/build-standalone}"
DEPS_DIR="$BUILD_DIR/deps"
SOURCE_DIR="$BUILD_DIR/strawberry-$STRAWBERRY_VERSION"

# Code signing (set these environment variables or modify here)
APPLE_DEVELOPER_ID="${APPLE_DEVELOPER_ID:-}"
NOTARIZATION_PROFILE="${NOTARIZATION_PROFILE:-notarization}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    command -v cmake >/dev/null 2>&1 || log_error "cmake is required"
    command -v ninja >/dev/null 2>&1 || log_error "ninja is required"
    command -v gh >/dev/null 2>&1 || log_error "GitHub CLI (gh) is required"
    command -v pkg-config >/dev/null 2>&1 || log_error "pkg-config is required"
    command -v autoconf >/dev/null 2>&1 || log_error "autoconf is required"
    command -v automake >/dev/null 2>&1 || log_error "automake is required"

    if [[ -n "$APPLE_DEVELOPER_ID" ]]; then
        log_info "Code signing enabled with: $APPLE_DEVELOPER_ID"
    else
        log_warn "No APPLE_DEVELOPER_ID set - DMG will not be signed"
    fi
}

# Download pre-built dependencies from strawberry-macos-dependencies
download_dependencies() {
    log_info "Downloading pre-built ARM64 dependencies..."

    mkdir -p "$DEPS_DIR"
    cd "$BUILD_DIR"

    # Get latest release URL
    DEPS_URL=$(gh api repos/strawberrymusicplayer/strawberry-macos-dependencies/releases/latest \
        --jq '.assets[] | select(.name == "strawberry-macos-arm64-release.tar.xz") | .browser_download_url')

    if [[ -z "$DEPS_URL" ]]; then
        log_error "Failed to get dependencies download URL"
    fi

    log_info "Downloading from: $DEPS_URL"
    curl -L -o deps.tar.xz "$DEPS_URL"

    log_info "Extracting dependencies..."
    tar -xf deps.tar.xz -C "$DEPS_DIR" --strip-components=1
    rm deps.tar.xz

    log_info "Dependencies extracted to $DEPS_DIR"
}

# Download Strawberry source code
download_strawberry() {
    log_info "Downloading Strawberry $STRAWBERRY_VERSION source..."

    cd "$BUILD_DIR"

    if [[ -d "$SOURCE_DIR" ]]; then
        log_info "Source directory already exists, skipping download"
        return
    fi

    curl -L -o strawberry.tar.xz \
        "https://files.strawberrymusicplayer.org/strawberry-$STRAWBERRY_VERSION.tar.xz"

    tar -xf strawberry.tar.xz
    rm strawberry.tar.xz

    log_info "Source extracted to $SOURCE_DIR"
}

# Build and install libgpod for iPod support
build_libgpod() {
    log_info "Building libgpod $LIBGPOD_VERSION for iPod support..."

    cd "$BUILD_DIR"

    # Download libgpod
    curl -L -o libgpod.tar.bz2 \
        "https://downloads.sourceforge.net/project/gtkpod/libgpod/libgpod-0.8/libgpod-$LIBGPOD_VERSION.tar.bz2"

    tar -xf libgpod.tar.bz2
    rm libgpod.tar.bz2

    cd "libgpod-$LIBGPOD_VERSION"

    # Create libplist.pc compatibility wrapper
    mkdir -p pkgconfig
    cat > pkgconfig/libplist.pc << EOF
prefix=$DEPS_DIR
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libplist
Description: A library to handle Apple Property Lists
Version: 2.7.0
Libs: -L\${libdir} -lplist-2.0
Cflags: -I\${includedir}
EOF

    export PKG_CONFIG_PATH="$(pwd)/pkgconfig:$DEPS_DIR/lib/pkgconfig"
    export CFLAGS="-I$DEPS_DIR/include"
    export LDFLAGS="-L$DEPS_DIR/lib"

    autoreconf -fiv
    ./configure \
        --prefix="$DEPS_DIR" \
        --disable-dependency-tracking \
        --disable-silent-rules \
        --disable-gtk-doc \
        --disable-pygobject \
        --disable-udev \
        --without-hal

    make -j$(sysctl -n hw.ncpu)
    make install

    log_info "libgpod installed to $DEPS_DIR"
}

# Configure and build Strawberry
build_strawberry() {
    log_info "Configuring Strawberry build..."

    cd "$SOURCE_DIR"

    # Set up environment
    export PKG_CONFIG_PATH="$DEPS_DIR/lib/pkgconfig"
    export PATH="$DEPS_DIR/bin:$PATH"

    # CMake arguments
    CMAKE_ARGS=(
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_PREFIX_PATH="$DEPS_DIR"
        -DBUILD_WITH_QT6=ON
        -DENABLE_BUNDLE=ON
        -DCREATE_DMG=ON
        -DENABLE_SPARKLE=OFF
        -DENABLE_QTSPARKLE=OFF
        -DENABLE_STREAMTAGREADER=OFF
        -DENABLE_TRANSLATIONS=ON
        -DENABLE_DBUS=OFF
        -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0
        -DCMAKE_OSX_ARCHITECTURES=arm64
        -G Ninja
    )

    if [[ -n "$APPLE_DEVELOPER_ID" ]]; then
        CMAKE_ARGS+=(-DAPPLE_DEVELOPER_ID="$APPLE_DEVELOPER_ID")
    fi

    log_info "Running CMake..."
    cmake -B build "${CMAKE_ARGS[@]}"

    log_info "Building Strawberry..."
    cmake --build build --parallel
}

# Deploy (bundle all dependencies)
deploy_bundle() {
    log_info "Deploying app bundle with all dependencies..."

    cd "$SOURCE_DIR"

    # Set GStreamer environment for macgstcopy.sh
    export GIO_EXTRA_MODULES="$DEPS_DIR/lib/gio/modules"
    export GST_PLUGIN_SCANNER="$DEPS_DIR/libexec/gstreamer-1.0/gst-plugin-scanner"
    export GST_PLUGIN_PATH="$DEPS_DIR/lib/gstreamer-1.0"

    cmake --build build --target deploy

    log_info "Verifying deployment..."
    cmake --build build --target deploycheck || log_warn "deploycheck had warnings"
}

# Create DMG
create_dmg() {
    log_info "Creating DMG..."

    cd "$SOURCE_DIR"
    cmake --build build --target dmg

    DMG_FILE=$(ls build/strawberry-*.dmg 2>/dev/null | head -1)

    if [[ -z "$DMG_FILE" ]]; then
        log_error "DMG file not found after build"
    fi

    log_info "DMG created: $DMG_FILE"
    echo "$DMG_FILE"
}

# Notarize DMG with Apple
notarize_dmg() {
    local dmg_file="$1"

    if [[ -z "$APPLE_DEVELOPER_ID" ]]; then
        log_warn "Skipping notarization - no APPLE_DEVELOPER_ID set"
        return
    fi

    log_info "Submitting DMG for notarization..."

    xcrun notarytool submit "$dmg_file" \
        --keychain-profile "$NOTARIZATION_PROFILE" \
        --wait

    log_info "Stapling notarization ticket..."
    xcrun stapler staple "$dmg_file"

    log_info "Notarization complete!"
}

# Rename DMG to our naming convention
finalize_dmg() {
    local dmg_file="$1"
    local final_name="Strawberry-Music-Player-$STRAWBERRY_VERSION-$ARCH.dmg"
    local output_dir="$BUILD_DIR/output"

    mkdir -p "$output_dir"
    cp "$dmg_file" "$output_dir/$final_name"

    log_info "Final DMG: $output_dir/$final_name"

    # Calculate SHA256
    local sha256=$(shasum -a 256 "$output_dir/$final_name" | awk '{print $1}')
    log_info "SHA256: $sha256"

    echo ""
    echo "=========================================="
    echo "Build complete!"
    echo "=========================================="
    echo "DMG: $output_dir/$final_name"
    echo "SHA256: $sha256"
    echo ""
    echo "To update the Cask, use this SHA256 value."
    echo "=========================================="
}

# Main build process
main() {
    log_info "Starting Strawberry standalone DMG build..."
    log_info "Version: $STRAWBERRY_VERSION"
    log_info "Architecture: $ARCH"
    log_info "Build directory: $BUILD_DIR"
    echo ""

    mkdir -p "$BUILD_DIR"

    check_prerequisites
    download_dependencies
    download_strawberry
    build_libgpod
    build_strawberry
    deploy_bundle

    DMG_FILE=$(create_dmg)
    notarize_dmg "$DMG_FILE"
    finalize_dmg "$DMG_FILE"
}

# Run main unless sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
