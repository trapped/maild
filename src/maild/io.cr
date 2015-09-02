module IO
  def puts(string : String)
    self << string
    puts unless string.ends_with?("\r\n")
  end

  def puts
    write_byte '\r'.ord.to_u8
    write_byte '\n'.ord.to_u8
  end
end
