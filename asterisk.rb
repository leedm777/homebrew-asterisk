class Asterisk < Formula
  desc "Open Source PBX and telephony toolkit"
  homepage "http://www.asterisk.org"
  url "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-13.6.0.tar.gz"
  sha256 "8a01b53c946d092ac561c11b404f68cd328306d0e3b434a7485a11d4b175005a"

  devel do
    url "https://github.com/asterisk/asterisk.git", :branch => "13"
    version "13.7-devel"
  end

  head do
    url "https://github.com/asterisk/asterisk.git"
    version "14-head"
  end

  option "with-dev-mode", "Enable dev mode in Asterisk"
  option "with-clang", "Compile with clang instead of gcc"
  option "with-gcc", "Compile with gcc (default)"
  option "without-optimizations", "Disable optimizations"

  if build.without? "clang"
    fails_with :llvm
    fails_with :clang
    # :gcc just matches on apple-gcc42
    fails_with :gcc

    depends_on "gcc" => :build
  end

  depends_on "pkg-config" => :build

  depends_on "iksemel"
  depends_on "jansson"
  depends_on "homebrew/dupes/ncurses"
  depends_on "openssl"
  depends_on "pjsip-asterisk"
  depends_on "speex"
  depends_on "sqlite"
  depends_on "srtp"
  depends_on "unixodbc"

  def install
    dev_mode = false
    optimize = true
    if build.with? "dev-mode"
      dev_mode = true
      optimize = false
    end

    if build.without? "optimizations"
      optimize = false
    end

    openssl = Formula["openssl"]
    sqlite = Formula["sqlite"]
    unixodbc = Formula["unixodbc"]
    pjsip = Formula["pjsip-asterisk"]

    # Some Asterisk code doesn't follow strict aliasing rules
    ENV.append "CFLAGS", "-fno-strict-aliasing"

    # Use brew's pkg-config
    ENV["PKG_CONFIG"] = "#{HOMEBREW_PREFIX}/bin/pkg-config"

    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--datadir=#{share}/#{name}",
                          "--docdir=#{doc}/asterisk",
                          "--enable-dev-mode=#{dev_mode ? 'yes' : 'no'}",
                          "--with-pjproject=#{pjsip.opt_prefix}",
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

    if not optimize
      system "menuselect/menuselect",
             "--enable", "DONT_OPTIMIZE", "menuselect.makeopts"
    end

    if dev_mode
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
