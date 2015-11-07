require 'httpclient'
client = HTTPClient.new
client.get("https://www.ruby-lang.org/en/").status

=begin
% ruby a1.rb
ok: "/C=BE/O=GlobalSign nv-sa/OU=Root CA/CN=GlobalSign Root CA"
ok: "/C=BE/O=GlobalSign nv-sa/CN=GlobalSign Domain Validation CA - SHA256 - G2"
ok: "/OU=Domain Control Validated/CN=*.ruby-lang.org"
Protocol version: TLSv1.2
Cipher: ["ECDHE-RSA-AES128-GCM-SHA256", "TLSv1/SSLv3", 128, 128]
State: SSLOK : SSL negotiation finished successfully
=end
