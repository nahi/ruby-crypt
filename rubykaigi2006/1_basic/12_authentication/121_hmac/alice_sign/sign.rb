require 'openssl'

# load text to be signed
plain = ARGF.read

# load SECRET key
key = File.binread("seckey.bin")

# sign
digester = OpenSSL::Digest::SHA1.new
sig = OpenSSL::HMAC.digest(digester, key, plain)

File.open("plain.txt", "wb") do |file|
  file << plain
end
puts 'wrote text to plain.txt'

File.open("plain.sig.bin", "wb") do |file|
  file << sig
end
puts 'wrote sign to plain.sig.bin'
