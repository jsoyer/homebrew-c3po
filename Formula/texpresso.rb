# Copyright Jerome Soyer
# SPDX-License-Identifier: Apache-2.0

class Texpresso < Formula
  desc "Live rendering and error reporting for LaTeX"
  homepage "https://github.com/let-def/texpresso"
  license "MIT"
  head "https://github.com/let-def/texpresso.git", branch: "main"

  stable do
    url "https://github.com/let-def/texpresso.git",
        tag:      "v0.1",
        revision: "1f17765ddad7e1f7c0fafc100f7fca5472952dc7"
  end

  bottle do
    root_url "https://github.com/jsoyer/homebrew-tap/releases/download/texpresso-0.1"
    sha256 cellar: :any, arm64_tahoe: "6f49508ccf95e81fabb9320a66588d809bf8d452624d8cc8f87e5cb7010ff516"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "icu4c@78"
  depends_on "jbig2dec"
  depends_on "jpeg-turbo"
  depends_on "mupdf-tools"
  depends_on "openjpeg"
  depends_on "openssl@3"
  depends_on "sdl2"

  uses_from_macos "zlib"

  def install
    mkdir_p "build/objects"

    mupdf = Formula["mupdf-tools"]
    harfbuzz = Formula["harfbuzz"]
    freetype = Formula["freetype"]
    icu4c = Formula["icu4c@78"]
    openssl = Formula["openssl@3"]

    # Detect optional mupdf-third library
    mupdf_third = (mupdf.opt_lib/"libmupdf-third.a").exist? ? "-lmupdf-third" : ""

    # Get SDL2 linker flags
    sdl2_libs = Utils.safe_popen_read("sdl2-config", "--libs").strip

    # Write Makefile.config directly, bypassing `make config` which hardcodes brew --prefix paths
    (buildpath/"Makefile.config").write <<~MAKEFILE
      CFLAGS=-O2 -I. -fPIC -I#{mupdf.opt_include} -I#{harfbuzz.opt_include}/harfbuzz -I#{freetype.opt_include}/freetype2 -I#{HOMEBREW_PREFIX}/include
      CC=#{ENV.cc} $(CFLAGS)
      LDCC=#{ENV.cxx} $(CFLAGS)
      LIBS=-L#{mupdf.opt_lib} -lmupdf #{mupdf_third} -L#{HOMEBREW_PREFIX}/lib -lm -lz -ljpeg -ljbig2dec -lharfbuzz -lfreetype -lopenjp2 #{sdl2_libs}
      TECTONIC_ENV=PKG_CONFIG_PATH=#{icu4c.opt_lib}/pkgconfig:#{openssl.opt_lib}/pkgconfig:$$PKG_CONFIG_PATH C_INCLUDE_PATH=#{icu4c.opt_include} LIBRARY_PATH=#{icu4c.opt_lib}
    MAKEFILE

    # Set environment for tectonic (Rust/Cargo) build
    ENV.prepend_path "PKG_CONFIG_PATH", icu4c.opt_lib/"pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", openssl.opt_lib/"pkgconfig"
    ENV["PKG_CONFIG_ALLOW_CROSS"] = "1"
    ENV["OPENSSL_DIR"] = openssl.opt_prefix.to_s

    # Build C binary and Rust/tectonic binary
    system "make", "texpresso"
    system "make", "texpresso-tonic"

    bin.install "build/texpresso"
    bin.install "build/texpresso-tonic"
  end

  test do
    assert_path_exists bin/"texpresso"
    assert_path_exists bin/"texpresso-tonic"
  end
end
