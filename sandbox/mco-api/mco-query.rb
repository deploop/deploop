#!/usr/bin/env ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
 
require "mcollective"
  
include MCollective::RPC
   
c = rpcclient "service"
c.compound_filter '((customer=acme and environment=staging) or environment=development) and /apache/'
    
printrpc c.restart :service => "httpd"
