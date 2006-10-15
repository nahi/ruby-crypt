require 'openssl'

# load password
password = File.read("password.txt")

# create AES engine
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

# initialize
cipher.decrypt
# calc key and IV from password
cipher.pkcs5_keyivgen(password)

# decryption
print cipher.update(ARGF.read) + cipher.final
