require "./maild/*"
require "./maild/smtp/*"
require "./maild/pop3/*"

info "Starting maild"
info "#{Maild::User.all.size} users in database"
list = Maild::Listener.new(2525, Maild::SMTP)
list.start
