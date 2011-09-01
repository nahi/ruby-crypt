#!/usr/bin/env ruby

require 'openssl'
require 'ca_config'
require 'getopts'

include OpenSSL

$stdout.sync = true

cn = ARGV.shift || 'SubCA'

getopts nil, "csrout:"
csrout = $OPT_csrout || "csr.pem"

unless FileTest.exist?('private')
  Dir.mkdir('private', 0700)
end
unless FileTest.exist?('newcerts')
  Dir.mkdir('newcerts')
end
unless FileTest.exist?('crl')
  Dir.mkdir('crl')
end
unless FileTest.exist?('serial')
  File.open('serial', 'w') do |f|
    f << '2'
  end
end

print "Generating CA keypair: "
keypair = PKey::RSA.new(CAConfig::CA_RSA_KEY_LENGTH) { putc "." }
putc "\n"

keypair_file = CAConfig::KEYPAIR_FILE
puts "Writing keypair."
File.open(keypair_file, "w", 0400) do |f|
  f << keypair.export(Cipher::DES.new(:EDE3, :CBC), &CAConfig::PASSWD_CB)
end

name = CAConfig::NAME.dup << ['CN', cn]

puts "Generating CSR for #{name.inspect}"

req = X509::Request.new
req.subject = X509::Name.new(name)
req.public_key = keypair.public_key
req.sign(keypair, 'SHA1')

puts "Writing #{csrout}..."
File.open(csrout, "w") do |f|
  f << req.to_pem
end
