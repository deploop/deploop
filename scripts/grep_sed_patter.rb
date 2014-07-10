string = IO.read(ARGV[0])
string = string.gsub!(/^pluginsync.*/m, '')
puts string
