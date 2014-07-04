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

require 'net/ping'
require "mcollective"

include MCollective::RPC
   
module Marionette
  class MCHandler
    def initialize

    end

    def ifHostUp(host)
      Net::Ping::TCP.new(host).ping?
    end

    def checkIfDeploopHost(host)
      mc = rpcclient "rpcutil"
      mc.identity_filter "#{host}"
      mc.progress = false

      result = mc.inventory
      mc.disconnect 

      result[0][:data][:agents].include? 'deploop'
    end

    def deployEnv(host, env)
      mc = rpcclient "deploop"

      mc.identity_filter host
      mc.progress = false

      mc.puppet_environment(:env => env)

      mc.disconnect 
    end

    def deployFact(host, fact, value)
      mc = rpcclient "deploop"

      mc.identity_filter host
      mc.progress = false

      mc.create_fact(:fact => fact, :value => value)

      mc.disconnect 
    end

    def puppetRunBatch(layer, interval)
      mc = rpcclient "puppet"
      mc.compound_filter "deploop_category=#{layer}"
      mc.progress = false

      nodes = mc.discover
      nodes = mc.discover.sort

      result = mc.runonce(:forcerun => true, :batch_size => interval)
      puts "schedule status: #{result[0][:statusmsg]}"
      printrpcstats
    end

    def handleBatchLayer(operation)
        worker_services = ['hadoop-hdfs-datanode', 'hadoop-yarn-nodemanager']
        manager_1st_services = ['hadoop-hdfs-zkfc', 'hadoop-hdfs-jornalnode', 
          'zookeeper-server']
        nn_services = ['hadoop-hdfs-namenode']
        rm_services = ['hadoop-yarn-resourcemanager', 'mapreduce-historyserver']

        # discover worker node collection
        mcService = rpcclient "service"
        mcService.compound_filter 'deploop_category=batch and deploop_role=dn'
        mcService.progress = false
        nodes = mcService.discover
        nodes = mcService.discover.sort

        nodes.each do |n| 
          mcFact = rpcclient 'rpcutil'
          mcFact.fact_filter "hostname=#{n}"
          mcFact.progress = false

          worker_services.each do |service|
            if operation == 'start'
              puts "starting #{service} in #{n}"
              res = mcService.start(:service => service)
            else
              puts "stopping #{service} in #{n}"
              res = mcService.stop(:service => service)
            end
          end
          mcFact.disconnect
        end

    end

  end # class MCHandler
end


