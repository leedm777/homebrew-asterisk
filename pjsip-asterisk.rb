class PjsipAsterisk < Formula
  desc "PJSIP libraries for Asterisk"
  homepage "http://www.pjsip.org/"
  url "http://pjsip.org/release/2.7.1/pjproject-2.7.1.tar.bz2"
  sha256 "59fabc62a02b2b80857297cfb10e2c68c473f4a0acc6e848cfefe8421f2c3126"

  keg_only "Specifically tuned just for asterisk"

  depends_on "openssl"
  depends_on "portaudio"
  depends_on "srtp"

  patch :p0, :DATA

  def install
    ENV.deparallelize

    # Hack to truly disable opencore
    ENV["enable_opencore_amr"] = "no"
    # Build for not-debug
    ENV["CFLAGS"] = "-O2 -DNDEBUG"

    config_site = <<-EOF
      #include <sys/select.h>

      /*
       * Defining PJMEDIA_HAS_SRTP to 0 does NOT disable Asterisk's ability to use srtp.
       * It only disables the pjmedia srtp transport which Asterisk doesn't use.
       * The reason for the disable is that while Asterisk works fine with older libsrtp
       * versions, newer versions of pjproject won't compile with them.
       */
      #define PJMEDIA_HAS_SRTP 0

      /*
       * Defining PJMEDIA_HAS_WEBRTC_AEC to 0 does NOT disable Asterisk's ability to use
       * webrtc.  It only disables the pjmedia webrtc transport which Asterisk doesn't use.
       */
      #define PJMEDIA_HAS_WEBRTC_AEC 0

      #define PJ_HAS_IPV6 1
      #define NDEBUG 1
      #define PJ_MAX_HOSTNAME (256)
      #define PJSIP_MAX_URL_SIZE (512)
      #define PJ_IOQUEUE_MAX_HANDLES  (FD_SETSIZE)
      #define PJ_IOQUEUE_HAS_SAFE_UNREG 1
      #define PJ_IOQUEUE_MAX_EVENTS_IN_SINGLE_POLL (16)

      #define PJ_SCANNER_USE_BITWISE  0
      #define PJ_OS_HAS_CHECK_STACK   0

      #ifndef PJ_LOG_MAX_LEVEL
      #define PJ_LOG_MAX_LEVEL                6
      #endif

      #define PJ_ENABLE_EXTRA_CHECK   1
      #define PJSIP_MAX_TSX_COUNT             ((64*1024)-1)
      #define PJSIP_MAX_DIALOG_COUNT  ((64*1024)-1)
      #define PJSIP_UDP_SO_SNDBUF_SIZE        (512*1024)
      #define PJSIP_UDP_SO_RCVBUF_SIZE        (512*1024)
      #define PJ_DEBUG                        0
      #define PJSIP_SAFE_MODULE               0
      #define PJ_HAS_STRICMP_ALNUM            0

      /*
       * Do not ever enable PJ_HASH_USE_OWN_TOLOWER because the algorithm is
       * inconsistently used when calculating the hash value and doesn't
       * convert the same characters as pj_tolower()/tolower().  Thus you
       * can get different hash values if the string hashed has certain
       * characters in it.  (ASCII '@', '[', '\\', ']', '^', and '_')
       */
      #undef PJ_HASH_USE_OWN_TOLOWER

      /*
        It is imperative that PJSIP_UNESCAPE_IN_PLACE remain 0 or undefined.
        Enabling it will result in SEGFAULTS when URIs containing escape sequences are encountered.
      */
      #undef PJSIP_UNESCAPE_IN_PLACE
      #define PJSIP_MAX_PKT_LEN                       32000

      #undef PJ_TODO
      #define PJ_TODO(x)

      /* Defaults too low for WebRTC */
      #define PJ_ICE_MAX_CAND 32
      #define PJ_ICE_MAX_CHECKS (PJ_ICE_MAX_CAND * PJ_ICE_MAX_CAND)

      /* Increase limits to allow more formats */
      #define PJMEDIA_MAX_SDP_FMT   64
      #define PJMEDIA_MAX_SDP_BANDW   4
      #define PJMEDIA_MAX_SDP_ATTR   (PJMEDIA_MAX_SDP_FMT*2 + 4)
      #define PJMEDIA_MAX_SDP_MEDIA   16
    EOF
    (buildpath/"pjlib/include/pj/config_site.h").write(config_site)

    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared",
                          "--disable-resample",
                          "--disable-speex-codec",
                          "--disable-speex-aec",
                          "--disable-speex-aec",
                          "--disable-gsm-codec",
                          "--disable-ilbc-codec",
                          "--disable-l16-codec",
                          "--disable-g722-codec",
                          "--disable-g7221-codec",
                          "--disable-opencore-amr",
                          "--disable-silk",
                          "--disable-opus",
                          "--disable-video",
                          "--disable-v4l2",
                          "--disable-sound",
                          "--disable-ext-sound",
                          "--disable-oss",
                          "--disable-sdl",
                          "--disable-libyuv",
                          "--disable-ffmpeg",
                          "--disable-openh264",
                          "--disable-ipp",
                          "--disable-libwebrtc",
                          "--with-external-pa",
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
 
 
