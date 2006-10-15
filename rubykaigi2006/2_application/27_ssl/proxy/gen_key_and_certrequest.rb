#!/usr/bin/env ruby

require 'openssl'

include OpenSSL

def usage
  myname = File::basename($0)
  $stderr.puts <<EOS
Usage: #{myname} name
  name ... ex. /C=org/O=ctor/OU=development/CN=NaHi
EOS
  exit
end

csrout = "csr.pem"
keyout = "privkey.pem"

$stdout.sync = true
name_str = ARGV.shift or usage()
name = X509::Name.parse(name_str)

keypair = PKey::RSA.new(1024) { putc "." }
puts
puts "Writing #{keyout}..."
File.open(keyout, "w", 0400) do |f|
  f << keypair.to_pem
end

puts "Generating CSR for #{name_str}"

req = X509::Request.new
req.version = 0
req.subject = name
req.public_key = keypair.public_key
req.sign(keypair, Digest::MD5.new)

puts "Writing #{csrout}..."
File.open(csrout, "w") do |f|
  f << req.to_pem
end
