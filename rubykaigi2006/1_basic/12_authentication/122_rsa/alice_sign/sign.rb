require 'openssl'

# load text to be signed
plain = ARGF.read

# load PRIVATE key
key = OpenSSL::PKey::RSA.new(File.read("privkey.pem"))

# sign
# CAUTION: digester must be an instance of
#   ::OpenSSL::Digest::* not ::Digest::* even if
#   openssl is loaded.
digester = OpenSSL::Digest::SHA1.new
sig = key.sign(digester, plain)

File.open("plain.txt", "wb") do |file|
  file << plain
end
puts 'wrote text to plain.txt'

File.open("plain.sig.bin", "wb") do |file|
  file << sig
end
puts 'wrote sign to plain.sig.bin'
