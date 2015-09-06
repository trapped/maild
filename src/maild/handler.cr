require "socket"

abstract class Maild::Handler
  abstract def method_missing(sock : Socket, name : String)
  abstract def argument_missing(sock : Socket, name : String)
  abstract def handle(sock : Socket)

  macro inherited
    macro handle(sock, cmd, args)
      case \{\{cmd.id}}.upcase
      \{% for method in @type.methods.map(&.name.stringify).select(&.starts_with? "cmd_").map(&.gsub(/cmd_/, "")) %}
      when \{\{method.upcase}}
        cmd_\{\{method.id}}(sock, args)
      \{% end %}
      else
        method_missing \{\{cmd.id}}.upcase
      end
    end
  end

  macro required(name, source)
    {{name.id}} = {{source.id}} || return argument_missing {{name}}
  end

  macro must_not_have(var)
    return sock.puts "503 wrong session state" unless {{var}}.nil?
  end

  macro must_have(var)
    return sock.puts "503 wrong session state" if {{var}}.nil?
  end
end
