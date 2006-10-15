require 'openssl'

# load text to be signed
plain = ARGF.read

# load PRIVATE key
privkey =
  OpenSSL::PKey::DSA.new(File.read("privkey.pem"))

# sign
sig = privkey.sign(OpenSSL::Digest::DSS1.new, plain)

File.open("plain.txt", "wb") do |file|
  file << plain
end
puts 'wrote text to plain.txt'

File.open("plain.sig.bin", "wb") do |file|
  file << sig
end
puts 'wrote sign to plain.sig.bin'
