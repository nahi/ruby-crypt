require 'webrick'
require 'openssl'
require 'logger'
require '../marshallablersakey'

class HostNgList
  def initialize
    @masterpubkey = OpenSSL::PKey::RSA.new(
      File.read("masterpubkey.pem"))
    @digester = OpenSSL::Digest::SHA256.new
    @nglist = File.open("nglist.txt").collect { |line|
      line.chomp
    }

    @logger = Logger.new(STDERR)
    @server = WEBrick::GenericServer.new(
      :Port => 1234, :Logger => @logger)
  end

  def start
    @server.start do |sock|
      auth = false
      result = nil
      begin
        # receive
        pubkey = Marshal.load(sock)
        pubsig = Marshal.load(sock)
        source = Marshal.load(sock)
        sourcesig = Marshal.load(sock)
        sock.close_read
        # verify
        auth = verify(pubkey, pubsig, source, sourcesig)
        # eval
        result = eval(source) if auth
      ensure
        sock.write(Marshal.dump(auth))
        sock.write(Marshal.dump(result))
        sock.close
      end
    end
  end

  def shutdown
    @server.shutdown
  end

private

  def verify(pubkey, pubsig, source, sourcesig)
    unless @masterpubkey.verify(@digester, pubsig, pubkey.to_pem)
      @logger.warn('masterpubkey verification failed')
      return false
    end
    unless pubkey.verify(@digester, sourcesig, source)
      @logger.warn('pubkey verification failed')
      return false
    end
    if @nglist.include?(pubkey.n.to_s)
      @logger.warn('nglist include the key')
      return false
    end
    @logger.info('verification succeeded')
    true
  end
end

if __FILE__ == $0
  server = HostNgList.new
  trap(:INT) do
    server.shutdown
  end
  server.start
end
