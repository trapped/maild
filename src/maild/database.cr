require "active_record"
require "fs_adapter"

module Maild
  class User < ActiveRecord::Model
    name User
    adapter fs
    ENV["FSDB_PATH"] = "#{__DIR__}/../../users_db"
    primary id :: Int
    field username :: String
    field pwhash :: String
    field mailbox :: Int
  end
end
