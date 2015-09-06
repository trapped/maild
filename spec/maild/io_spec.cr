module IO
  describe "#puts" do
    it "appends CRLF" do
      s = StringIO.new
      s.puts "z"
      s.to_s.ends_with?("\r\n").should be_true
    end
  end
end
