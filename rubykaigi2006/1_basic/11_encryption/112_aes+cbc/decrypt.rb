require 'openssl'

# load SECRET key
key = File.binread("seckey.bin")

# create AES engine
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

# load iv from the begining of cipher
iv = ARGF.read(16)

# initialize
cipher.decrypt
cipher.key = key
cipher.iv = iv

# decryption
print cipher.update(ARGF.read) + cipher.final
