require 'openssl'

STDOUT.sync = true
puts 'creating 1024 bits DSA keypair...'
key = OpenSSL::PKey::DSA.new(1024) { print '.' }
puts 'done'

File.open("privkey.pem", "w") do |w|
  w << key.to_pem
end
puts 'wrote privkey.pem'

File.open("pubkey.pem", "w") do |w|
  w << key.public_key.to_pem
end
puts 'wrote pubkey.pem'
