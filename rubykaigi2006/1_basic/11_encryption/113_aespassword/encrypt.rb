require 'openssl'

# load password
password = File.binread("password.txt")

# create AES engine
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

# create salt; must be 8 bytes
salt = OpenSSL::Random.random_bytes(8)

# initialize
cipher.encrypt
# calc key and IV from password and salt
cipher.pkcs5_keyivgen(password, salt)

# salt is needed for key
print salt

# encryption
print cipher.update(ARGF.read) + cipher.final
