require 'webrick/https'
require 'logger'

logger = Logger.new(STDERR)

server = WEBrick::HTTPServer.new(
  BindAddress: "localhost",
  Logger: logger,
  Port: 17443,
  DocumentRoot: '/dev/null',
  SSLEnable: true,
  SSLCACertificateFile: 'cert/ca-chain.cert',
  SSLCertificate: OpenSSL::X509::Certificate.new(File.read('cert/server.cert')),
  SSLPrivateKey: OpenSSL::PKey::RSA.new(File.read('cert/server.key')),
)
server.ssl_context.ssl_version = :TLSv1
server.mount("/hello",
  WEBrick::HTTPServlet::ProcHandler.new(->(req, res) {
    res['content-type'] = 'text/plain'
    res.body = "hello"
  })
)
trap(:INT) do
  server.shutdown
end

t = Thread.new {
  Thread.current.abort_on_exception = true
  server.start
}
while server.status != :Running
  sleep 0.1
  raise unless t.alive?
end
puts $$

require 'httpclient'
client = HTTPClient.new
client.ssl_config.add_trust_ca('cert/ca.cert')
client.ssl_config.ssl_version = :TLSv1_2
client.get("https://localhost:17443/").status

=begin
% ruby a3.rb
SSL_connect returned=1 errno=0 state=SSLv3 read server hello A: wrong version number (OpenSSL::SSL::SSLError)
=end
