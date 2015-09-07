require "../../../src/maild/handler"
require "../../../src/maild/logger"
require "../../../src/maild/io"
require "../../../src/maild/smtp"
require "socket"

$no_logging = true

class Maild::SMTP < Maild::Handler
  describe "#handle" do
    it "greets on connect" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
    end
    it "accepts commands" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "NOOP"
        ss[0].gets.not_nil!.chomp.should eq "250 no operation performed"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
    end
    it "times out after a couple seconds" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 2.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        sleep 3.seconds
        ss[0].gets.not_nil!.chomp.should eq "421 timed out"
        ss[1].closed?.should be_true
      end
      smtp.handle(ss[1])
    end
  end
end