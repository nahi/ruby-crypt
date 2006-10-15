require 'openssl'

puts 'create 256 bit random key for AES'
key = OpenSSL::Random.random_bytes(256/8)

File.open("seckey.bin", "wb") do |file|
  file << key
end
puts 'wrote seckey.bin'
