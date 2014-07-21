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
#
# Author::  Javi Roman <javiroman@redoop.org>
# Website:: http://www.redoop.org
    
require 'socket'
require 'net/ping'
require "mcollective"

include MCollective::RPC
   
module Marionette
  class MCHandler
    def initialize
      #FIXME: set the environment this way is dirty.
      @cmdenv = 'source /etc/profile.d/java.sh && '
    end

    # ==== Summary
    #
    # This method raises an ICMP request. It's used
    # for check wether the host is up before operate
    # over him. For example is used in a JSON cluster
    # deployment before the real deployment.
    #
    # ==== Attributes
    #
    # * +host+ - the host to make the ping
    #
    def ifHostUp(host)
      Net::Ping::TCP.new(host).ping?
    end

    # ==== Summary
    #
    # This method is used for check if the host
    # has installed the mcollective-deploop-agent,
    # therefore the node can be handled by Deploop.
    #
    # ==== Attributes
    #
    # * +host+ - the host to make the ping
    #
    def checkIfDeploopHost(host)
      mc = rpcclient "rpcutil"

      # https://github.com/deploop/deploop/issues/5

      h = Socket.gethostbyname(host)
      mc.identity_filter "#{h[1][0]}"
      mc.progress = false

      result = mc.inventory
      mc.disconnect 

      result[0][:data][:agents].include? 'deploop'
    end

    # ==== Summary
    #
    # This method is used for execute the action
    # 'puppet_environment' from mcollective deploop
    # agent. This action add three entries to the
    # file /etc/puppet.conf in order to get the host
    # ready for an Puppet Master environment.
    #
    # ==== Attributes
    #
    # * +host+ - the host to make the ping
    # * +env+ - The Puppet environment, production
    #           preproduction or test.
    #
    def deployEnv(host, env)
      mc = rpcclient "deploop"

      h = Socket.gethostbyname(host)
      mc.identity_filter "#{h[1][0]}"
      mc.progress = false

      mc.puppet_environment(:env => env)

      mc.disconnect 
    end

    # ==== Summary
    #
    # This method is used for execute the action
    # 'create_fact' from mcollective deploop
    # agent. This action create the custom facts
    # used by Deploop. This new facts are used
    # by the Puppet catalog recipes in order to
    # handle the proper role of the node.
    #
    # ==== Attributes
    #
    # * +host+ - the host to make the ping
    # * +fact+ - The Puppet environment, production
    #           preproduction or test.
    # * +value+ - The Puppet environment, production
    #
    def deployFact(host, fact, value)
      mc = rpcclient "deploop"

      h = Socket.gethostbyname(host)
      mc.identity_filter "#{h[1][0]}"
      mc.progress = false

      mc.create_fact(:fact => fact, :value => value)

      mc.disconnect 
    end

    def checkForPuppetRun(nodes, ep)
      m = rpcclient "puppet"
      m.progress = false
      processed = nodes.dup
      while nodes.any? do
        nodes.each do |n|
          m.reset_filter
          m.identity_filter n
          ret = m.status(:forcerun => true)
          status = ret[0][:data][:status]
          epoch = ret[0][:data][:lastrun]
          if (status == 'stopped' and epoch > ep)
            puts "Finished catalog run for #{n}"
            processed.delete n
          end
        end
        nodes = processed.dup
        sleep(5)
      end
    end

    # ==== Summary
    #
    # This method is used for execute a
    # 'puppet run' over the all layer in
    # bunchs of 'interval' hosts.
    #
    # ==== Attributes
    #
    # * +layer+ - the layer over to run the puppet runs
    # * +interval+ - the batch execution of mcollective
    #
    def puppetRunBatch(cluster, layer, interval)

      epoch = Time.now.to_i

      mc = rpcclient "puppet"
      mc.compound_filter "deploop_collection=#{cluster} and deploop_category=#{layer}"
      mc.progress = false

      nodes = mc.discover
      nodes = mc.discover.sort

      result = mc.runonce(:forcerun => true, :batch_size => interval)
      waitPuppetRun = Thread.new{checkForPuppetRun nodes, epoch}
      puts 'waiting for puppet run all catalog finished'

      waitPuppetRun.join
      puts 'DONE!'
    end

    # ==== Summary
    #
    # This method is used for Start/Stop/BootStrap the
    # batch layer (a Hadoop system). This method uses
    # the mcollective-service-agent for start and stop
    # the Hadoop services. And use the action MIERDA
    # for execute task for the Hadoop BootStrapping,
    # in other words, the first time a Hadoop cluster
    # is deployed.
    #
    # ==== Attributes
    #
    # * +operation+ - start/stop or bootstrap.
    #
    def handleBatchLayer(cluster, operation)
        case operation
        when 'bootstrap'
          batchLayerBootStrapping cluster
        when 'start'
          batchLayerStart cluster
        when 'stop'
          batchLayerStop cluster
        else
          puts "ERROR"
        end
    end

