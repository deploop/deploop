# http://rdoc.info/gems/curb/0.7.15/
#
require 'mcollective'
require 'curb'

curl = Curl::Easy.download('http://openbus-deploop:8080/ejemplo.dat', filename="ejemplo.dat")

#curl = Curl::Easy.perform('http://openbus-deploop:8080/ejemplo.dat')
#puts curl.body_str
