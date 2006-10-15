require 'webrick'
require 'openssl'
require 'logger'

class HostCheck
  def initialize
    @pubkey =
      OpenSSL::PKey::RSA.new(File.read("pubkey.pem"))
    @digester = OpenSSL::Digest::SHA256.new
    @name = 'Alice'

    @logger = Logger.new(STDERR)
    @server = WEBrick::GenericServer.new(
      :Port => 1234, :Logger => @logger)
  end

  def start
    @server.start do |sock|
      begin
        # receive
        sig = sock.gets.unpack("m*")[0]
        source = sock.read
        sock.close_read
        # verify and eval
        if verify(@name + source, sig)
          # send the result as a String
          sock << eval(source).to_s
        end
      ensure
        sock.close
      end
    end
  end

  def shutdown
    @server.shutdown
  end

private

  def verify(source, sig)
    unless @pubkey.verify(@digester, sig, source)
      @logger.warn { 'verification failed' }
      return false
    end
    @logger.info { 'verification succeeded' }
    true
  end
end

if __FILE__ == $0
  server = HostCheck.new
  trap(:INT) do
    server.shutdown
  end
  server.start
end
