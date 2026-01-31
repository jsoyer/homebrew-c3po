# Copyright Jerome Soyer
# SPDX-License-Identifier: Apache-2.0

cask "strawberry-music-player" do
  version "1.2.17"
  sha256 "9e61574e310f439c00391d70752d4d2b0f4f107109e49a9b8c88de614f681ce1"

  url "https://github.com/jsoyer/homebrew-tap/releases/download/strawberry-music-player-#{version}/Strawberry-Music-Player-#{version}-arm64.dmg"
  name "Strawberry Music Player"
  desc "Cross-platform music player with iPod support (standalone)"
  homepage "https://www.strawberrymusicplayer.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"
  depends_on arch: :arm64
  # Standalone build - all dependencies bundled in the app

  app "Strawberry.app"

  zap trash: [
    "~/Library/Application Support/Strawberry",
    "~/Library/Caches/Strawberry",
    "~/Library/Preferences/org.strawberrymusicplayer.strawberry.plist",
    "~/Library/Saved Application State/org.strawberrymusicplayer.strawberry.savedState",
  ]

  caveats <<~EOS
    This is a standalone build with all dependencies bundled.
    Includes iPod support via libgpod.
  EOS
end
