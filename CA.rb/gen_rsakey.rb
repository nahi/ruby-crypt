#!/usr/bin/env ruby

require 'openssl'

include OpenSSL

$stdout.sync = true

keypair_file = ARGV.shift || 'keypair.pem'

PASSWD_CB = Proc.new { |flag|
  print "Enter password: "
  pass = $stdin.gets.chop!
  # when the flag is true, this passphrase
  # will be used to perform encryption; otherwise it will
  # be used to perform decryption.
  if flag
    print "Verify password: "
    pass2 = $stdin.gets.chop!
    raise "verify failed." if pass != pass2
  end
  pass
}

print "Generating CA keypair: "
keypair = PKey::RSA.new(2048) { putc "." }
putc "\n"
puts "Writing keypair."
File.open(keypair_file, "w", 0400) do |f|
  f << keypair.export(Cipher::DES.new(:EDE3, :CBC), &PASSWD_CB)
end
