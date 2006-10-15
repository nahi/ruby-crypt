require 'socket'
require 'openssl'

class ProxyHostCheck
  def initialize
    @signkey =
      OpenSSL::PKey::RSA.new(File.read("privkey.pem"))
    @hostname = 'Alice'
  end

  def evaluate(source)
    # calc signature of @hostname + source
    digester = OpenSSL::Digest::SHA256.new
    sig = @signkey.sign(digester, @hostname + source)
    # open connection
    sock = TCPSocket.new("localhost", 1234)
    # send sig in a line
    sock << sig2line(sig)
    # send source
    sock << source
    sock.close_write
    # receive the result as a String
    sock.read
  ensure
    sock.close if sock
  end

private

  def sig2line(sig)
    [sig].pack("m*").tr("\n", '') << "\n"
  end
end

if __FILE__ == $0
  host = ProxyHostCheck.new
  source = '("hello " + "world!").reverse'
  p host.evaluate(source)
end
