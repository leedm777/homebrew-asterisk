require 'formula'

class Asterisk < Formula
  homepage 'http://www.asterisk.org'
  url 'http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-13.4.0.tar.gz'
  sha1 'fb5e1244899dbc5d769f2554b63a4783fd5b8ef0'

  option "with-dev-mode", "Enable dev mode in Asterisk"
  option "with-clang", "Compile with clang instead of gcc"

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

  patch :p0, :DATA

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
end

__END__
Change -Xlinker to -Wl,

I don't have a good reason for it, but when building Asterisk via
homebrew fails when using the -Xlinker option. The -Wl, does the same
thing, and works, so we'll do that.

Index: Makefile
===================================================================
--- Makefile	(revision 433964)
+++ Makefile	(working copy)
@@ -254,10 +254,10 @@
 
 ifneq ($(findstring darwin,$(OSARCH)),)
   _ASTCFLAGS+=-D__Darwin__ -mmacosx-version-min=10.6
-  _SOLINK=-mmacosx-version-min=10.6 -Xlinker -undefined -Xlinker dynamic_lookup
+  _SOLINK=-mmacosx-version-min=10.6 -Wl,-undefined,dynamic_lookup
   _SOLINK+=/usr/lib/bundle1.o
   SOLINK=-bundle $(_SOLINK)
-  DYLINK=-Xlinker -dylib $(_SOLINK)
+  DYLINK=-Wl,-dylib $(_SOLINK)
   _ASTLDFLAGS+=-L/usr/local/lib
 else
 # These are used for all but Darwin
