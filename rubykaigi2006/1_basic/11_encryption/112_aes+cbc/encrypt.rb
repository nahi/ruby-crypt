require 'openssl'

# load SECRET key
key = File.binread("seckey.bin")

# create AES engine
# 128/192/256 must match key length (bits)
cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

# create IV(initial vector)
# 16 bytes == 128 bits is a block length
# AES is a 128 bit block cipher
iv = OpenSSL::Random.random_bytes(16)

# initialize
cipher.encrypt
cipher.key = key
cipher.iv = iv

# iv is needed for decryption
print iv

# encryption
print cipher.update(ARGF.binread) + cipher.final
