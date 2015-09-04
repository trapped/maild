require "socket"

abstract class Maild::Handler
  abstract def method_missing(sock : TCPSocket, name : String)
  abstract def argument_missing(sock : TCPSocket, name : String)
  abstract def handle(sock : TCPSocket)

  macro inherited
    macro handle(sock, cmd, args)
      case \{\{cmd.id}}.upcase
      \{% for method in @type.methods.map(&.name.stringify).select(&.starts_with? "cmd_").map(&.gsub(/cmd_/, "")) %}
      when \{\{method.upcase}}
        cmd_\{\{method.id}}(sock, args)
      \{% end %}
      else
        method_missing sock, \{\{cmd.id}}.upcase
      end
    end
  end

  macro required(name, source)
    {{name.id}} = {{source.id}} || return argument_missing sock, {{name}}
  end

  macro must_not_have(var)
    return sock.puts "503 wrong session state" if {{var}}
  end

  macro must_have(var)
    return sock.puts "503 wrong session state" unless {{var}}
  end
end
