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



# == deployfacts.rb
#
# This module has the main class for cluster deployments.
#
# == Contact
#
# Author::  Javi Roman <javiroman@redoop.org>
# Website:: https://github.com/deploop/deploop
# Date:: 17-06-2014 

require 'rubygems'
require 'json'
require 'pp'

require_relative '../lib/marionette'
require_relative '../lib/outputhandler'
require_relative '../lib/environment'

module DeployFacts
  # Multi-sided dice class.  The number of sides is determined
  # in the constructor, or later on by accessing the _sides_
  # attribute.
  #
  # == Summary
  #  
  # A #single_roll returns a single integer from 1 to the
  # number of sides, _inclusive_.  However, if you want to
  # roll multiple times you can can use the #roll method,
  # specifying the number of rolls you want, and you will
  # get an Array with the values of all the rolls!
  # 
  # == Example
  # 
  #     dice = Dice.new(8)   # An eight sided dice
  #     four = dice.roll(4)  # An Array containing 4 rolls
  #     sum  = four.inject(0) { |mem,i| mem+i } # Sum of rolls
  # 
  class FactsDeployer
    def initialize(opt)
      @opt = opt
      @categories = ['batch', 'bus', 'speed', 'serving']
      @roles_batch = ['nn1', 'nn2', 'rm', 'dn']
      @roles_speed = ['master', 'worker']
      @roles_bus = ['worker']
      @roles_serving = ['master', 'worker']
      @parsed_obj = nil

      @mchandler = Marionette::MCHandler.new 
      @outputHandler = OutputModule::OutputHandler.new opt.output

      # host = {'mncars001' => 
      #           {deploop_collection:'production', deploop_category:'batch',
      #            deploop_role:'nn1',deploop_entity:'flume'}, 
      #         'mncars002' => 
      #           {deploop_collection:'production', deploop_category:'batch',
      #            deploop_role:'nn2',deploop_entity:'flume'}, 
      #         }
      #
      # host['mncars003'] = {:a=>"new", :b=>"value"}
      #
      # The host list with their facts: gattered from the JSON file.
      @host_facts = Hash.new
    end

    # ==== Summary
    #
    # This method is used for check the JSON schema 
    # integrity, the syntax integrity and the cluster
    # logical organization. For example, you can not
    # deploy a Hadoop cluster without a NameNode node
    # in the JSON schema.
    #
    # ==== Attributes
    #
    # * +json+ - JSON file describing the cluster schema
    #
    # ==== Returns
    #  
    # ==== Examples
    #
    def checkJSON(json)
      # FIXME: logical check of cluster pending
      jsonObj = File.read(json)
      begin
          @parsed_obj = JSON.parse(jsonObj)
      rescue JSON::ParserError => e
        puts "ERROR: JSON file parsing error"
        exit
      end
      @parsed_obj
    end 

    # ==== Summary
    #
    # This method fill the variable member @host_facts
    # with the facts per-host. 
    #
    # ==== Attributes
    #
    # * +collection+ - Production, Preproduction or Test
    # * +category+ - batch, speed, or bus layer
    # * +show+ - If true only show the facts per-host
    #
    # ==== Returns
    #  
    # * +@host_facts+ - Fact list per-host
    #
    # ==== Examples
    #
    def create_facts(collection, category, show)
      case category
      when 'batch'
        $roles = @roles_batch
      when 'speed'
        $roles = @roles_speed
      when 'bus'
        $roles = @roles_bus
      else
        $roles = @roles_serving
      end

      $roles.each do |r|
        case r
        when 'dn', 'worker'
          @parsed_obj['cluster_layout'][category][r].each do |w|
              $hostname=w['hostname']
              $entities=w['entity']

              @host_facts[$hostname] = 
                { 'deploop_collection' => collection, 
                  'deploop_category' => category,
                  'deploop_role' => r,
                  'deploop_entity' => $entities }

              if show
                print "#{$hostname}: deploop_collection=#{collection} "
                print "deploop_category=#{category} deploop_role=#{r} deploop_entity="
                $entities.each do |e|
                  print e + " "
                end
                puts ""
              end
           end
        else
            $hostname=@parsed_obj['cluster_layout'][category][r]["hostname"]
            $entities=@parsed_obj['cluster_layout'][category][r]["entity"]

            @host_facts[$hostname] = 
                { 'deploop_collection' => collection, 
                  'deploop_category' => category,
                  'deploop_role' => r,
                  'deploop_entity' => $entities }

            if show
              print "#{$hostname}: deploop_collection=#{collection} "
              print "deploop_category=#{category} deploop_role=#{r} deploop_entity="
              $entities.each do |e|
                print e + " "
              end
              puts ""
            end
        end
      end
    end

    # ==== Summary
    #
    # Load the JSON file and retuns it, also the JSON
    # loaded is stored in the class variable @parsed_obj
    #
    # ==== Attributes
    #
    # ==== Returns
    #
    # ==== Examples
    #
    def loadJSON(json)
      checkJSON(json)
    end

    def createFactsHash(json, show)
      loadJSON(json)
      @categories.each do |b|
        create_facts @parsed_obj['environment_cluster'], b, show
      end

      if !show
        # the real deployment is here.
        deployClusters
      end
    end

    # ==== Summary
    #
    # This is the real method where de deploy magic
    # is done. In this method a main loop go over the
    # layers passed by the user and execute the steps:
    #
    # 1. deployFactsLayer [batch, speed, serving or bus]
    # 2. puppetRunBatch [batch, speed, serving or bus]
    # 3. handleBatchLayer or handleSpeedLayer ...
    #
    # ==== Attributes
    #
    # ==== Returns
    #
    # ==== Examples
    #
    def deployClusters
      # for each layer in --deploy parameter.
      @opt.deploy.each do |d|
        case d
        when 'batch'
          if !@opt.nofacts
            # This is the only method using the JSON information
            # The reamin methods, puppetRunBatch, handleBatchLayer,
            # are using the mcollective discoverty feature using
            # the deployed facts.
            deployFactsLayer 'batch'
          end
          if !@opt.norun
            # this method uses the mc discovery subsystem.
            @mchandler.puppetRunBatch @opt.cluster, 'batch', 2
          end
          if !@opt.onlyrun
            # this method uses the mc discovery subsystem.
            @mchandler.handleBatchLayer @opt.cluster, 'bootstrap'
          end
        when 'bus'
          if !@opt.nofacts
            deployFactsLayer 'bus'
          end
          if !@opt.norun
            @mchandler.puppetRunBatch 'bus', 2
          end
          @mchandler.handleBusLayer 'bootstrap'
        when 'speed'
          if !@opt.nofacts
            deployFactsLayer 'speed'
          end
          if !@opt.norun
            @mchandler.puppetRunBatch 'speed', 2
          end
          @mchandler.handleSpeedLayer 'bootstrap'
        when 'serving'
          if !@opt.nofacts
            deployFactsLayer 'serving'
          end
          if !@opt.norun
            @mchandler.puppetRunBatch 'serving', 2
          end
          @mchandler.handleServingLayer 'bootstrap'
        end
      end
    end 

    # ==== Summary
    #
    # This method exit the cli if any host of the layer
    # is not Deploop enabled. The program continue after the call if
    # all the hosts are enabled.
    #
    # ==== Attributes
    #
    # * +layer+ - The cluster layer
    #
    def checkHosts(layer)
      @host_facts.each do |f|
        if f[1]['deploop_category'] == layer
          up = @mchandler.ifHostUp f[0]
          if @opt.verbose
            puts "checking host #{f[0]} is up: "  
            puts up
          end
          if !up
            msg = "ERROR: host \'#{f[0]}\' is unreachable. Aboring."
            @outputHandler.msgError msg
          end
          deplUp = @mchandler.checkIfDeploopHost f[0]
          if @opt.verbose
            puts "checking Deploop enabled host #{f[0]}: "  
            puts deplUp
          end
          if !deplUp
            msg = "ERROR: host \'#{f[0]}\' is not Deploop enabled, fix this. Aborting."
            @outputHandler.msgError msg
          end
        end
      end
      msg = "The layer \'#{layer}\' has all host Deploop enabled"
      @outputHandler.msgOutput msg
    end

    # ==== Summary
    #
    # The fist step in the deployment. The facts spread.
    # First of all is the environemnt setup in the puppet
    # agents. And the second the deploop_xxx facts population
    # with the roles of the nodes.
    #
    # ==== Attributes
    #
    # * +layer+ - The cluster layer
    #
    def deployFactsLayer(layer)
      deploop_facts = ['deploop_collection',
                      'deploop_category',
                      'deploop_role',
                      'deploop_entity']
      checkHosts layer
      @host_facts.each do |f|
        if f[1]['deploop_category'] == layer
          @mchandler.deployEnv f[0], f[1]['deploop_collection']
          deploop_facts.each do |d|
            if d == 'deploop_entity'
              value = f[1][d].join(" ")
            else
              value = f[1][d]
            end
            puts f[0] + " " + d.split("_")[1] + " " + value
            @mchandler.deployFact f[0], d.split("_")[1], value
          end
        end
      end
    end

    def layerRunAction(cluster, layers, action)
      layers.each do |d|
        case d
        when 'batch'
          @mchandler.handleBatchLayer cluster, action
        when 'bus'
          @mchandler.handleBusLayer cluster, action
        when 'speed'
          @mchandler.handleSpeedLayer cluster, action
        when 'serving'
          @mchandler.handleServingLayer cluster, action
        else
          puts "ERROR: no exits layer"
          exit
        end
      end
    end

    def printTopology
      @mchandler.printTopology
    end

    def printReport
      @mchandler.printReport
    end

  end
end



