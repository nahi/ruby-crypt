require 'openssl'

# load PUBLIC key
pubkey = OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))

# load text and sig
plain = File.binread("../alice_sign/plain.txt")
sig = File.binread("../alice_sign/plain.sig.bin")

# verify
digester = OpenSSL::Digest::SHA1.new
if pubkey.verify(digester, sig, plain)
  puts 'authentication succeeded'
  puts plain
else
  raise 'authentication failed'
end
