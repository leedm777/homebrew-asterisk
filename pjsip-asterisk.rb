class PjsipAsterisk < Formula
  desc "PJSIP libraries for Asterisk"
  homepage "http://www.pjsip.org/"
  url "http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2"
  sha256 "086f5e70dcaee312b66ddc24dac6ef85e6f1fec4eed00ff2915cebe0ee3cdd8d"

  keg_only "Specifically tuned just for asterisk"

  depends_on "libgsm"
  depends_on "openssl"
  depends_on "portaudio"
  depends_on "speex"
  depends_on "srtp15"

  patch :p0, :DATA

  def install
    ENV.j1

    openssl = Formula["openssl"]

    # Hack to truly disable opencore
    ENV["enable_opencore_amr"] = "no"
    # Build for not-debug
    ENV["CFLAGS"] = "-O2 -DNDEBUG"

    system "./configure", "--prefix=#{prefix}",
                          "--with-ssl=#{openssl.opt_prefix}",
                          "--enable-shared",
                          "--disable-opencore-amr",
                          "--disable-resample",
                          "--disable-sound",
                          "--disable-video",
                          "--with-external-gsm",
                          "--with-external-pa",
                          "--with-external-speex",
                          "--with-external-srtp"

    system "make", "all", "install"
  end
end

__END__

With Xcode 7.3, PJSIP build started failing to find dependent libs. This patch
lists them explicitly so that the linker can find them.

Index: pjmedia/build/Makefile
===================================================================
--- pjmedia/build/Makefile	(revision 5280)
+++ pjmedia/build/Makefile	(working copy)
@@ -128,6 +128,7 @@
 export PJSDP_LDFLAGS += $(PJMEDIA_LDLIB) \
 			$(PJLIB_LDLIB) \
 			$(PJLIB_UTIL_LDLIB) \
+			$(PJNATH_LDLIB) \
 			$(_LDFLAGS)
 
 
@@ -146,6 +147,8 @@
 			$(ILBC_CFLAGS) $(IPP_CFLAGS) $(G7221_CFLAGS)
 export PJMEDIA_CODEC_LDFLAGS += $(PJMEDIA_LDLIB) \
 				$(PJLIB_LDLIB) \
+				$(PJLIB_UTIL_LDLIB) \
+				$(PJNATH_LDLIB) \
 				$(_LDFLAGS)
 
 ###############################################################################
Index: pjsip/build/Makefile
===================================================================
--- pjsip/build/Makefile	(revision 5280)
+++ pjsip/build/Makefile	(working copy)
@@ -88,6 +88,9 @@
 			   $(PJMEDIA_LDLIB) \
 			   $(PJLIB_UTIL_LDLIB) \
 			   $(PJLIB_LDLIB) \
+			   $(PJMEDIA_VIDEODEV_LDLIB) \
+			   $(PJMEDIA_AUDIODEV_LDLIB) \
+			   $(PJNATH_LDLIB) \
 			   $(_LDFLAGS)
 
 
