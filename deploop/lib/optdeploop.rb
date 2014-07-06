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


module OptionsParser
  class OptparseDeploop

    CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
    CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      options.json = []
      options.verbose = false
      options.output = false

      opt_parser = OptionParser.new do |opts|
        # a banner, displayed at the top of the help screen.
        opts.banner = "Usage: deploop [options]"

        opts.separator ""
        opts.separator "Specific options:"

        # Define the options, and what they do
        
        #  
        # JSON cluster operations
        #
        
        opts.on("-j", "--json",
                "Deploop output formating in JSON") do |j|
          options.output = true
        end

        opts.on("-f", "--file CLUSTER_SCHEMA",
                "Require the JSON file describing your cluster for deploy") do |file|
          options.json << file
        end

        # sanity checking the syntax of JSON file
        opts.on("--check", "Check JSON file consistency") do |check|
          options.check = check
        end

        # Show facts per host:
        #
        # Example: 
        # deploop -f cluster.json --show
        #
        opts.on("--show", "Show facts in JSON cluster schema") do |show|
          options.show = show
        end

        # Deploy from scratch a layer
        #
        # Example:
        # deploop --deploy batch,bus
        #
        opts.on("--deploy batch,speed,bus,serving", Array, "Deploy a cluster layer") do |deploy|
          options.deploy = deploy
        end

        # Execute --deploy disanbling the deploop
        # facts phase.
        #
        # Example:
        # deploop --deploy batch --facts 
        #
        opts.on("--nofacts", "skip facts deploying") do |nofacts|
          options.nofacts = nofacts
        end

        # Execute --deploy disanbling the puppet
        # run phase.
        #
        # Example:
        # deploop --deploy batch --facts --norun
        opts.on("--norun", "skip puppet runs") do |norun|
          options.norun = norun
        end

        # Execute --deploy with the only phase
        # puppet run, after that exit the program.
        #
        # Example:
        # deploop --deploy batch --facts --onlyrun
        #
        opts.on("--onlyrun", "skip puppet runs") do |onlyrun|
          options.onlyrun = onlyrun
        end

        # This parameter is for cluster operations
        # when the cluster is already deployed.
        #
        # Example:
        # deploop --layer batch --start
        # deploop --layer batch --stop
        #
        opts.on("--layer batch,speed,bus,serving", Array, "Define cluster for operation") do |layer|
          options.layer = layer
        end

        opts.on("--start", "Start a cluster layer") do |operation|
          options.operation = 'start'
        end

        opts.on("--stop", "Stop a cluster layer") do |operation|
          options.operation = 'stop'
        end

        # This parameter is for enable Kerberos or
        # disable Kerberos when the cluster is already deployed.
        #
        # Example:
        # deploop --layer batch --kerberos
        # deploop --layer batch --nokerberos
        #
        opts.on("--kerberos", "print batch topology") do |kerberos|
          options.kerberos = kerberos
        end

        opts.on("--nokerberos", "print batch topology") do |nokerberos|
          options.nokerberos = nokerberos
        end

        # Get information from Hadoop cluster for testing.
        #
        # Example:
        # deploop --topology
        # deploop --report
        #
        opts.on("--topology", "print batch topology") do |topo|
          options.topology = topo
        end

        opts.on("--report", "print batch topology") do |report|
          options.report = report
        end

        # List of arguments.
        opts.on("-c", "--fact HOSTNAME", Array, "Example 'list' of arguments") do |fact|
          options.fact = fact
        end

        #
        # Operations around a hostname
        #
        opts.on("-h", "--host HOSTNAME", "hostname to handle") do |host|
          options.host = host
        end

        opts.on("-s", "--status HOSTNAME", "hostname to handle") do |status|
          options.status = status
        end

        #
        # Generic options.
        #
        # Boolean switch.
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options.verbose = v
        end

        # Testing for rails
        opts.on("-t", "--test", Array, "Run error or output test") do |t|
          options.test = t
        end

        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts $VERSION 
          exit
        end
      end

      opt_parser.parse!(args)
      options
    end  # parse()
 end  # class OptparseExample
end


