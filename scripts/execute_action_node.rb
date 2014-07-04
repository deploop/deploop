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

# mco rpc deploop execute cmd='ls -l' --with-identity=openbus-nn1

require "mcollective"
include MCollective::RPC

$cmd='ls -l'

$h = 'openbus-nn1'
mc = rpcclient "deploop"
mc.identity_filter "#{$h}"
mc.progress = false

result = mc.execute(:cmd=> $cmd)

result[0][:data].each do |a|
  puts a
end

puts "Exit Code: #{result[0][:data][:exitcode]}"


mc.disconnect 
