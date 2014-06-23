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

require_relative '../lib/deployfacts'
require_relative '../lib/outputhandler'

module Main
  class MainLogic

    def initialize(opt)
      @facts = DeployFacts::FactsDeployer.new opt
      @outputHandler = OutputModule::OutputHandler.new opt.output
      @opt = opt
      navigateOptions
    end

    def navigateOptions()
      if @opt.verbose 
          puts @opt
      end

      #
      # With a JSON file you can check the integrity
      # or deploy the cluster.
      #
      if !@opt.json.empty?
        if !File.exist?(@opt.json[0])
          @outputHandler.msgError "ERROR: unable open file #{@opt.json}"
        end
        if @opt.show
          @facts.createFactsHash @opt.json[0], true
          exit
        end
        # integrity checking
        if @opt.check
          @facts.checkJSON @opt.json[0]
          exit
        end
        # cluster deployment
        if @opt.deploy
          @facts.createFactsHash @opt.json[0], false
          exit
        else
          puts "you have to put more options"
        end
      end

      #
      # with --host option you can handle all the 
      # deploy steps by phase. 
      #
      if @opt.host
        puts "hostname to handle"
      end
    end
  end # class MainLogic
end

