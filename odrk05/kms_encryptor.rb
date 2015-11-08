require 'aws-sdk'

class KMSEncryptor
  CTX = { 'purpose' => 'odrk05 demonstration' }
  GCM_IV_SIZE = 12
  GCM_TAG_SIZE = 16

  def initialize(region, key_id)
    @region, @key_id = region, key_id
    @kms = Aws::KMS::Client.new(region: @region)
  end

  def generate_data_key
    resp = @kms.generate_data_key_without_plaintext(
      key_id: @key_id,
      encryption_context: CTX,
      key_spec: 'AES_128'
    )
    resp.ciphertext_blob
  end

  def with_key(wrapped_key)
    key = nil
    begin
      key = @kms.decrypt(
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
      cipher = OpenSSL::Cipher::Cipher.new('aes-128-gcm')
      iv = OpenSSL::Random.random_bytes(GCM_IV_SIZE)
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv
      ciphertext = cipher.update(plaintext) + cipher.final
      iv + ciphertext + cipher.auth_tag
    end
  end

  def decrypt(wrapped_key, ciphertext)
    with_key(wrapped_key) do |key|
      iv, data = ciphertext.unpack("a#{GCM_IV_SIZE}a*")
      auth_tag = data.slice!(data.bytesize - GCM_TAG_SIZE, GCM_TAG_SIZE)
      cipher = OpenSSL::Cipher::Cipher.new('aes-128-gcm')
      cipher.decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_tag = auth_tag
      cipher.update(data) + cipher.final
    end
  end
end

if defined?(JRuby)
  require 'java'
  java_import 'javax.crypto.Cipher'
  java_import 'javax.crypto.SecretKey'
  java_import 'javax.crypto.spec.SecretKeySpec'
  java_import 'javax.crypto.spec.GCMParameterSpec'

  class KMSEncryptor
    # Overrides
    def encrypt(wrapped_key, plaintext)
      with_key(wrapped_key) do |key|
        cipher = Cipher.getInstance('AES/GCM/PKCS5Padding')
        iv = OpenSSL::Random.random_bytes(GCM_IV_SIZE)
        spec = GCMParameterSpec.new(GCM_TAG_SIZE * 8, iv.to_java_bytes)
        cipher.init(1, SecretKeySpec.new(key.to_java_bytes, 0, key.bytesize, 'AES'), spec)
        ciphertext = String.from_java_bytes(cipher.doFinal(plaintext.to_java_bytes), Encoding::BINARY)
        iv + ciphertext
      end
    end

    # Overrides
    def decrypt(wrapped_key, ciphertext)
      with_key(wrapped_key) do |key|
        cipher = Cipher.getInstance('AES/GCM/PKCS5Padding')
        iv, data = ciphertext.unpack("a#{GCM_IV_SIZE}a*")
        spec = GCMParameterSpec.new(GCM_TAG_SIZE * 8, iv.to_java_bytes)
        cipher.init(2, SecretKeySpec.new(key.to_java_bytes, 0, key.bytesize, 'AES'), spec)
        String.from_java_bytes(cipher.doFinal(data.to_java_bytes), Encoding::BINARY)
      end
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
