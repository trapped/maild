require "socket"

abstract class Maild::Handler
  @@handlers = nil
  def initialize
    @@handlers = Hash(String, (TCPSocket, Array(String) -> (Nil | Int32))).new unless @@handlers
  end
  private def handle(sock : TCPSocket, cmd : String, line : Array(String))
    if @@handlers.not_nil!.has_key? cmd.upcase
      handler = @@handlers.not_nil!.fetch(cmd.upcase)
      handler.call sock, line
    else
      method_missing sock, cmd.upcase
    end
  end
  def self.add_method(cmd : String, proc : (TCPSocket, Array(String) -> (Nil | Int32)))
    if @@handlers.nil?
      info "Reinstantiating @@handlers"
      @@handlers = Hash(String, (TCPSocket, Array(String) -> (Nil | Int32))).new
    end
    @@handlers.not_nil![cmd.upcase] = proc
  end
  macro handle(cmd)
    def self.cmd_{{cmd.id}}(sock : TCPSocket, args : Array(String))
      {{yield}}
    end
    self.add_method({{cmd}}, ->cmd_{{cmd.id}}(TCPSocket, Array(String)))
    info "New handler: #{{{cmd}}}"
  end
  abstract def method_missing(sock : TCPSocket, name : String)
  abstract def handle(sock : TCPSocket)
end
