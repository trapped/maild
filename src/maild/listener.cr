require "socket"
require "concurrent/channel"

module Maild
  class Listener
    def initialize(port : (Int32 | Nil), protocol_handler = nil : (Maild::Handler.class | Nil))
      @ch = Channel(TCPSocket).new
      @proto_handler = protocol_handler || nil
      @server = TCPServer.new(port) if port
    end

    private def handle(sock : TCPSocket)
      if @proto_handler.nil?
        sock.close unless sock.closed?
      else
        @proto_handler.not_nil!.new.handle sock
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
      info "Spawned 10 listener workers"
      loop do
        sock = @server.not_nil!.accept if @server
        @ch.send sock.not_nil!
      end
    end
  end
end
