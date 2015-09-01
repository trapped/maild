require "socket"

abstract class Maild::Handler
  @@methods = Hash(String, (TCPSocket, Array(String) -> (Nil | Int32)))
  private def handle(sock : TCPSocket, cmd : String, line : Array(String))
    if @@methods.not_nil!.has_key? cmd
      handler = @@methods.not_nil!.fetch(cmd)
      handler.call sock, line
    else
      method_missing sock, cmd
    end
  end
  def self.add_method(cmd : String, proc : (TCPSocket, Array(String) -> (Nil | Int32)))
    unless @@methods
      @@methods = Hash(String, (TCPSocket, Array(String) -> (Nil | Int32))).new
    end
    @@methods.not_nil![cmd] = proc
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
