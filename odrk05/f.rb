require 'aws-sdk'

DEMO_CTX = {
  'purpose' => 'odrk05 demonstration'
}

def erase_key(key)
  # TODO: confirm that key is deleted from memory
  key.tr!("\0-\xff".force_encoding('BINARY'), "\0")
end

def encrypt(key_id, plaintext)
  # Create wrapping AES key
  kms = Aws::KMS::Client.new(region: 'us-east-1')
  resp = kms.generate_data_key(
    key_id: key_id,
    encryption_context: DEMO_CTX,
    key_spec: 'AES_128'
  )
  key = resp.plaintext
  wrapped_key = resp.ciphertext_blob

  cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
  iv = OpenSSL::Random.random_bytes(16)
  cipher.encrypt
  cipher.key = key
  cipher.iv = iv
  ciphertext = iv + cipher.update(plaintext) + cipher.final
  erase_key(key)
  return wrapped_key, ciphertext
end

def decrypt(wrapped_key, ciphertext)
  kms = Aws::KMS::Client.new(region: 'us-east-1')
  resp = kms.decrypt(
    ciphertext_blob: wrapped_key,
    encryption_context: DEMO_CTX
  )
  key = resp.plaintext

  iv, data = ciphertext.unpack('a16a*')
  cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
  cipher.decrypt
  cipher.key = key
  cipher.iv = iv

  plaintext = cipher.update(data) + cipher.final
  erase_key(key)
  plaintext
end

key_id = 'alias/nahi-test'
plaintext = File.read(__FILE__)

wrapped_key, ciphertext = encrypt(key_id, plaintext)
# save wrapped_key and ciphertext in DB, File or somewhere

# restore wrapped_key and ciphertext from DB, File or somewhere
puts decrypt(wrapped_key, ciphertext)
