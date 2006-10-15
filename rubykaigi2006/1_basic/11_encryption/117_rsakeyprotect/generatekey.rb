require 'openssl'

STDOUT.sync = true
puts 'creating 2048 bits RSA keypair...'
key = OpenSSL::PKey::RSA.new(2048) { print "." }
puts 'done'

File.open("privkey.pem", "w") do |file|
  # protect key with a password
  protectedkey = key.export(OpenSSL::Cipher::Cipher.new("AES-256-CBC"))

  # for protecting with a given password
  #   protectedkey = key.export(
  #     OpenSSL::Cipher::Cipher.new("AES-256-CBC"),
  #     "my password")

  # for custom password callback:
  #   require 'password_callback'
  #   protectedkey = key.export(
  #     OpenSSL::Cipher::Cipher.new("AES-256-CBC"),
  #     &PasswordCallback)

  file << protectedkey
end
puts 'wrote privkey.pem with password protection'

File.open("pubkey.pem", "w") do |file|
  file << key.public_key.to_pem
end
puts 'wrote pubkey.pem'
