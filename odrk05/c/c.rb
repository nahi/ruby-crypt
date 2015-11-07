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
basic_auth = WEBrick::HTTPAuth::BasicAuth.new(
  Logger: logger,
  Realm: 'auth',
  UserDB: WEBrick::HTTPAuth::Htpasswd.new('htpasswd')
)
server.mount("/hello",
  WEBrick::HTTPServlet::ProcHandler.new(->(req, res) {
    basic_auth.authenticate(req, res)
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
t.join
