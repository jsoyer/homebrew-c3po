# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Homebrew tap (`jsoyer/tap`) containing custom formulas and casks for macOS. The tap includes developer tools (devbox, sqlit) and a specialized Strawberry Music Player build with iPod support not available in official Homebrew.

## Common Commands

```bash
# Test a formula locally before committing
brew install --build-from-source ./Formula/formula-name.rb

# Audit a formula for issues
brew audit --strict --online Formula/formula-name.rb

# Test a formula's test block
brew test Formula/formula-name.rb

# Install a cask locally
brew install --cask ./Casks/cask-name.rb

# Update bottle checksums after rebuilding
brew bottle Formula/formula-name.rb

# Build standalone DMG for Strawberry (requires APPLE_DEVELOPER_ID for signing)
APPLE_DEVELOPER_ID="Developer ID Application: Name" ./scripts/build-standalone-dmg.sh
```

## Architecture

### Directory Structure
- `Formula/` - Homebrew formulas (Ruby files that build from source)
- `Casks/` - Homebrew casks (Ruby files that install pre-built DMG/pkg)
- `scripts/` - Build scripts for standalone DMG creation

### Formulas
- **devbox.rb** - Pre-built binary download with multi-platform support (macOS/Linux, Intel/ARM)
- **sqlit.rb** - Python virtualenv-based installation with ~60 resource dependencies from PyPI
- **strawberry-music-player.rb** - Complex build with patching, builds libgpod inline for iPod support
- **libgpod.rb** - Standalone iPod library with pkg-config compatibility wrapper for libplist

### Casks
- **strawberry-music-player.rb** - Standalone DMG with all dependencies bundled (ARM64 only)

### Scripts
- **build-standalone-dmg.sh** - Builds Strawberry with bundled dependencies from strawberry-macos-dependencies

## Formula Conventions Used

- All formulas include SPDX license identifiers
- Pre-built bottles hosted on GitHub releases with SHA256 checksums
- `test` blocks validate installation (version checks or library compilation tests)
- `caveats` provide post-install setup instructions when needed
- `post_install` hooks for shell completions or symlink creation

## Key Patterns

### Multi-architecture binaries (devbox)
Uses `on_macos`/`on_linux` blocks with `on_intel`/`on_arm` sub-blocks for platform-specific downloads.

### Python formulas (sqlit)
Uses `virtualenv_install_with_resources` with explicit `resource` blocks for each PyPI dependency. Resources are organized by category in comments.

### Complex builds with patching (strawberry-music-player)
Builds dependencies inline, generates compatibility pkg-config files, and patches CMake files. Creates `/Applications` symlink in `post_install`.

### Bottle rebuilds
Use `rebuild N` in bottle block when updating bottles without version change. Increment the rebuild number each time.
