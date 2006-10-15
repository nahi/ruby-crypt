require 'openssl'

# create password for AES
password = OpenSSL::Random.random_bytes(16)

# encrypt source with AES
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
cipher.encrypt
cipher.pkcs5_keyivgen(password)
ciphertext =
  cipher.update(ARGF.read) + cipher.final

# encrypt password with RSA
pubkey =
  OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))
cipherpassword = pubkey.public_encrypt(password)

# dump
print Marshal.dump(cipherpassword) +
  Marshal.dump(ciphertext)
