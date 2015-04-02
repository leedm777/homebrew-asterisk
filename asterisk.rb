require 'formula'

class Asterisk < Formula
  homepage 'http://www.asterisk.org'
  url 'http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-13.3.0.tar.gz'
  sha1 '85e5f3ae0528280f6f6df7c191631f495dea2eaf'

  # Asterisk depends on specific GCC features
  fails_with :clang
  fails_with :llvm

  depends_on 'pkg-config' => :build
  depends_on 'gcc' => :build

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

    system "make", "all", "NOISY_BUILD=yes"
    system "make", "install"
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
