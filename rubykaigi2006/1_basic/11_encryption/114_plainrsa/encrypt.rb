require 'openssl'

# it's just a proof of concept

# RSA public key calculation
# c = m ^ e (mod n)
def rsa_public(input, n, e)
  input_bn = OpenSSL::BN.new(input.to_s)
  n_bn = OpenSSL::BN.new(n.to_s)
  e_bn = OpenSSL::BN.new(e.to_s)
  (input_bn.mod_exp(e_bn, n_bn)).to_i
end

# RSA private key calculation
# s = m ^ d (mod n)
def rsa_private(input, n, d)
  input_bn = OpenSSL::BN.new(input.to_s)
  n_bn = OpenSSL::BN.new(n.to_s)
  d_bn = OpenSSL::BN.new(d.to_s)
  (input_bn.mod_exp(d_bn, n_bn)).to_i
end

# test key
e = 3
d = 7
n = 33

# encryption and decryption sample
plain = 13
p ['plain', plain]

# sender knows n and e (PUBLIC key)
cipher = rsa_public(plain, n, e)
p ['cipher', cipher]

# receiver knows n and d (PRIVATE key)
decrypted = rsa_private(cipher, n, d)
p ['decrypted', decrypted]
