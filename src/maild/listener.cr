require "socket"
require "concurrent/channel"

class Maild::Listener
  def initialize(port : (Int32 | Nil), protocol_handler = nil : (Maild::Handler.class | Nil))
    @ch = Channel(TCPSocket).new if port
    @proto_handler = protocol_handler || nil
    @server = TCPServer.new(port) if port
  end

  private def handle(sock : TCPSocket)
    unless @proto_handler
      sock.close unless sock.closed?
    else
      @proto_handler.new.handle sock
    end
  end

  def start
    10.times do
      spawn do
        loop do
          handle @ch.receive if @ch
        end
      end
    end
    info "Spawned 10 listener workers"
    loop do
      sock = @server.accept if @server
      @ch.send sock if @ch
    end
  end
end
