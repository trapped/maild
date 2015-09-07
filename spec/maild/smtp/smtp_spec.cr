class FakeSocket < Socket
  property receiving
  property sending

  def initialize
    @receiving = StringIO.new
    @sending = StringIO.new
  end

  def inspect
    "#{@receiving.inspect}\n#{@sending.inspect}"
  end

  def <<(string)
    info "<<"
    @receiving.puts string
  end

  def write_byte(c)
    @receiving.write_byte c
  end

  def puts(string)
    info "puts"
    @receiving.puts string
  end
  def puts_(string)
    info "puts_"
    @sending.puts string
  end

  def gets
    info "gets"
    @sending.gets
  end
  def gets_
    info "gets_"
    @receiving.gets
  end

  def closed?
    @sending.closed? || @receiving.closed?
  end

  def close
    info "close"
    @receiving.close
  end
  def close_
    @sending.close
  end

  def peeraddr
    Addr.new(0, 0, "test.spec")
  end
end

require "../../../src/maild/handler"
require "../../../src/maild/logger"
require "../../../src/maild/io"
require "../../../src/maild/smtp"

class Maild::SMTP < Maild::Handler
  describe "#handle" do
    it "greets on connect" do
      smtp = Maild::SMTP.new
      ss = FakeSocket.new
      spawn do
        info "gotten here 1"
        ss.gets_.should eq "220 maild ESMTP server ready"
        ss.close
      end
      puts "gotten here 0"
      smtp.handle(ss)
    end
    it "accepts commands" do
      smtp = Maild::SMTP.new
      ss = FakeSocket.new
      smtp.timeout = 2.seconds
      spawn do
        smtp.handle(ss)
      end
      ss.puts_ "NOOP"
      ss.gets_.should eq "250 no operation performed"
      ss.close
    end
    it "times out after a couple seconds" do
      smtp = Maild::SMTP.new
      ss = FakeSocket.new
      smtp.timeout = 2.seconds
      spawn do
        smtp.handle(ss)
      end
      ss.gets_.should eq "421 timed out"
      ss.closed?.should be_true
    end
  end
end