#        worker_services = ['hadoop-hdfs-datanode', 'hadoop-yarn-nodemanager']
#        manager_1st_services = ['hadoop-hdfs-zkfc', 'hadoop-hdfs-jornalnode', 
#          'zookeeper-server']
#        nn_services = ['hadoop-hdfs-namenode']
#        rm_services = ['hadoop-yarn-resourcemanager', 'mapreduce-historyserver']

        # discover worker node collection
#        mcService = rpcclient "service"
#        mcService.compound_filter 'deploop_category=batch and deploop_role=dn'
#        mcService.progress = false
#        nodes = mcService.discover
#        nodes = mcService.discover.sort

#        nodes.each do |n| 
#          mcFact = rpcclient 'rpcutil'
#          mcFact.identity_filter "#{n}"
#          mcFact.progress = false

#          worker_services.each do |service|
#            if operation == 'start'
#              puts "starting #{service} in #{n}"
#              res = mcService.start(:service => service)
#            else
#              puts "stopping #{service} in #{n}"
#              res = mcService.stop(:service => service)
#            end
#          end
#          mcFact.disconnect
#        end

    # ==== Summary
    #
    # This method is used for Start/Stop/BootStrap the
    # Bus layer (a Hadoop system). This method uses
    # the mcollective-service-agent for start and stop
    # the Hadoop services. And use the action MIERDA
    # for execute task for the Hadoop BootStrapping,
    # in other words, the first time a Hadoop cluster
    # is deployed.
    #
    # ==== Attributes
    #
    # * +operation+ - start/stop or bootstrap.
    #
    def handleBusLayer(cluster, operation)
        case operation
        when 'bootstrap'
          puts 'bootstrap bus layer'
        when 'start'
          puts 'starting bus layer'
        when 'stop'
          puts 'stopping bus layer'
        else
          puts "ERROR"
        end
    end

    # ==== Summary
    #
    # This method is used for Start/Stop/BootStrap the
    # Speed layer (a Hadoop system). This method uses
    # the mcollective-service-agent for start and stop
    # the Hadoop services. And use the action MIERDA
    # for execute task for the Hadoop BootStrapping,
    # in other words, the first time a Hadoop cluster
    # is deployed.
    #
    # ==== Attributes
    #
    # * +operation+ - start/stop or bootstrap.
    #
    def handleSpeedLayer(cluster, operation)
        case operation
        when 'bootstrap'
          puts 'bootstrap speed layer'
        when 'start'
          puts 'starting speed layer'
        when 'stop'
          puts 'stopping speed layer'
        else
          puts "ERROR"
        end
    end

    # ==== Summary
    #
    # This method is used for Start/Stop/BootStrap the
    # Serving layer (a Hadoop system). This method uses
    # the mcollective-service-agent for start and stop
    # the Hadoop services. And use the action MIERDA
    # for execute task for the Hadoop BootStrapping,
    # in other words, the first time a Hadoop cluster
    # is deployed.
    #
    # ==== Attributes
    #
    # * +operation+ - start/stop or bootstrap.
    #
    def handleServingLayer(cluster, operation)
        case operation
        when 'bootstrap'
          puts 'bootstrap serving layer'
        when 'start'
          puts 'starting serving layer'
        when 'stop'
          puts 'stopping serving layer'
        else
          puts "ERROR"
        end
    end

    def getClusterHosts(cluster)
      # discovering the node managers.
      mc = rpcclient "rpcutil"
      mc.compound_filter "(deploop_role=nn1 or deploop_role=nn2 or deploop_role=rm) and deploop_collection=#{cluster} "
      node_managers = mc.discover
      
      # the workers list
      mc.reset_filter
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=dn"
      node_workers = mc.discover

      # storing nodemanagers one by one
      mc.reset_filter
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=nn1"
      node = mc.discover
      nn1 = node[0]

      mc.reset_filter
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=nn2"
      node = mc.discover
      nn2 = node[0]

      mc.reset_filter
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=rm"
      node = mc.discover
      rm = node[0]
      mc.disconnect

      return node_managers, node_workers, nn1, nn2, rm
    end


    # ==== Summary
    #
    # Complex method for make the BootStrap phase
    # of Hadoop cluster. The bootstrapping phases are:
    #
    # 1. Zookeeper Esemble bootstrappping.
    # 2. Zookeeper Esemble Znode formating.
    # 3. QJM - Quorum Journal Manager startup.
    # 4. HDFS format initialization.
    # 5. Namenodes startup.
    # 6. HA checking for error sanity control.
    # 7. Automatic Failover startup (Zkfc).
    # 8. Workers node startup.
    # 9. Minimal HDFS folders layout creation.
    #
    # ==== Attributes
    #
    def batchLayerBootStrapping(cluster)
      node_managers, node_workers, nn1, nn2, rm = getClusterHosts cluster

      puts "Batch Layer (Hadoop) Bootstrap ..."

      #
      # 1. Zookeeper bootstrap
      #
      puts "Zookeeper Esemble starting up ..."
      node_managers.each do |h|
        mcServiceAction h, 'zookeeper-server', 'start'
      end

      #
      # 2. Zookeeper znode formating for Automatic Failover.
      #
      # FIXME: Warning FORMAT
      puts "Zookeeper Znode formating for Automatic Failover ..."
      cmd = @cmdenv + 'sudo -E -u hdfs hdfs zkfc -formatZK -force'
      dpExecuteAction nn1, cmd

      #
      # 3. QJM - Quorum Journal Manager startup.
      #
      puts "starting QJM ...."
      node_managers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-journalnode', 'start'
      end

      #
      # 4. HDFS format initialization
      #
      # FIXME: Warning FORMAT
      puts "Formating HDFS ...."
      cmd = @cmdenv + 'sudo -E -u hdfs hdfs namenode -format -force'
      dpExecuteAction nn1, cmd

      # 
      # 5. Namenodes startup
      #
      puts "NameNodes start up ...."
      mcServiceAction nn1, 'hadoop-hdfs-namenode', 'start'
      # FIXME: Warning FORMAT:
      cmd = @cmdenv + 'sudo -E -u hdfs hdfs namenode -bootstrapStandby'
      dpExecuteAction nn2, cmd
      mcServiceAction nn2, 'hadoop-hdfs-namenode', 'start'

      # 
      # 6. Check HA
      #
      puts "HA checking ..."
      cmd = @cmdenv + 'sudo -E -u hdfs hdfs haadmin -getServiceState nn1'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hdfs haadmin -getServiceState nn2'
      dpExecuteAction nn1, cmd

      #
      # 7. Automatic Failover startup
      #
      puts "Automatic Failover startup"
      mcServiceAction nn1, 'hadoop-hdfs-zkfc', 'start'
      mcServiceAction nn2, 'hadoop-hdfs-zkfc', 'start'

      #
      # 8. Workers node startup 
      #
      puts "starting DataNode workers...."
      node_workers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-datanode', 'start'
      end

      #
      # 9. Minimal HDFS folders layout creation.
      #
      puts "HDFS folder initialization ..."
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -mkdir /tmp'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -chmod -R 1777 /tmp'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -mkdir -p /user/history'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -mkdir /user/history/done_intermediate'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -chown -R mapred:mapred /user/history'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -chmod -R 777 /user/history'
      dpExecuteAction nn1, cmd

      #
      # 10. History Server.
      #
      puts "Hisotry server starting up ..."
      mcServiceAction rm, 'hadoop-mapreduce-historyserver', 'start'
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn'
      dpExecuteAction nn1, cmd

      #
      # 11. Example user creation.
      #
      puts "example user creation"
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -mkdir -p /user/jroman'
      dpExecuteAction nn1, cmd
      cmd = @cmdenv + 'sudo -E -u hdfs hadoop fs -chown jroman /user/jroman'
      dpExecuteAction nn1, cmd

      #
      # 11. YARN system start up
      #
      puts "YARN Framework starting up"
      mcServiceAction rm, 'hadoop-yarn-resourcemanager', 'start'
      node_workers.each do |h|
        mcServiceAction h, 'hadoop-yarn-nodemanager', 'start'
      end

    end

    # ==== Summary
    #
    # Gracefully start of Batch Layer.
    #
    # ==== Attributes
    #
    def batchLayerStart(cluster)
      node_managers, node_workers, nn1, nn2, rm = getClusterHosts

      # 1. Start Zookeeper Esemble
      puts "starting up Zookeeper Esemble...."
      node_managers.each do |h|
        mcServiceAction h, 'zookeeper-server', 'start'
      end

      # 2. Stop QJM
      puts "starting up QJM ...."
      node_managers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-journalnode', 'start'
      end

      # 3. Start namenodes and resourcemanager
      puts "starting up NameNodes and ResourceManager ...."
      mcServiceAction nn1, 'hadoop-hdfs-namenode', 'start'
      mcServiceAction nn2, 'hadoop-hdfs-namenode', 'start'
      mcServiceAction rm, 'hadoop-yarn-resourcemanager', 'start'

      # 4. Start Automatic Failover
      puts "starting up Zkfc ...."
      mcServiceAction nn1, 'hadoop-hdfs-zkfc', 'start'
      mcServiceAction nn2, 'hadoop-hdfs-zkfc', 'start'

      #
      # 5. History Server.
      #
      puts "Hisotry server starting up ..."
      mcServiceAction rm, 'hadoop-mapreduce-historyserver', 'start'

      # 6. start the workers.
      puts "starting up DataNode workers...."
      node_workers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-datanode', 'start'
        mcServiceAction h, 'hadoop-yarn-nodemanager', 'start'
      end
    end

    # ==== Summary
    #
    # Gracefully stop of Batch Layer.
    #
    # ==== Attributes
    #
    def batchLayerStop(cluster)
      node_managers, node_workers, nn1, nn2, rm = getClusterHosts

      # 1. Stop the workers.
      puts "shutting down DataNode workers...."
      node_workers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-datanode', 'stop'
        mcServiceAction h, 'hadoop-yarn-nodemanager', 'stop'
      end

      # 2. Stop Automatic Failover
      puts "shutting down Zkfc ...."
      mcServiceAction nn1, 'hadoop-hdfs-zkfc', 'stop'
      mcServiceAction nn2, 'hadoop-hdfs-zkfc', 'stop'

      # 3. Stop QJM
      puts "shutting down QJM ...."
      node_managers.each do |h|
        mcServiceAction h, 'hadoop-hdfs-journalnode', 'stop'
      end

      # 4. Stop Zookeeper
      puts "shutting down Zookeeper Esemble...."
      node_managers.each do |h|
        mcServiceAction h, 'zookeeper-server', 'stop'
      end

      # 5. Stop namenodes and resourcemanager
      puts "shutting down NameNodes and ResourceManager ...."
      mcServiceAction nn1, 'hadoop-hdfs-namenode', 'stop'
      mcServiceAction nn2, 'hadoop-hdfs-namenode', 'stop'
      mcServiceAction rm, 'hadoop-yarn-resourcemanager', 'stop'

      #
      # 6. History Server.
      #
      puts "shutting down Hisotry server ..."
      mcServiceAction rm, 'hadoop-mapreduce-historyserver', 'stop'
    end

    # ==== Summary
    #
    # mcollective-service-agent wrapper. This
    # method start/stop one service in one host.
    #
    # ==== Attributes
    #
    # * +host+ - host over to start/stop the service
    # * +service+ - the service name
    # * +cmd+ - start/stop.
    #
    def mcServiceAction(host, service, cmd)
      mc = rpcclient "service"

      h = Socket.gethostbyname(host)
      mc.identity_filter "#{h[1][0]}"

      mc.progress = false
      if cmd == 'start'
        res = mc.start(:service => service)
      else
        res = mc.stop(:service => service)
      end
      mc.disconnect
    end 

    # ==== Summary
    #
    # mcollective-deploop-agent wrapper for
    # 'execute' free command action.
    #
    # ==== Attributes
    #
    # * +host+ - host over to execute the command.
    # * +cmd+ - free command to execute in host.
    #
    def dpExecuteAction(host, cmd)
      mc = rpcclient "deploop"
      h = Socket.gethostbyname(host)
      mc.identity_filter "#{h[1][0]}"
      mc.progress = false

      result = mc.execute(:cmd=> cmd)

      mc.disconnect

      result[0][:data].each do |a|
        puts a
      end

      result[0][:data][:exitcode]
    end

    def printTopology(cluster)
      mc = rpcclient "rpcutil"
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=nn1"
      node = mc.discover
      mc.disconnect

      cmd = @cmdenv + 'sudo -E -u hdfs hdfs dfsadmin -printTopology'

      dpExecuteAction node[0], cmd
    end

    def printReport(cluster)
      mc = rpcclient "rpcutil"
      mc.compound_filter "deploop_collection=#{cluster} and deploop_role=nn1"
      node = mc.discover
      mc.disconnect

      cmd = @cmdenv + 'sudo -E -u hdfs hdfs dfsadmin -report'

      dpExecuteAction node[0], cmd
    end


  end # class MCHandler
end


