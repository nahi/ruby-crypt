#!/usr/bin/env ruby

require 'openssl'
require 'ca_config'
require 'getopts'

include OpenSSL

def usage
  myname = File::basename($0)
  $stderr.puts 
  $stderr.puts "Warning: You're publishing empty CRL."
  $stderr.puts "For revoking certificates use it like this:"
  $stderr.puts "\t$ #{myname} Cert_to_revoke1.pem*"
  $stderr.puts 
end

ARGV.empty? && usage()

# CA setup

ca_file = CAConfig::CERT_FILE
puts "Reading CA cert (from #{ca_file})"
ca = X509::Certificate.new(File.read(ca_file))

ca_keypair_file = CAConfig::KEYPAIR_FILE
puts "Reading CA keypair (from #{ca_keypair_file})"
ca_keypair = PKey::RSA.new(File.read(ca_keypair_file), &CAConfig::PASSWD_CB)

# CRL setting

crl = if FileTest.exist?(CAConfig::CRL_FILE)
    X509::CRL.new(File.read(CAConfig::CRL_FILE))
  else
    X509::CRL.new
  end

now = Time.now
crl.issuer = ca.subject
crl.last_update = now
crl.next_update = now + CAConfig::CRL_DAYS * 24 * 60 * 60

ARGV.each do |file|
  cert = X509::Certificate.new(File.read(file))
  re = X509::Revoked.new
  re.serial = cert.serial
  re.time = now
  crl.add_revoked(re)
  puts "+ Serial ##{re.serial} - revoked at #{re.time}"
end

crl.sign(ca_keypair, Digest::SHA1.new)

puts "Writing #{CAConfig::CRL_FILE}."
File.open(CAConfig::CRL_FILE, "w") do |f|
  f << crl.to_der
end
File.open(CAConfig::CRL_PEM_FILE, "w") do |f|
  f << crl.to_pem
end

puts "DONE. (Generated CRL for '#{ca.subject}')"
