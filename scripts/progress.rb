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

progress = 'Progress ['

100.times do |i|
  # i is number from 0-999
  j = i + 1
 
  # add 1 percent every 10 times
  if j % 1 == 0
    progress << "="
    # move the cursor to the beginning of the line with \r
    print "\r"
    # puts add \n to the end of string, use print instead
    print progress + " #{j / 10} % ]"
 
    # force the output to appear immediately when using print
    # by default when \n is printed to the standard output, the buffer is flushed.
    $stdout.flush
    sleep 0.05
  end
end

puts "\nDone!"
