class Iksemel < Formula
  desc "This is an XML parser library mainly designed for Jabber applications."
  homepage "https://github.com/meduketto/iksemel"
  url "https://iksemel.googlecode.com/files/iksemel-1.4.tar.gz"
  sha256 "458c1b8fb3349076a6cecf26c29db1d561315d84e16bfcfba419f327f502e244"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "false"
  end
end
