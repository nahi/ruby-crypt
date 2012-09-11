require 'openssl'

# load PUBLIC key
pubkey = OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))

# encryption
# CAUTION: ARGF must be shorter than key size!
print pubkey.public_encrypt(ARGF.read)
