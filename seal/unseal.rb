require 'openssl'

wrapped = File.read('wrapped.bin')
cipher_text = File.read('data.bin')

privkey = OpenSSL::PKey::RSA.new(File.read('privkey.pem'))
key = privkey.private_decrypt(wrapped)

cipher = OpenSSL::Cipher.new('rc4')
cipher.decrypt
cipher.key = key

p cipher.update(cipher_text) + cipher.final
