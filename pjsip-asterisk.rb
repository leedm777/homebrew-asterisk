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
  depends_on "srtp"

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
