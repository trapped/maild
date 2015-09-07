require "../../../src/maild/handler"
require "../../../src/maild/logger"
require "../../../src/maild/io"
require "../../../src/maild/smtp"
require "socket"

class Maild::SMTP < Maild::Handler
  describe "#handle" do
    it "greets on connect" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      smtp.handle(ss[1])
      ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
      ss[0].close
    end
    it "accepts commands" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      smtp.handle(ss[1])
      ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
      ss[0].puts "NOOP"
      ss[0].gets.not_nil!.chomp.should eq "250 no operation performed"
      ss[0].close
    end
    it "times out after a couple seconds" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 2.seconds
      smtp.handle(ss[1])
      ss[0].gets
      sleep 3.seconds
      ss[0].gets.not_nil!.chomp.should eq "421 timed out"
      ss[1].closed?.should be_true
    end
  end
end