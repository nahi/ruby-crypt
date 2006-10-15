require 'openssl'

# load SECRET key
key = File.read("seckey.bin")

# create AES engine
cipher = OpenSSL::Cipher::Cipher.new("AES-128-ECB")

# initialize
cipher.decrypt
cipher.key = key

# decryption
print cipher.update(ARGF.read) + cipher.final
