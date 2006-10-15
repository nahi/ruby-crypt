require 'socket'
require 'openssl'
require '../marshallablersakey'

class ProxyMasterControl
  def initialize
    @pubkey =
      OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))
    @pubsig = File.read("pubkey.pem.sig")
    @signkey =
      OpenSSL::PKey::RSA.new(File.read("privkey.pem"))
  end

  def evaluate(source)
    # calc signature
    digester = OpenSSL::Digest::SHA256.new
    sig = @signkey.sign(digester, source)
    # open connection
    sock = TCPSocket.new("localhost", 1234)
    # send 
    sock << Marshal.dump(@pubkey)
    sock << Marshal.dump(@pubsig)
    sock << Marshal.dump(source)
    sock << Marshal.dump(sig)
    sock.close_write
    # receive
    auth = Marshal.load(sock)
    result = Marshal.load(sock)
    [auth, result]
  ensure
    sock.close if sock
  end
end

if __FILE__ == $0
  host = ProxyMasterControl.new
  source = '("hello " + "world!").reverse'
  p host.evaluate(source)
end
