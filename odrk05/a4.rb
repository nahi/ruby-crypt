require 'net/https'

class NetHTTPClient < Net::HTTP
  require 'httpclient'

  def do_start
    # verify callback that dumps certificates
    if $DEBUG && @use_ssl
      self.verify_callback = HTTPClient::SSLConfig.new(nil).method(:default_verify_callback)
    end
    super
  end

  def on_connect
    if $DEBUG && @use_ssl
      ssl_socket = @socket.io
      if ssl_socket.respond_to?(:ssl_version)
        warn("Protocol version: #{ssl_socket.ssl_version}")
      end
      warn("Cipher: #{ssl_socket.cipher.inspect}")
      warn("State: #{ssl_socket.state}")
    end
  end
end

client = NetHTTPClient.new("www.ruby-lang.org", 443)
client.use_ssl = true
client.cert_store = store = OpenSSL::X509::Store.new
store.set_default_paths

client.get("/")
