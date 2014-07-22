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

require_relative '../lib/deployfacts'
require_relative '../lib/outputhandler'

module Main
  class MainLogic

    def initialize(opt)
      # this is the main module for cluster deployment.
      @facts = DeployFacts::FactsDeployer.new opt

      # stdout, stderr handler for Ruby on Rails or cli calls.
      # The constructor get the -j or --json parameter from cli.
      @outputHandler = OutputModule::OutputHandler.new opt.output

      # Setup the puppet environment for multi-cluster setup.
      @environment = Environment::PuppetEnvironment.new @outputHandler

      # Extlookup csv file render
      #@csv = ExtLookup::CSVExtLookup.new 'uno', 'dos'

      # cli parameters.
      @opt = opt

      # main method for Opt navigation.
      navigateOptions
    end

    def navigateOptions()
      if @opt.verbose 
          puts @opt
      end
      
      # Code realted with CLI parameter -f JSON.file.
      # This option is used for the full deploy of a new
      # cluster:
      #
      # 1. Deploy the Deploop facts.
      # 2. Execute the puppet runs over the cluster.
      # 3. BootStrap the cluster.
      #
      # Example of CLI call:
      #
      #   deploop -f cluster.json --set-environment
      #   deploop -f cluster.json --deploy batch,bus
      #   deploop -f cluster.json --deploy batch --nofacts --norun
      #
      if !@opt.json.empty?
        if !File.exist?(@opt.json[0])
          @outputHandler.msgError "ERROR: unable open file #{@opt.json}"
        end
        # create puppet environment for Testing.
        if @opt.penv
          @environment.createPuppetMasterEnv @facts.loadJSON @opt.json[0]
          exit
        end
        # show facts for Testing.
        if @opt.show 
          @facts.createFactsHash @opt.json[0], true
          exit
        end
        # integrity checking for Testing.
        if @opt.check
          @facts.checkJSON @opt.json[0]
          exit
        end
        # cluster real deployment, no Testing.
        if @opt.deploy
          @environment.createPuppetMasterEnv @facts.loadJSON @opt.json[0]
          @facts.createFactsHash @opt.json[0], false
          exit
        else
          puts "you have to put more options"
        end
      end

      # with --layer parameter you can start/stop
      # a whole layer (cluster). The start/stop is 
      # over a yet deployed  cluster. So the JSON 
      # is no important here.
      #
      # Example of CLI call:
      # 
      # deploop --cluster production --layer batch --stop
      # deploop --cluster production --layer batch,speed --start
      #
      if @opt.layer
        if @opt.cluster.nil?
          puts "ERROR: you have put a cluster name"
          exit
        end
        if !@opt.operation
          puts 'ERROR: you have to put an operation over the layers (start, stop)'
          puts 'example: deploop --layer batch --stop'
          exit
        else
          # you run an action (start/stop) over a cluster and layer.
          @facts.layerRunAction @opt.cluster, @opt.layer, @opt.operation
        end
      end

      #
      # with --host option you can handle all the 
      # deploy steps by phase. 
      #
      if @opt.host
        puts "hostname to handle"
      end

      if @opt.topology
        if @opt.cluster.nil?
          puts "ERROR: you have to give a cluster name topology"
          exit
        end
        @facts.printTopology @opt.cluster
      end

      if (@opt.report and @opt.cluster.nil?)
        puts "ERROR: you have to give a cluster name for reporting"
        exit
      else
        @facts.printReport @opt.cluster
      end

    end
  end # class MainLogic
end

