require "./maild/*"
require "./maild/smtp/*"
require "./maild/pop3/*"

info "Starting maild"
list = Maild::Listener.new(2525, Maild::SMTP.new)
list.start
