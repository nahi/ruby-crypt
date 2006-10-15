require 'webrick/ssl'
require 'openssl'
require 'logger'

class HostSsl
  def initialize
    logger = Logger.new(STDERR)
    servercert = OpenSSL::X509::Certificate.new(
      File.read("servercert.pem"))
    serverprivkey = OpenSSL::PKey::RSA.new(
      File.read("privkey.pem"))
    ca_file = '../ca/cacert.pem'
    # CAUTION: crl_file is not reloaded until the
    #   next server startup
    crl_file = '../ca/crl/ctor.pem'

    store = OpenSSL::X509::Store.new
    store.add_file(ca_file)
    store.add_crl(
      OpenSSL::X509::CRL.new(File.read(crl_file)))
    store.flags = OpenSSL::X509::V_FLAG_CRL_CHECK |
      OpenSSL::X509::V_FLAG_CRL_CHECK_ALL

    @server = WEBrick::GenericServer.new(
      :X_SSLCertificateStoreCrlFile => crl_file,
      :X_SSLCertificateStoreFlags => OpenSSL::X509::V_FLAG_CRL_CHECK | OpenSSL::X509::V_FLAG_CRL_CHECK_ALL,
      :SSLEnable => true,
      :SSLCertificate => servercert,
      :SSLPrivateKey => serverprivkey,
      :SSLCertificateStore => store,
      :SSLVerifyClient => OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT,
      :SSLOptions => OpenSSL::SSL::OP_NO_SSLv2,
      :Port => 1234,
      :Logger => logger
    )
  end

  def start
    @server.start do |sock|
      begin
        source = Marshal.load(sock)
        sock << Marshal.dump(eval(source))
      ensure
        sock.close
      end
    end
  end

  def shutdown
    @server.shutdown
  end
end

if __FILE__ == $0
  server = HostSsl.new
  trap(:INT) do
    server.shutdown
  end
  server.start
end
