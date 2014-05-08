#!/usr/bin/env ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby

require 'rubygems'
require 'rest_client'

# Get a catalog from the node
HOST='openbus-rm.openstacklocal'
URL='https://puppet:8140/production/catalog/' + HOST
puts RestClient.get URL, {:accept => :pson}

# The same as: "sudo puppet cert --list --all"
URL='https://puppet:8140/production/certificate_statuses/all'
puts  RestClient.get URL, {:accept => :pson}

