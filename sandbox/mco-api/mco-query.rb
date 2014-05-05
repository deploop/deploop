#!/usr/bin/ruby
 
require "mcollective"
  
include MCollective::RPC
   
c = rpcclient("service")
c.compound_filter '((customer=acme and environment=staging) or environment=development) and /apache/'
    
printrpc c.restart(:service => "httpd")
