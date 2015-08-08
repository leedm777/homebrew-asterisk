require 'formula'

class Asterisk < Formula
  homepage 'http://www.asterisk.org'
  url 'http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-13.5.0.tar.gz'
  sha1 '7715d7496ca35e93482a15fd7044f05f4d8bdbe5'

  option "with-dev-mode", "Enable dev mode in Asterisk"
  option "with-clang", "Compile with clang instead of gcc"

  devel do
    url "https://gerrit.asterisk.org/asterisk.git", :branch => "13"
    version "13"

    patch do
      url "https://github.com/leedm777/asterisk/commit/06b464ab1b7c42e3c1b5b05463d5bc73c112dd76.patch"
      sha256 "b735fa4839517cc149642a10d45aefe5ff4fa7b19d9733b5305e2c253a004e05"
    end
  end

  head do
    url "https://gerrit.asterisk.org/asterisk.git"

    patch do
      url "https://github.com/leedm777/asterisk/commit/06b464ab1b7c42e3c1b5b05463d5bc73c112dd76.patch"
      sha256 "b735fa4839517cc149642a10d45aefe5ff4fa7b19d9733b5305e2c253a004e05"
    end

    patch do
      url "https://github.com/leedm777/asterisk/commit/40caf0ad9bef07bdfb568a88192c157dd1840100.patch"
      sha256 "eb6ae6ecd62d4a64c668efeade57d93c73080aa37efb09a04d728045d931caac"
    end
  end

  if not build.with? "clang"
    fails_with :llvm
    fails_with :clang

    depends_on 'gcc' => :build
  end

  depends_on 'pkg-config' => :build

  depends_on 'gmime'
  depends_on 'iksemel'
  depends_on 'jansson'
  depends_on 'homebrew/dupes/ncurses'
  depends_on 'openssl'
  depends_on 'pjsip-asterisk'
  depends_on 'speex'
  depends_on 'sqlite'
  depends_on 'srtp'
  depends_on 'unixodbc'

  def install
    # To help debug broken builds
    if ARGV.verbose?
      # disable parallel builds
      ENV.j1
    end

    dev_mode = "no"
    if build.with? "dev-mode"
      dev_mode = "yes"
    end

    openssl = Formula['openssl']
    sqlite = Formula['sqlite']
    unixodbc = Formula['unixodbc']
    pjsip = Formula['pjsip-asterisk']

    # Some Asterisk code doesn't follow strict aliasing rules
    ENV.append "CFLAGS", "-fno-strict-aliasing"

    # Use brew's pkg-config
    ENV["PKG_CONFIG"] = "#{HOMEBREW_PREFIX}/bin/pkg-config"

    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--datadir=#{share}/#{name}",
                          "--docdir=#{doc}/asterisk",
                          "--enable-dev-mode=#{dev_mode}",
                          "--with-pjsip=#{pjsip.opt_prefix}",
                          "--with-sqlite3=#{sqlite.opt_prefix}",
                          "--with-ssl=#{openssl.opt_prefix}",
                          "--with-unixodbc=#{unixodbc.opt_prefix}",
                          "--without-gmime",
                          "--without-gtk2",
                          "--without-iodbc",
                          "--without-netsnmp"

    system "make", "menuselect/cmenuselect",
                   "menuselect/nmenuselect",
                   "menuselect/gmenuselect",
                   "menuselect/menuselect",
                   "menuselect-tree",
                   "menuselect.makeopts"

    # Inline function cause errors with Homebrew's gcc-4.8
    system "menuselect/menuselect",
           "--enable", "DISABLE_INLINE", "menuselect.makeopts"
    # Native compilation doesn't work with Homebrew's gcc-4.8
    system "menuselect/menuselect",
           "--disable", "BUILD_NATIVE", "menuselect.makeopts"

    if dev_mode == "yes"
      system "menuselect/menuselect",
             "--enable", "DONT_OPTIMIZE", "menuselect.makeopts"
      system "menuselect/menuselect",
             "--enable", "TEST_FRAMEWORK", "menuselect.makeopts"
      system "menuselect/menuselect",
             "--enable", "DO_CRASH", "menuselect.makeopts"
      system "menuselect/menuselect",
             "--enable-category", "MENUSELECT_TESTS", "menuselect.makeopts"
    end

    system "make", "all", "NOISY_BUILD=yes"
    system "make", "install", "samples"

    # Replace Cellar references to opt/asterisk
    system "sed", "-i", "", "s#Cellar/asterisk/[^/]*/#opt/asterisk/#", "#{etc}/asterisk/asterisk.conf"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
          <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/asterisk</string>
          <string>-f</string>
          <string>-C</string>
          <string>#{etc}/asterisk/asterisk.conf</string>
        </array>
         <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/asterisk.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/asterisk.log</string>
        <key>ServiceDescription</key>
        <string>Asterisk PBX</string>
      </dict>
    </plist>
    EOS
  end
end
