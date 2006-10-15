require 'openssl'

puts 'create 128 bit random key for AES'
key = OpenSSL::Random.random_bytes(128/8)

File.open("seckey.bin", "wb") do |file|
  file << key
end
puts 'wrote seckey.bin'
