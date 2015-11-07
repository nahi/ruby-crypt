require 'aws-sdk'

class KMSEncryptor
  CTX = { 'purpose' => 'odrk05 demonstration' }

  def initialize(region, key_id)
    @region, @key_id = region, key_id
  end

  def generate_data_key
    kms = Aws::KMS::Client.new(region: @region)
    resp = kms.generate_data_key_without_plaintext(
      key_id: @key_id,
      encryption_context: CTX,
      key_spec: 'AES_128'
    )
    resp.ciphertext_blob
  end

  def with_key(wrapped_key)
    kms = Aws::KMS::Client.new(region: @region)
    key = nil
    begin
      key = kms.decrypt(
        ciphertext_blob: wrapped_key,
        encryption_context: CTX
      ).plaintext
      yield key
    ensure
      # TODO: confirm that key is deleted from memory
      key.tr!("\0-\xff".force_encoding('BINARY'), "\0")
    end
  end

  def encrypt(wrapped_key, plaintext)
    with_key(wrapped_key) do |key|
      cipher = OpenSSL::Cipher::Cipher.new("AES-128-CTR")
      iv = OpenSSL::Random.random_bytes(16)
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv
      iv + cipher.update(plaintext) + cipher.final
    end
  end

  def decrypt(wrapped_key, ciphertext)
    with_key(wrapped_key) do |key|
      iv, data = ciphertext.unpack('a16a*')
      cipher = OpenSSL::Cipher::Cipher.new("AES-128-CTR")
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.update(data) + cipher.final
    end
  end
end

region = 'ap-northeast-1'
key_id = 'alias/nahi-test-tokyo'
encryptor = KMSEncryptor.new(region, key_id)

# generate key for each data, customer, or something
wrapped_key = encryptor.generate_data_key

plaintext = File.read(__FILE__)

ciphertext = encryptor.encrypt(wrapped_key, plaintext)
# save wrapped_key and ciphertext in DB, File or somewhere

# restore wrapped_key and ciphertext from DB, File or somewhere
puts encryptor.decrypt(wrapped_key, ciphertext)
