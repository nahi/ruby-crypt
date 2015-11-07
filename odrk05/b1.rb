require 'httpclient'
client = HTTPClient.new
client.ssl_config.ssl_version = :TLSv1
client.get("https://doc.rust-lang.org/").status

=begin
% ruby b1.rb
Connection reset by peer - SSL_connect (Errno::ECONNRESET)
SSL_connect returned=1 errno=0 state=SSLv3 read server hello A: wrong version number (OpenSSL::SSL::SSLError)
=end
