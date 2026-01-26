# Copyright Jerome Soyer
# SPDX-License-Identifier: Apache-2.0

class StrawberryMusicPlayer < Formula
  desc "Cross-platform music player and music collection organizer"
  homepage "https://www.strawberrymusicplayer.org/"
  url "https://files.strawberrymusicplayer.org/strawberry-1.2.17.tar.xz"
  sha256 "98c988d4c9574681bf0b32b804c4d6b120807034a60ecb2fa8bd7f20ba2e1ca7"
  license "GPL-3.0-or-later"
  head "https://github.com/strawberrymusicplayer/strawberry.git", branch: "master"

  livecheck do
    url :stable
    regex(/strawberry[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/jsoyer/homebrew-tap/releases/download/strawberry-music-player-1.2.17"
    sha256 cellar: :any, arm64_tahoe: "8ab20f44c581fb1eef1ef5ceeeef0ad712f7c0d824a4bee83facbc05b708bae2"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "gtk-doc" => :build
  depends_on "intltool" => :build
  depends_on "libtool" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "chromaprint"
  depends_on "faad2"
  depends_on "fftw"
  depends_on "flac"
  depends_on "gdk-pixbuf"
  depends_on "gettext"
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "gstreamer"
  depends_on "icu4c@76"
  depends_on "lame"
  depends_on "libbs2b"
  depends_on "libcdio"
  depends_on "libebur128"
  depends_on "libmtp"
  depends_on "libogg"
  depends_on "libopenmpt"
  depends_on "libplist"
  depends_on "libsoup"
  depends_on "libvorbis"
  depends_on "mpg123"
  depends_on "musepack"
  depends_on "opus"
  depends_on "orc"
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "rapidjson"
  depends_on "speex"
  depends_on "sqlite"
  depends_on "taglib"
  depends_on "twolame"
  depends_on "wavpack"

  on_macos do
    depends_on "game-music-emu"
  end

  resource "kdsingleapplication" do
    url "https://github.com/KDAB/KDSingleApplication/archive/refs/tags/v1.2.0.tar.gz"
    sha256 "ff4ae6a4620beed1cdb3e6a9b78a17d7d1dae7139c3d4746d4856b7547d42c38"
  end

  resource "libgpod" do
    url "https://downloads.sourceforge.net/project/gtkpod/libgpod/libgpod-0.8/libgpod-0.8.3.tar.bz2"
    sha256 "638a7959d04e95f1e62abad02bd33702e4e8dfef98485ac7d9d50395c37e955d"
  end

  def install
    # Build and install KDSingleApplication first
    resource("kdsingleapplication").stage do
      system "cmake", "-S", ".", "-B", "build",
             "-DCMAKE_BUILD_TYPE=Release",
             "-DKDSingleApplication_QT6=ON",
             "-DKDSingleApplication_EXAMPLES=OFF",
             "-DKDSingleApplication_TESTS=OFF",
             *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Build and install libgpod for iPod support
    resource("libgpod").stage do
      # Create a symlink for libplist.pc since libgpod expects libplist, not libplist-2.0
      pkgconfig_dir = buildpath/"pkgconfig"
      pkgconfig_dir.mkpath
      (pkgconfig_dir/"libplist.pc").write <<~EOS
        prefix=#{Formula["libplist"].opt_prefix}
        exec_prefix=${prefix}
        libdir=${prefix}/lib
        includedir=${prefix}/include

        Name: libplist
        Description: A library to handle Apple Property Lists
        Version: 2.7.0
        Libs: -L${libdir} -lplist-2.0
        Cflags: -I${includedir}
      EOS

      ENV.prepend_path "PKG_CONFIG_PATH", pkgconfig_dir
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["libplist"].opt_lib/"pkgconfig"
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["glib"].opt_lib/"pkgconfig"
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["sqlite"].opt_lib/"pkgconfig"
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["gdk-pixbuf"].opt_lib/"pkgconfig"

      system "autoreconf", "-fiv"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--disable-gtk-doc",
                            "--disable-pygobject",
                            "--disable-udev",
                            "--without-hal",
                            "--prefix=#{prefix}"
      system "make", "install"
    end

    # Patch cmake/Dmg.cmake to remove REQUIRED from macdeploycheck and create-dmg
    # These tools are not available via Homebrew and are only needed for DMG creation
    inreplace "cmake/Dmg.cmake" do |s|
      s.gsub!(/find_program\(MACDEPLOYCHECK_EXECUTABLE.*REQUIRED\)/,
              "find_program(MACDEPLOYCHECK_EXECUTABLE NAMES macdeploycheck)")
      s.gsub!(/find_program\(CREATEDMG_EXECUTABLE.*REQUIRED\)/,
              "find_program(CREATEDMG_EXECUTABLE NAMES create-dmg)")
    end

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O2"

    args = %W[
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_PREFIX_PATH=#{Formula["qt@6"].opt_prefix};#{prefix}
      -DBUILD_WITH_QT6=ON
      -DENABLE_SPARKLE=OFF
      -DENABLE_QTSPARKLE=OFF
      -DENABLE_STREAMTAGREADER=OFF
      -DENABLE_TRANSLATIONS=ON
      -DCREATE_DMG=OFF
    ]

    # macOS specific options
    if OS.mac?
      args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}"
      args << "-DENABLE_DBUS=OFF"
      args << "-DENABLE_BUNDLE=ON"
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    if OS.mac? && (buildpath/"build/Strawberry.app").exist?
      # Move the app bundle to the correct location
      prefix.install "build/Strawberry.app"
    end
  end

  def caveats
    <<~EOS
      Note: Some GStreamer plugins may not be available through Homebrew.
      For full codec support, you may need to install additional GStreamer plugins.

      To set up GStreamer environment variables, add to your shell profile:
        export GIO_EXTRA_MODULES="#{HOMEBREW_PREFIX}/lib/gio/modules"
        export GST_PLUGIN_SCANNER="#{HOMEBREW_PREFIX}/libexec/gstreamer-1.0/gst-plugin-scanner"
        export GST_PLUGIN_PATH="#{HOMEBREW_PREFIX}/lib/gstreamer-1.0"
    EOS
  end

  test do
    if OS.mac?
      assert_path_exists prefix/"Strawberry.app"
    else
      assert_match "strawberry", shell_output("#{bin}/strawberry --version 2>&1", 1)
    end
  end
end
