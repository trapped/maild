require "socket"

abstract class Maild::Handler
  @@handlers = nil

  def initialize
    @@handlers = Hash(String, (TCPSocket, Array(String) -> (Nil))).new unless @@handlers
  end

  abstract def method_missing(sock : TCPSocket, name : String)
  abstract def argument_missing(sock : TCPSocket, name : String)
  abstract def handle(sock : TCPSocket)

  private def handle(sock : TCPSocket, cmd : String, line : Array(String))
    if @@handlers.not_nil!.has_key? cmd.upcase
      handler = @@handlers.not_nil!.fetch(cmd.upcase)
      handler.call sock, line
    else
      method_missing sock, cmd.upcase
    end
  end

  def self.add_method(cmd : String, proc : (TCPSocket, Array(String) -> (Nil)))
    if @@handlers.nil?
      info "Reinstantiating @@handlers"
      @@handlers = Hash(String, (TCPSocket, Array(String) -> (Nil))).new
    end
    @@handlers.not_nil![cmd.upcase] = proc
  end

  macro handle(cmd)
    def self.cmd_{{cmd.id}}(sock : TCPSocket, args : Array(String))
      {{yield}}
      return nil
    end
    self.add_method({{cmd}}, ->cmd_{{cmd.id}}(TCPSocket, Array(String)))
    info "New handler: #{{{cmd}}}"
  end

  macro requires(cast)
    #the 'as' keyword is reserved for cast exprs, but we can carve the values out
    #https://github.com/manastech/crystal/blob/ff30e2eb976286e260ef33b3ba6340422a479fa9/src/compiler/crystal/macros/methods.cr#L927-L938
    %value = nil
    begin
      %value = {{cast.obj.id}}
    rescue IndexError
      self.argument_missing sock, {{cast.to.stringify.downcase}}
      return nil
    end
    %value = {{cast.obj.id}} as {{cast.to.id}}
    %value
  end
end
