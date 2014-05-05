#!/usr/bin/env ruby
# This example is the same as mco cli command:
# mco service status atd --with-identity openbus-nn1
 
require "mcollective"
  
include MCollective::RPC
   
c = rpcclient("service")
c.identity_filter "openbus-nn1"
    
printrpc c.status(:service => "atd")
