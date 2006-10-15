require 'openssl'

# load SECRET key
key = File.read("seckey.bin")

# load text and sig
plain = File.read("plain.txt")
sig = File.read("plain.sig.bin")

# self sign calculation
digester = OpenSSL::Digest::SHA1.new
calsig = OpenSSL::HMAC.digest(digester, key, plain)

# and check
if sig == calsig
  puts 'authentication succeeded'
  puts plain
else
  raise 'authentication failed'
end
