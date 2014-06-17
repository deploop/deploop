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
        
        # Mandatory argument.
        opts.on("-j", "--json",
                "Deploop output formating in JSON") do |j|
          options.output = true
        end

        opts.on("-f", "--file CLUSTER_SCHEMA",
                "Require the JSON file describing your cluster for deploy") do |file|
          options.json << file
        end

       # Cast 'delay' argument to a Float.
        opts.on("--check", "Check JSON file consistency") do |check|
          options.check = check
        end

        # List of arguments.
        opts.on("--deploy batch,speed,bus", Array, "Example 'list' of arguments") do |deploy|
          options.deploy = deploy
        end

        # Boolean switch.
        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options.verbose = v
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
          puts ::Version.join('.')
          exit
        end
      end

      opt_parser.parse!(args)
      options
    end  # parse()
 end  # class OptparseExample
end


