require 'socket'
require 'openssl'
require '../marshallablersakey'

class ProxyEncrypt
  def initialize
    @masterpubkey = OpenSSL::PKey::RSA.new(
      File.read("masterpubkey.pem"))
    @pubkey =
      OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))
    @pubsig = File.read("pubkey.pem.sig")
    @signkey =
      OpenSSL::PKey::RSA.new(File.read("privkey.pem"))
    @secretcipher =
      OpenSSL::Cipher::Cipher.new("AES-256-CBC")
  end

  def evaluate(source)
    # open connection
    sock = TCPSocket.new("localhost", 1234)
    # read nonce
    nonce = Marshal.load(sock)
    # sign source with nonce
    digester = OpenSSL::Digest::SHA256.new
    sig = @signkey.sign(digester, nonce + source)
    # encrypt
    ciphertext, cipherkey = encrypt(source)
    # send
    sock << Marshal.dump(@pubkey)
    sock << Marshal.dump(@pubsig)
    sock << Marshal.dump(ciphertext)
    sock << Marshal.dump(cipherkey)
    sock << Marshal.dump(sig)
    sock.close_write
    # receive
    auth = Marshal.load(sock)
    result = Marshal.load(sock)
    [auth, result]
  ensure
    sock.close if sock
  end

private

  def encrypt(source)
    keysource = OpenSSL::Random.random_bytes(16)
    @secretcipher.encrypt
    @secretcipher.pkcs5_keyivgen(keysource)
    ciphertext = @secretcipher.update(source) +
      @secretcipher.final
    cipherkey = @masterpubkey.public_encrypt(keysource)
    [ciphertext, cipherkey]
  end
end

if __FILE__ == $0
  host = ProxyEncrypt.new
  source = '("hello " + "world!").reverse'
  p host.evaluate(source)
end
