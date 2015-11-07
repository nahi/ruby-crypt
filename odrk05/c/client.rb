require 'httpclient'
client = HTTPClient.new {
  self.ssl_config.add_trust_ca("ca.cert")
  self.set_basic_auth(nil, "admin", "admin")
}
p client.get_content("https://localhost:17443/hello")

