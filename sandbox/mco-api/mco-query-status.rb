#!/usr/bin/env ruby
# This example is the same as mco cli command:
# mco service status atd --with-identity openbus-nn1
 
require "mcollective"
  
include MCollective::RPC
   
mc = rpcclient "service"
mc.progress = false

mc.identity_filter "openbus-nn1"
    
printrpc mc.status :service => "atd"
