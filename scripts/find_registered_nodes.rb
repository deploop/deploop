#!/usr/bin/env ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
#
# mco find --with-fact "deploop_collection=/.*/"

require "mcollective"
include MCollective::RPC
   
puts "The Marionette Collective version #{MCollective.version}"

mc = rpcclient "rpcutil"
mc.compound_filter 'deploop_collection=/.*/'

nodes = mc.discover

puts "Deploop enabled in:"
nodes.each do |c| 
  print "\tHostname => "
  puts c
end
