require "../../src/maild/listener"
require "../../src/maild/handler"
require "../../src/maild/smtp"

class Maild::Listener
  describe "#initialize" do
    it "accepts 1 or 2 arguments" do
      x = begin
        Maild::Listener.new nil
      rescue ex
        puts ex.inspect
        nil
      end
      x.should_not be_nil

      x = begin
        Maild::Listener.new(nil, Maild::SMTP)
      rescue ex
        puts ex.inspect
        nil
      end
      x.should_not be_nil
    end
  end
end
