require 'openssl'

STDOUT.sync = true
puts 'creating 2048 bits RSA keypair...'
key = OpenSSL::PKey::RSA.new(2048) { print "." }
puts 'done'

File.open("privkey.pem", "w") do |file|
  file << key.to_pem
end
puts 'wrote privkey.pem'

File.open("pubkey.pem", "w") do |file|
  file << key.public_key.to_pem
end
puts 'wrote pubkey.pem'
