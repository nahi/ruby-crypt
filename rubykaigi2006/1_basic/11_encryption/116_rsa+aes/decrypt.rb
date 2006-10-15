require 'openssl'

# load encrypted password and encrypted text
cipherpassword, ciphertext =
  Marshal.load(ARGF), Marshal.load(ARGF)

# decrypt password with RSA
privkey =
  OpenSSL::PKey::RSA.new(File.read("privkey.pem"))
password = privkey.private_decrypt(cipherpassword)

# decrypt password with AES
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
cipher.decrypt
cipher.pkcs5_keyivgen(password)

# dump
print cipher.update(ciphertext) + cipher.final
