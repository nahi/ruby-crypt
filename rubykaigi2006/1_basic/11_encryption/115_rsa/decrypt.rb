require 'openssl'

# load PRIVATE key
privkey =
  OpenSSL::PKey::RSA.new(File.read("privkey.pem"))

# decryption
print privkey.private_decrypt(ARGF.read)
