require 'openssl'

# load SECRET key
key = File.binread("seckey.bin")

# create AES engine
# 128/192/256 must match key length (bits)
cipher = OpenSSL::Cipher::Cipher.new("AES-128-ECB")

# initialize
cipher.encrypt
cipher.key = key

# encryption
print cipher.update(ARGF.read) + cipher.final
