require 'formula'

class PjsipAsterisk < Formula
  homepage 'http://www.pjsip.org/'
  url 'http://www.pjsip.org/release/2.3/pjproject-2.3.tar.bz2'
  sha1 '42743b36d758fb0c7656a4b5f041d086efbcb587'

  keg_only "Specifically tuned just for asterisk"

  depends_on 'libgsm'
  depends_on 'openssl'
  depends_on 'portaudio'
  depends_on 'speex'
  depends_on 'srtp'

  def install
    ENV.j1

    openssl = Formula.factory('openssl')

    # Hack to truly disable opencore
    ENV['enable_opencore_amr'] = 'no'
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
