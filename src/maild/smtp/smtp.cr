class Maild::SMTP < Maild::Handler
  property identity :: String
  property from :: String
  property to :: Array(String)

  def handle(sock : TCPSocket)
    info "New client"
    greet sock
    sock.read_timeout = 30.seconds
    begin
      sock.each_line do |line|
        args = line.chomp.split ' '
        cmd = args.shift.upcase
        info "#{cmd} from #{sock.peeraddr.ip_address}:#{sock.peeraddr.ip_port}"
        handle sock, cmd, args
        break if sock.closed?
      end
    rescue IO::Timeout
      info "Connection timed out"
      sock.puts "421 timed out"
    rescue ex
      info "Connection terminated unexpectedly: #{ex.inspect}"
    end
    info "Closed"
  end

  def self.method_missing(sock, cmd)
    sock.puts "504 not implemented"
    error "#{cmd.upcase.inspect} requested but not implemented (available: #{@@handlers.try &.keys.join ", "})"
  end

  def self.argument_missing(sock, arg)
    sock.puts "501 argument missing: #{arg}"
  end

  private def greet(sock)
    sock.puts "220 maild ESMTP server ready"
  end

  handle "noop" do |sock|
    sock.puts "250 no operation performed"
  end

  handle "quit" do |sock|
    sock.puts "221 maild ESMTP server closing connection"
    sock.close
  end

  handle "ehlo" do |sock, args|
    @identity = requires args[0] as String
    capabilities = [
      "greetings, #{identity}!",
      "8BITMIME"
    ]
    capabilities.each_with_index do |capability, i|
      sock.puts "250#{i == capabilities.length-1 ? '-' : ' '}#{capability}"
    end
  end
end
