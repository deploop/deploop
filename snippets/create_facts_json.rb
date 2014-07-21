#!/usr/bin/ruby
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

require 'rubygems'
require 'json'
require 'pp'

json = File.read('../conf/deploy.json')
$parsed_obj = JSON.parse(json)

$collections = ['production', 'preproduction', 'test']
$categories = ['batch', 'bus', 'realtime', 'serving']
$roles_batch = ['nn1', 'nn2', 'rm', 'dn']
$roles_realtime = ['master', 'worker']
$roles_bus = ['worker']
$roles_serving = ['master', 'worker']

def create_facts(collection, category)
  case category
  when 'batch'
    $roles = $roles_batch
  when 'realtime'
    $roles = $roles_realtime
  when 'bus'
    $roles = $roles_bus
  else
    $roles = $roles_serving
  end

  $roles.each do |r|
    case r
    when 'dn', 'worker'
        $parsed_obj[collection][category][r].each do |w|
          $hostname=w['hostname']
          $entities=w['entity']
          print "#{$hostname}: deploop_collection=#{collection} "
          print "deploop_category=#{category} deploop_role=#{r} deploop_entity="
          $entities.each do |e|
            print e + " "
          end
          puts ""
        end
    else
        $hostname=$parsed_obj[collection][category][r]["hostname"]
        $entities=$parsed_obj[collection][category][r]["entity"]
        print "#{$hostname}: deploop_collection=#{collection} "
        print "deploop_category=#{category} deploop_role=#{r} deploop_entity="
        $entities.each do |e|
          print e + " "
        end
        puts ""
    end
  end
end

$collections.each do |a|
  if $parsed_obj[a]
    $categories.each do |b|
      if $parsed_obj['production'][b]
        create_facts 'production',b
      end
    end
  end
end

