require 'pgp/packet'
include PGP
include Packet

# load PUBLIC key packet
pubkey = userid = pubsig = nil
Packet.load(File.read('pubkey.asc')).each do |packet|
  case packet
  when PublicKey
    pubkey = packet
  when UserID
    userid = packet
  when Signature
    pubsig = packet
  else
    raise "unknown format"
  end
end
if !pubkey.nil? and !userid.nil?
  puts "loaded pubkey of '#{userid.userid}'"
end

# load text
plain = File.read('plain.txt')

# find signature packet
packets = Packet.load(File.read('plain.txt.asc'))
signature = packets.find { |packet|
  Signature === packet
}

# verify
if signature.verify(pubkey, plain)
  puts 'verifycation succeeded'
  puts plain
else
  raise 'verifycation failed'
end
