require "socket"

class Maild::Listener
  @pool = [] of Fiber

  def initialize(port)
    @ch = Channel(TCPSocket).new
    @server = TCPServer.new(port)
  end

  def handle(sock)
    sock.puts "woah"
    sock.close
  end

  def start
    spawn do
      10.times do
        @pool << spawn do
          loop do
            handle @ch.receive
          end
        end
      end
      loop do
        sock = @server.accept
        @ch.send sock
      end
    end
  end
end
