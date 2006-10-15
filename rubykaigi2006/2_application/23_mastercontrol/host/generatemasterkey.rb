require 'openssl'

STDOUT.sync = true
puts 'creating 2048 bits RSA keypair...'
key = OpenSSL::PKey::RSA.new(2048) { print "." }
puts 'done'

File.open("masterprivkey.pem", "w") do |w|
  w << key.to_pem
end
puts 'wrote masterprivkey.pem'

File.open("masterpubkey.pem", "w") do |w|
  w << key.public_key.to_pem
end
puts 'wrote masterpubkey.pem'
