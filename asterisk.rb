class Asterisk < Formula
  desc "Open Source PBX and telephony toolkit"
  homepage "http://www.asterisk.org"
  url "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-15.1.5.tar.gz"
  sha256 "f1ef579fa635a54c6c149b47f23f3f022e5e1ad0ef762122b2b2f2410c4fa759"

  # Fixes needed for stable, 15 branch, and master
  patch do
    url "https://github.com/leedm777/asterisk/commit/cc159e4152e9f071228eec47fdaf07b3974e27db.patch"
    sha256 "cf8c444fc7fe38d5761852d780fb4e8284f43df716f1a649e862ec186158f711"
  end

  devel do
    url "https://github.com/asterisk/asterisk.git", :branch => "15"
    version "15-devel"

    # Fixes for bugs introduced on 15 branch
    patch do
      url "https://github.com/leedm777/asterisk/commit/5e9d11fb518f8072d0f3d57ec4c3303431e849d4.patch"
      sha256 "3b3fd91ea4580572baefb85adf8d7ae544e38255efa4d9f071a560b1cd05ea9e"
    end
  end

  head do
    url "https://github.com/asterisk/asterisk.git"
    version "head"

    # Fixes for bugs introduced on 15 branch
    patch do
      url "https://github.com/leedm777/asterisk/commit/5e9d11fb518f8072d0f3d57ec4c3303431e849d4.patch"
      sha256 "3b3fd91ea4580572baefb85adf8d7ae544e38255efa4d9f071a560b1cd05ea9e"
    end
  end

  # backport fixes that are already on the 15 branch
  stable do
    # tests: Fix warnings found on Mac
    patch do
      url "https://github.com/asterisk/asterisk/commit/ef4dc43a756c61defa8c6cc93025725924e2285c.patch"
      sha256 "fe886362e4979e750f3f053313180e89c2667e3dc58158cf73796dfdc97fa14a"
    end

    # iostream: Fix ast_iostream_printf declaration
    patch do
      url "https://github.com/asterisk/asterisk/commit/9da69ac6c16e008c72ec8fda2d34b1036cdbfde3.patch"
      sha256 "7ef07c38dbcc7b714245695127cb25bf4642bc3a3aed4c8814158d0a7305aae8"
    end

    # res_fax: Remove checks for unsigned values being >= 0
    patch do
      url "https://github.com/asterisk/asterisk/commit/85d675b14c7f946b86cc371a43aaa7f5d314d8c2.patch"
      sha256 "3011e3a8c234687cefa1202dff25159da40462594ec89b9d9d6b8b736176920a"
    end

    # app_minivm: Fix possible uninitialized return value
    patch do
      url "https://github.com/asterisk/asterisk/commit/19ba25dd962895d9a25b88678f7a49d21f7adc54.patch"
      sha256 "70bd3c397c1e44a6bb8bdee06c221fa50994c485fbf98c7defd462dd96e3c2ce"
    end
  end

  option "with-dev-mode", "Enable dev mode in Asterisk"
  option "with-clang", "Compile with clang (default)"
  option "with-gcc", "Compile with gcc instead of clang"
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

  if build.with? "gcc"
    fails_with :clang do
      build 9999999 # unconditionally switch to a different compiler
      cause "avoiding clang as the compiler"
    end
    # :gcc just matches on apple-gcc42
    fails_with :gcc do
      cause "Apple's GCC 4.2 is too old to build Asterisk reliably"
    end

    depends_on "gcc" => :build
  end

  depends_on "pkg-config" => :build

  depends_on "jansson"
  depends_on "libgsm"
  depends_on "libxml2"
  depends_on "openssl"
  depends_on "pjsip-asterisk"
  depends_on "speex"
  depends_on "sqlite"
  depends_on "srtp"

  def install
    langs = %w[en en-au en-gb es fr it ru ja sv].select do |lang|
      build.with? "sounds-#{lang}"
    end
    formats = %w[gsm wav ulaw alaw g729 g722 sln16 siren7 siren14].select do |format|
      build.with? "sounds-#{format}"
    end

    dev_mode = false
    optimize = true
    if build.with? "dev-mode"
      dev_mode = true
      optimize = false
    end

    optimize = false if build.without? "optimizations"

    # Some Asterisk code doesn't follow strict aliasing rules
    ENV.append "CFLAGS", "-fno-strict-aliasing"

    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--datadir=#{share}/#{name}",
                          "--docdir=#{doc}/asterisk",
                          "--enable-dev-mode=#{dev_mode ? "yes" : "no"}",
                          "--with-crypto",
                          "--with-ssl",
                          "--without-pjproject-bundled",
                          "--with-pjproject",
                          "--with-sqlite3",
                          "--without-sqlite",
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

    unless optimize
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

    formats.each do |format|
      system "menuselect/menuselect",
             "--enable", "MOH-OPSOUND-#{format.upcase}", "menuselect.makeopts"

      langs.each do |lang|
        system "menuselect/menuselect",
               "--enable", "CORE-SOUNDS-#{lang.upcase}-#{format.upcase}", "menuselect.makeopts"

        if build.with? "sounds-extras"
          system "menuselect/menuselect",
                 "--enable", "EXTRA-SOUNDS-#{lang.upcase}-#{format.upcase}", "menuselect.makeopts"
        end
      end
    end

    system "make", "all", "NOISY_BUILD=yes"
    system "make", "install", "samples"

    # Replace Cellar references to opt/asterisk
    system "sed", "-i", "", "s#Cellar/asterisk/[^/]*/#opt/asterisk/#", "#{etc}/asterisk/asterisk.conf"
  end

  plist_options :startup => false, :manual => "asterisk -r"

  def plist; <<-EOS
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
