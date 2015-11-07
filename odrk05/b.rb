require 'httpclient'
client = HTTPClient.new
p client.get("https://test-sspev.verisign.com:2443/test-SSPEV-revoked-verisign.html").status

=begin
% ruby b.rb
200
% jruby b.rb
200
% jruby -J-Dcom.sun.security.enableCRLDP=true -J-Dcom.sun.net.ssl.checkRevocation=true b.rb
OpenSSL::SSL::SSLError:
  sun.security.validator.ValidatorException:
    PKIX path validation failed:
      java.security.cert.CertPathValidatorException: Certificate has been revoked,
          reason: UNSPECIFIED,
          revocation date: Thu Oct 30 06:29:37 JST 2014,
          authority: CN=Symantec Class 3 EV SSL CA - G3, OU=Symantec Trust Network, O=Symantec Corporation, C=US,
          extensions: {}
=end
