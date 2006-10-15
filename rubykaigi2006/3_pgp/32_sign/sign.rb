require 'pgp/packet'
require 'pgp/armor'

include PGP
include Packet

# load PRIVATE key packet
packets = Packet.load(File.read('privkey.asc'))
privkey = packets.find { |packet|
  SecretKey === packet
}

# load PUBLIC key packet for keyid
packets = Packet.load(File.read('pubkey.asc'))
pubkey = packets.find { |packet|
  PublicKey === packet
}

# load text
plain = File.read('plain.txt')

# sign
signature = Signature.new(0x0, 1, 2)
signature.target = plain
signature.secretkey = privkey
signature.hashedsubpacket <<
  SigSubPacket::CreationTime.new(Time.new)
signature.unhashedsubpacket <<
  SigSubPacket::IssuerKeyID.new(pubkey.keyid)

armor = Armor.new(signature.dump)
armor.type = :SIGNATURE
File.open('plain.txt.asc', 'w') do |file|
  file << armor.dump
end
puts 'wrote plain.txt.asc'
