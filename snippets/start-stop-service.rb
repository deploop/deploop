#!/usr/bin/env ruby
# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# mco rpc service start service=zookeeper-server
# mco rpc rpcutil get_fact fact=deploop_collection

require 'rubygems'
require "mcollective"
include MCollective::RPC
   
layer='batch'
service='zookeeper-server'
start = true

mcService = rpcclient "service"
mcService.compound_filter "deploop_category=#{layer}"
mcService.progress = false
nodes = mcService.discover
nodes = mcService.discover.sort


nodes.each do |n| 
  mcFact = rpcclient 'rpcutil'
  mcFact.fact_filter "hostname=#{n}"
  mcFact.progress = false

  result = mcFact.get_fact(:fact => "deploop_role")
  case result[0][:data][:value] 
  when 'nn1', 'nn2', 'rm'
    if start
      res = mcService.start(:service => service)
    else
      res = mcService.stop(:service => service)
    end
  end
  mcFact.disconnect
end

#puts "schedule status: #{result[0][:statusmsg]}"
#printrpcstats

