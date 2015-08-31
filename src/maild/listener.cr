require "socket"

class Maild::Listener
  def initialize(port : Int32, protocol_handler = nil : Maild::Handler?)
    @ch = Channel(TCPSocket).new
    @proto_handler = protocol_handler
    @server = TCPServer.new(port)
  end

  private def handle(sock : TCPSocket)
    unless @proto_handler
      sock.close
    else
      @proto_handler.handle sock
    end
  end

  def start
    10.times do
      spawn do
        loop do
          handle @ch.receive
        end
      end
    end
    info "Spawned listener 10 workers"
    loop do
      sock = @server.accept
      @ch.send sock
    end
  end
end
