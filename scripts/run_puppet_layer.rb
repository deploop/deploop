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
   
def func1(nodes, mc)
  m = rpcclient "puppet"
  m.progress = false
  processed = nodes.dup
  while nodes.any? do
    nodes.each do |n|
      m.reset_filter
      m.identity_filter n
      ret = m.status(:forcerun => true)
      #p ret
      status = ret[0][:data][:status]
      epoch = ret[0][:data][:lastrun]
      if (status == 'stopped' and epoch > $epoch)
        puts "Finished catalog run for #{n}"
        processed.delete n
      end
    end
    nodes = processed.dup
    sleep(5)
  end
end

layer='batch'
interval=2

$epoch = Time.now.to_i

mc = rpcclient "puppet"
mc.compound_filter "deploop_category=#{layer}"
mc.progress = true

nodes = mc.discover
nodes = mc.discover.sort

result = mc.runonce(:forcerun => true, :batch_size => interval)

t1=Thread.new{func1 nodes, mc}
puts 'waiting for puppet run all catalog finished'
t1.join
puts 'DONE!'


