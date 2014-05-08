require 'webrick'
 
include WEBrick
 
port=8080

puts "Starting server: http://#{Socket.gethostname}:#{port}"
server = HTTPServer.new(:Port=>port,:DocumentRoot=>Dir::pwd )
trap("INT"){ server.shutdown }
server.start
