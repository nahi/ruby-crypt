require 'openssl'

# load PUBLIC key
pubkey =
  OpenSSL::PKey::DSA.new(File.read("pubkey.pem"))

# load text and sig
plain = File.read("plain.txt")
sig = File.read("plain.sig.bin")

# verify
if pubkey.verify(OpenSSL::Digest::DSS1.new, sig, plain)
  puts 'authentication succeeded'
  puts plain
else
  raise 'authentication failed'
end
