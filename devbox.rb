# Copyright Jerome Soyer
# SPDX-License-Identifier: Apache-2.0

class Devbox < Formula
  desc "Portable, Isolated Dev Environments on any Machine"
  homepage "https://www.jetify.com/devbox"
  license "Apache-2.0"

  version "0.16.0"
  # When updating the version here, make sure to also update the SHA-256 checksums below
  # using the checksums.txt file provided with the GitHub release.

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_darwin_amd64.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "84049d509b44f8d3919bfbd1a472ad6e38f3f0ded1705eb7a1debc0c8d21918d"
  elsif OS.mac? && Hardware::CPU.arm?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_darwin_arm64.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "02dc863efb372330bc002df8c6687340e95e70bafdf6abd9a671e435a9c1b8fd"
  elsif OS.linux? && Hardware::CPU.intel? && !Hardware::CPU.is_64_bit?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_linux_386.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "0c4683c17eae0b5add6204d836f989e3aa237343de4b424f4fa8bc09a27429f5"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_linux_amd64.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "40de3daf9fd8f0d1bde6e274c8eeee3d5f6063e901c6dbebb3dd11f7834e1d0d"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_linux_arm64.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "a0dc960b560d83cfb0066245219c8fbda0488d5adec948c707a1a7f57eaee692"
  elsif OS.linux? && Hardware::CPU.arm? && !Hardware::CPU.is_64_bit?
    url "https://github.com/jetify-com/devbox/releases/download/#{version}/devbox_#{version}_linux_armv7l.tar.gz",
      verified: "github.com/jetify-com/devbox/"
    sha256 "3447592928219339c470da99c5774102e5ca7a8e757ae0df31dff3a3ab56b399"
  else
    odie "Unexpected platform!"
  end

  def install
    bin.install "devbox" => "devbox"
  end

  def post_install
    generate_completions_from_executable(bin/"devbox", "completion")
  end

  test do
    system "#{bin}/devbox", "--version"
  end
end
