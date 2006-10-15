require 'openssl'

sigfile = ARGV.shift or raise 'sigfile not given'

masterprivkey = OpenSSL::PKey::RSA.new(
  File.read("masterprivkey.pem"))

File.open(sigfile + ".sig", "wb") do |w|
  digester = OpenSSL::Digest::SHA256.new
  w << masterprivkey.sign(digester, File.read(sigfile))
end
puts "wrote #{sigfile}.sig"
