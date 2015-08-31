require "./maild/*"

list = Maild::Listener.new(2525)
list.start

loop do
  gets
end
