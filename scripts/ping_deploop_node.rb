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

# mco rpc rpcutil agent_inventory -I mncars001 -j

require 'socket'
require "mcollective"
include MCollective::RPC

$h = 'openbus-nn1.openbus.org'
#$h = 'openbus-nn1'
host = Socket.gethostbyname($h)
mc = rpcclient "rpcutil"
mc.identity_filter "#{host[1][0]}"
mc.progress = false

result = mc.inventory
puts result[0][:data][:agents].include? 'deploop'

mc.disconnect 
