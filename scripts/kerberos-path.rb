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
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed

require 'open3'
require "mcollective"
include MCollective::RPC

# sanity checking
min_release  = "1.8.7 (2011-06-30)"
ruby_release = "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE})"
if ruby_release != min_release
  abort "This program requires Ruby version #{min_release}.
    You're running #{ruby_release}; please upgrade to continue."
end

puts "The Marionette Collective version #{MCollective.version}"

mc = rpcclient "rpcutil"
mc.compound_filter 'deploop_collection=/.*/'
nodes = mc.discover

puts "Creating keytab per node: "
nodes.each do |c| 
  cmd = "echo #{c}"
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdout.each_line { |line| puts line }
  end
end





