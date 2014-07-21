
require 'net/ping'

p Net::Ping::TCP.new('mncars007').ping?
