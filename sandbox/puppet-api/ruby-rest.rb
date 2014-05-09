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
 
require 'rubygems'
require 'rest_client'

# Get a catalog from the node
HOST='openbus-rm.openstacklocal'
URL='https://puppet:8140/production/catalog/' + HOST
puts RestClient.get URL, {:accept => :pson}

# The same as: "sudo puppet cert --list --all"
URL='https://puppet:8140/production/certificate_statuses/all'
puts  RestClient.get URL, {:accept => :pson}

