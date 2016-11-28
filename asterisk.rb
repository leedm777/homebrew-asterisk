class Asterisk < Formula
  desc "Open Source PBX and telephony toolkit"
  homepage "http://www.asterisk.org"
  url "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-14.2.0.tar.gz"
  sha256 "ae65fc88fd0e73ae2b8e11be62ecaa0e60b53115f6e85d9754179010124c75f1"

  devel do
    url "https://github.com/asterisk/asterisk.git", :branch => "14"
    version "14-devel"
  end

  head do
    url "https://github.com/asterisk/asterisk.git"
    version "head"
  end

  option "with-dev-mode", "Enable dev mode in Asterisk"
  option "with-clang", "Compile with clang instead of gcc"
  option "with-gcc", "Compile with gcc (default)"
  option "without-optimizations", "Disable optimizations"

  option "without-sounds-en", "Install English sound packages"
  option "with-sounds-en-au", "Install Australian sound packages"
  option "with-sounds-en-gb", "Install British sound packages"
  option "with-sounds-es", "Install Spanish sound packages"
  option "with-sounds-fr", "Install French sound packages"
  option "with-sounds-it", "Install Italian sound packages"
  option "with-sounds-ru", "Install Russian sound packages"
  option "with-sounds-ja", "Install Japanese sound packages"
  option "with-sounds-sv", "Install Swedish sound packages"

  option "without-sounds-gsm", "Install GSM formatted sounds"
  option "with-sounds-wav", "Install WAV formatted sounds"
  option "with-sounds-ulaw", "Install uLaw formatted sounds"
  option "with-sounds-alaw", "Install aLaw formatted sounds"
  option "with-sounds-g729", "Install G.729 formatted sounds"
  option "with-sounds-g722", "Install G.722 formatted sounds"
  option "with-sounds-sln16", "Install SLN16 formatted sounds"
  option "with-sounds-siren7", "Install SIREN7 formatted sounds"
  option "with-sounds-siren14", "Install SIREN14 formatted sounds"

  option "with-sounds-extras", "Install extra sound packages"

  if build.without? "clang"
    fails_with :llvm
    fails_with :clang
    # :gcc just matches on apple-gcc42
    fails_with :gcc

    depends_on "gcc" => :build
  end

  depends_on "pkg-config" => :build

  depends_on "jansson"
  depends_on "openssl"
  depends_on "pjsip-asterisk"
  depends_on "speex"
  depends_on "homebrew/versions/srtp15"

  def install
    langs = [
      "en", "en-au", "en-gb", "es", "fr", "it", "ru", "ja", "sv"
    ].select { |lang| build.with? "sounds-#{lang}" }
    formats = [
      "gsm", "wav", "ulaw", "alaw", "g729", "g722", "sln16", "siren7", "siren14"
    ].select { |format| build.with? "sounds-#{format}" }

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
                          "--with-ssl=#{openssl.opt_prefix}",
                          "--with-pjproject=#{pjsip.opt_prefix}",
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

    formats.each { |format|
      system "menuselect/menuselect",
             "--enable", "MOH-OPSOUND-#{format.upcase}", "menuselect.makeopts"

      langs.each { |lang|
        system "menuselect/menuselect",
               "--enable", "CORE-SOUNDS-#{lang.upcase}-#{format.upcase}", "menuselect.makeopts"

        if build.with? 'sounds-extras'
          system "menuselect/menuselect",
                 "--enable", "EXTRA-SOUNDS-#{lang.upcase}-#{format.upcase}", "menuselect.makeopts"
        end
      }
    }

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
