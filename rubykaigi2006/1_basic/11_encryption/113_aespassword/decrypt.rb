require 'openssl'

# load password
password = File.binread("password.txt")

# create AES engine
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

# salt is needed for key
salt = ARGF.read(8)

# initialize
cipher.decrypt
# calc key and IV from password
cipher.pkcs5_keyivgen(password, salt)

# decryption
print cipher.update(ARGF.read) + cipher.final
