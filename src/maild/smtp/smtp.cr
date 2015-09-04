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

  def method_missing(sock, cmd)
    sock.puts "504 not implemented"
    error "#{cmd.upcase.inspect} requested but not implemented"
  end

  def argument_missing(sock, arg)
    sock.puts "501 argument missing: #{arg}"
  end

  private def greet(sock)
    sock.puts "220 maild ESMTP server ready"
  end

  def cmd_noop(sock, args)
    sock.puts "250 no operation performed"
  end

  def cmd_rset(sock, args)
    {% for var in @type.instance_vars %}
    {{var.id}} = nil
    {% end %}
    sock.puts "250 session has been reset"
  end

  def cmd_quit(sock, args)
    sock.puts "221 maild ESMTP server closing connection"
    sock.close
  end

  def cmd_ehlo(sock, args)
    must_not_have @identity
    @identity = required "identity", args[0]?
    capabilities = [
      "greetings, #{identity}!",
      "8BITMIME", # strings are UTF8 by default
      "PIPELINING" # receive buffer is not flushed on failure
    ]
    capabilities.each_with_index do |capability, i|
      sock.puts "250#{i == capabilities.length-1 ? ' ' : '-'}#{capability}"
    end
  end

  def cmd_helo(sock, args)
    must_not_have @identity
    @identity = required "identity", args[0]?
    sock.puts "250 greetings, #{identity}!"
  end

  def cmd_mail(sock, args)
    must_have @identity
    must_not_have @from
    while arg = args.shift?
      case arg.downcase
      when "from:"
        from = args.shift? || return argument_missing sock, "sender address"
        @from = from if from =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i || return sock.puts "553 invalid sender address"
      end
    end
    sock.puts "250 sender #{@from} ok"
  end
end
