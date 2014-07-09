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

# mco rpc puppet runonce --batch 2 
# https://github.com/example42/puppet-mcollective/blob/master/files/plugins/application/puppetd.rb

require 'rubygems'
require "mcollective"
include MCollective::RPC
   
def func1
  puts "func1 at: #{Time.now}"
  sleep(120)
end

layer='batch'
interval=2

mc = rpcclient "puppet"
mc.compound_filter "deploop_category=#{layer}"
mc.progress = false

nodes = mc.discover
nodes = mc.discover.sort

result = mc.runonce(:forcerun => true, :batch_size => interval)
puts "schedule status: #{result[0][:statusmsg]}"
printrpcstats

t1=Thread.new{func1()}
puts 'waiting for puppet run all catalog finished'
t1.join
puts 'done'


