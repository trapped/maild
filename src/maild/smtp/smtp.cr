class Maild::SMTP < Maild::Handler
  property identity :: String
  property sender :: String
  property recipients :: Array(String)
  property message :: String
  property messages :: Array(String)

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
      sock.close
    rescue ex
      info "Connection terminated unexpectedly: #{ex.inspect}"
    end
    info "Closed"
  end

  macro method_missing(cmd)
    (sock.puts "504 not implemented"; info "#{{{cmd}}} requested but not implemented")
  end

  macro argument_missing(arg)
    (sock.puts "501 argument missing: #{{{arg}}}"; nil)
  end

  private def greet(sock)
    sock.puts "220 maild ESMTP server ready"
  end

  def cmd_noop(sock, args)
    sock.puts "250 no operation performed"
  end

  macro def cmd_rset(sock, args) : Nil
    {% for var in @type.instance_vars %}
    @{{var.id}} = nil
    {% end %}
    sock.puts "250 session has been reset"
    nil
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
    must_not_have @sender
    args = args.map(&.split ':').flatten
    return argument_missing "sender address" if args.length < 2
    while arg = args.shift?
      case arg.downcase
      when "from"
        sender = args.shift? || return argument_missing "sender address"
        sender = sender[/<(.*)>/, 1]? || return sock.puts "501 malformatted address"
        @sender = sender if sender =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i || return sock.puts "553 invalid sender address"
        sock.puts "250 sender #{sender} ok"
      end
    end
    argument_missing "sender address" unless @sender
  end

  def cmd_rcpt(sock, args)
    must_have @identity
    must_have @sender
    args = args.map(&.split ':').flatten
    recipient = nil
    while arg = args.shift?
      case arg.downcase
      when "to"
        @recipients = Array(String).new unless @recipients
        recipient = args.shift? || return argument_missing "recipient address"
        recipient = recipient[/<(.*)>/, 1]? || return sock.puts "501 malformatted address"
        @recipients.not_nil! << recipient if recipient =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i || return sock.puts "553 invalid recipient address"
        sock.puts "250 recipient #{recipient} ok"
      end
    end
    argument_missing "recipient address" unless recipient
  end

  def cmd_data(sock, args)
    must_have @identity
    must_have @sender
    must_have @recipients
    must_not_have @message
    sock.puts "354 ok"
    @message = ""
    sock.each_line do |line|
      case line.chomp
      when "."
        @messages = Array(String).new unless @messages
        @messages.not_nil! << @message.not_nil!
        @message = nil
        @sender = nil
        @recipients = nil
        puts @messages.inspect
        return sock.puts "250 saved to disk"
      else
        @message = "#{message}#{line}"
      end
    end
  end
end
