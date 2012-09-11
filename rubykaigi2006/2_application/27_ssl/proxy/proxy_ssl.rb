require 'socket'
require 'openssl'
require '../sslsocket_fix'

class ProxySsl
  def initialize
    @clientcert = OpenSSL::X509::Certificate.new(File::read("clientcert.pem"))
    @clientprivkey = OpenSSL::PKey::RSA.new(File::read("privkey.pem"))
    @ca_file = '../ca/cacert.pem'
    @crl_file = '../ca/crl/ctor.pem'
    @ciphers = 'ALL:!ADH:!LOW:!EXP:!MD5:@STRENGTH'
  end

  def evaluate(source)
    ctx = create_sslcontext
    # SSL
    sock = TCPSocket.new("localhost", 1234)
    ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    ssl.connect
    ssl.sync_close = true
    ssl << Marshal.dump(source)
    Marshal.load(ssl)
  ensure
    ssl.close if ssl
  end

private

  def create_sslcontext
    # initialize store
    store = OpenSSL::X509::Store.new
    store.add_file(@ca_file)
    store.add_crl(
      OpenSSL::X509::CRL.new(File.read(@crl_file)))
    store.flags = OpenSSL::X509::V_FLAG_CRL_CHECK | OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
    # initialize SSL context
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.cert_store = store
    ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    ctx.cert = @clientcert
    ctx.key = @clientprivkey
    ctx.options = OpenSSL::SSL::OP_NO_SSLv2
    ctx.ciphers = @ciphers
    ctx
  end
end

if __FILE__ == $0
  host = ProxySsl.new
  source = '("hello " + "world!").reverse'
  p host.evaluate(source)
end
