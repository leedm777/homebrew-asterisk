require 'formula'

class Iksemel < Formula
  homepage 'http://code.google.com/p/iksemel/'
  url 'http://iksemel.googlecode.com/files/iksemel-1.4.tar.gz'
  sha1 '722910b99ce794fd3f6f0e5f33fa804732cf46db'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "false"
  end
end
