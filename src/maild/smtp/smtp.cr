class Maild::SMTP < Maild::Handler
  def parse(cmd : String)
    return cmd.chomp.split ' '
  end

  def handle(sock : TCPSocket)
    info "New client"
    greet sock
    begin
      sock.each_line do |line|
        cmd = parse line
        handle sock, cmd.shift.upcase, cmd
      end
    rescue
      info "Connection terminated unexpectedly"
    end
    info "Closed"
  end

  def method_missing(sock, cmd)
    sock.puts "504 not implemented"
  end

  private def greet(sock)
    sock.puts "220 maild ESMTP server ready"
  end

  handle "noop" do |sock|
    sock.puts "250 no operation performed"
  end
end
