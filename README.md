# 🍺 Homebrew Tap

> *A personal Homebrew tap for useful developer tools*

A curated collection of powerful development tools, packaged and ready to install on your Mac.

## 📦 Quick Start

Add this tap to your Homebrew:

```bash
brew tap jsoyer/tap
```

## 🛠️ Available Formulas

### 📦 Devbox

**Portable, Isolated Dev Environments on any Machine**

<img src="https://img.shields.io/badge/version-0.16.0-blue" alt="Version"> <img src="https://img.shields.io/badge/bottle-available-green" alt="Bottle Available"> <img src="https://img.shields.io/badge/platform-macOS-lightgrey" alt="Platform">

Devbox creates isolated development environments without containers. Perfect for managing project-specific dependencies.

**✨ Features:**
- 🔒 Isolated development environments
- 🚀 No Docker required
- 📝 Declarative configuration
- 🔄 Reproducible builds

**Installation:**

```bash
brew install jsoyer/tap/devbox
```

**Quick Start:**

```bash
devbox init                 # Initialize a new project
devbox add python nodejs    # Add packages
devbox shell               # Enter the environment
```

**More info:** [jetify.com/devbox](https://www.jetify.com/devbox)

---

### 🗄️ Sqlit

**Terminal UI for SQL Databases - The lazygit of databases**

<img src="https://img.shields.io/badge/version-1.2.5-blue" alt="Version"> <img src="https://img.shields.io/badge/python-3.12-yellow" alt="Python"> <img src="https://img.shields.io/badge/databases-20+-purple" alt="Databases">

A beautiful terminal user interface for managing SQL databases. Navigate your databases like you navigate code with lazygit!

**✨ Features:**
- �� Beautiful TUI with syntax highlighting
- 🔌 Support for 20+ database types
- ⚡ Fast navigation with keyboard shortcuts
- 📊 Data table visualization
- 🔍 Query history and favorites
- 🐳 Docker container support

**Supported Databases:**
PostgreSQL • MySQL • SQLite • MariaDB • CockroachDB • Oracle • SQL Server • MongoDB • DuckDB • ClickHouse • BigQuery • Snowflake • Redshift • Athena • Presto • Trino • Supabase • Turso • and more!

**Installation:**

```bash
brew install jsoyer/tap/sqlit
```

**Quick Start:**

```bash
sqlit                              # Launch with connection manager
sqlit --db-type sqlite --database mydb.db    # Direct connection
sqlit --help                       # See all options
```

**More info:** [github.com/Maxteabag/sqlit](https://github.com/Maxteabag/sqlit)

---

### 🍓 Strawberry Music Player

**Cross-platform Music Player with iPod and Discord Support**

<img src="https://img.shields.io/badge/version-1.2.17-blue" alt="Version"> <img src="https://img.shields.io/badge/bottle-available-green" alt="Bottle Available"> <img src="https://img.shields.io/badge/platform-macOS-lightgrey" alt="Platform">

Strawberry is a music player and music collection organizer. It is a fork of Clementine released in 2018 aimed at music collectors and audiophiles.

**Features:**
- Play and organize music
- Edit tags on audio files
- Album cover art from various sources
- Support for high resolution audio
- Audio CD playback and ripping
- Native desktop notifications
- Visualizations from projectM
- Lyrics from multiple sources
- iPod, MTP and mass storage USB device support
- Scrobbler supporting Last.fm, Libre.fm and ListenBrainz
- Discord Rich Presence support
- Subsonic/Airsonic/Navidrome/Gonic streaming support
- Tidal and Qobuz streaming support

**Installation:**

```bash
brew install jsoyer/tap/strawberry-music-player
```

**Quick Start:**

After installation, add these environment variables to your shell profile for full GStreamer support:

```bash
export GIO_EXTRA_MODULES="/opt/homebrew/lib/gio/modules"
export GST_PLUGIN_SCANNER="/opt/homebrew/libexec/gstreamer-1.0/gst-plugin-scanner"
export GST_PLUGIN_PATH="/opt/homebrew/lib/gstreamer-1.0"
```

Then launch Strawberry from your Applications folder or via Spotlight.

**More info:** [strawberrymusicplayer.org](https://www.strawberrymusicplayer.org/)

---

### 📱 libgpod

**Library for Accessing iPod Contents**

<img src="https://img.shields.io/badge/version-0.8.3-blue" alt="Version"> <img src="https://img.shields.io/badge/platform-macOS-lightgrey" alt="Platform">

A shared library to access the contents of an iPod. It supports reading and writing of the iTunesDB and provides bindings for application development.

**Features:**
- Read and write iPod database (iTunesDB)
- Support for music, photos, and artwork
- Cover art handling
- Smart playlist support
- Works with classic iPods and older iOS devices

**Installation:**

```bash
brew install jsoyer/tap/libgpod
```

**Usage:**

libgpod is a C library used by applications like Strawberry, gtkpod, and Rhythmbox to sync music with iPods.

**More info:** [gtkpod.org (archived)](https://web.archive.org/web/20210118214105/http://www.gtkpod.org/libgpod/)

---

## 🚀 Why Use This Tap?

- ✅ **Pre-built Bottles** - Fast installation with pre-compiled binaries (where available)
- 🔄 **Always Updated** - Latest stable versions
- 📝 **Well Documented** - Clear instructions and examples
- 🧪 **Tested** - All formulas are tested before release
- 🛡️ **Maintained** - Regular updates and bug fixes

## 🔧 Advanced Usage

### Update All Formulas

```bash
brew update
brew upgrade jsoyer/tap/devbox jsoyer/tap/sqlit jsoyer/tap/strawberry-music-player jsoyer/tap/libgpod
```

### Uninstall

```bash
brew uninstall devbox sqlit strawberry-music-player libgpod
brew untap jsoyer/tap
```

## 📊 Installation Stats

| Formula | Size | Install Time | Dependencies |
|---------|------|--------------|--------------|
| Devbox  | ~29MB | ~2 seconds (bottle) | None |
| Sqlit   | ~202MB | ~3 minutes (bottle) | Python 3.12, Rust |
| Strawberry Music Player | ~18.5MB | ~4 minutes (bottle) | Qt6, GStreamer, many audio libs |
| libgpod | ~1MB | ~2 minutes (bottle) | glib, libplist, taglib |

## 🤝 Contributing

Found a bug? Have a suggestion? Want to add a new formula?

1. 🐛 [Open an issue](https://github.com/jsoyer/homebrew-tap/issues)
2. 🔧 Submit a pull request
3. 💬 Start a discussion

### Adding a New Formula

To add a new formula to this tap:

1. Fork this repository
2. Create a new `.rb` file in the `Formula/` directory
3. Follow the [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
4. Submit a pull request

**Example:**

```ruby
class MyTool < Formula
  desc "Amazing development tool"
  homepage "https://example.com/mytool"
  url "https://github.com/user/mytool/archive/v1.0.0.tar.gz"
  sha256 "abc123..."
  license "MIT"

  def install
    bin.install "mytool"
  end

  test do
    system "#{bin}/mytool", "--version"
  end
end
```

## 📚 Resources

- 📖 [Homebrew Documentation](https://docs.brew.sh/)
- 🔧 [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- 🎓 [Homebrew Taps](https://docs.brew.sh/Taps)

## 📜 License

This tap is licensed under the MIT License. Individual formulas may have their own licenses.

## 🙏 Credits

- **Devbox** by [Jetify](https://www.jetify.com/)
- **Sqlit** by [Maxteabag](https://github.com/Maxteabag)
- **Strawberry Music Player** by [Jonas Kvinge](https://github.com/strawberrymusicplayer/strawberry)
- **libgpod** by the [gtkpod team](https://sourceforge.net/projects/gtkpod/)
- Maintained with ❤️ by [Jerome Soyer](https://github.com/jsoyer)

---

<p align="center">
  <sub>Made with ☕ and 🤖</sub><br>
  <sub>⭐ Star this repo if you find it useful!</sub>
</p>
