require 'openssl'

sigfile = ARGV.shift or raise 'sigfile not given'

# load key
privkey =
  OpenSSL::PKey::RSA.new(File.read("privkey.pem"))

File.open(sigfile + ".sig", "wb") do |w|
  digester = OpenSSL::Digest::SHA256.new
  w << privkey.sign(digester, File.read(sigfile))
end
puts "wrote #{sigfile}.sig (self generated signature)"
