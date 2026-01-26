# Copyright Jerome Soyer
# SPDX-License-Identifier: Apache-2.0

cask "strawberry-music-player" do
  version "1.2.17"
  sha256 "9e61574e310f439c00391d70752d4d2b0f4f107109e49a9b8c88de614f681ce1"

  url "https://github.com/jsoyer/homebrew-tap/releases/download/strawberry-music-player-#{version}/Strawberry-Music-Player-#{version}-arm64.dmg"
  name "Strawberry Music Player"
  desc "Cross-platform music player with iPod support"
  homepage "https://www.strawberrymusicplayer.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"
  depends_on arch: :arm64
  depends_on formula: [
    "qt@6",
    "gstreamer",
    "glib",
    "sqlite",
    "taglib",
    "gettext",
  ]

  app "Strawberry.app"

  zap trash: [
    "~/Library/Application Support/Strawberry",
    "~/Library/Caches/Strawberry",
    "~/Library/Preferences/org.strawberrymusicplayer.strawberry.plist",
    "~/Library/Saved Application State/org.strawberrymusicplayer.strawberry.savedState",
  ]

  caveats <<~EOS
    This version includes iPod support via libgpod.

    Some GStreamer plugins may not be available through Homebrew.
    For full codec support, you may need to install additional GStreamer plugins.

    To set up GStreamer environment variables, add to your shell profile:
      export GIO_EXTRA_MODULES="$(brew --prefix)/lib/gio/modules"
      export GST_PLUGIN_SCANNER="$(brew --prefix)/libexec/gstreamer-1.0/gst-plugin-scanner"
      export GST_PLUGIN_PATH="$(brew --prefix)/lib/gstreamer-1.0"
  EOS
end
