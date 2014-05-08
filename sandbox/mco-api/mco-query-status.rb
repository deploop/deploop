#!/usr/bin/env ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
# This example is the same as mco cli command:
# mco service status atd --with-identity openbus-nn1
 
require "mcollective"
  
include MCollective::RPC
   
mc = rpcclient "service"
mc.progress = false

mc.identity_filter "openbus-nn1"
    
printrpc mc.status :service => "atd"
