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

  describe "#method_missing" do
    it "warns about nonexistent commands" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "AWDAWDAW"
        ss[0].gets.not_nil!.chomp.should eq "504 not implemented"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
    end
  end

  describe "#argument_missing" do
    it "warns about missing command arguments" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 5.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "HELO"
        ss[0].gets.not_nil!.chomp.should eq "501 argument missing: identity"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
    end
  end

  describe "#cmd_noop" do
    it "performs no operation" do
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
  end

  describe "#cmd_rset" do
    it "sets all instance variables to nil" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 2.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "HELO example.com"
        ss[0].gets.not_nil!.chomp.should eq "250 greetings, example.com!"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
      smtp.identity.should eq "example.com"
      ss = UNIXSocket.pair
      spawn do
        ss[0].puts "RSET"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
      smtp.identity.should eq nil
    end
  end

  describe "#cmd_ehlo" do
    it "greets the client" do
      smtp = Maild::SMTP.new
      ss = UNIXSocket.pair
      smtp.timeout = 2.seconds
      spawn do
        ss[0].gets.not_nil!.chomp.should eq "220 maild ESMTP server ready"
        ss[0].puts "EHLO example.com"
        ss[0].gets.not_nil!.chomp.should eq "250-greetings, example.com!"
        ss[0].puts "QUIT"
      end
      smtp.handle(ss[1])
    end
  end
end