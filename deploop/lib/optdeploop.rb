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

require_relative 'deployfacts'

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
      options.inplace = false
      options.encoding = "utf8"
      options.transfer_type = :auto
      options.verbose = true
      facts = DeployFacts::FactsDeployer.new

      opt_parser = OptionParser.new do |opts|
        # a banner, displayed at the top of the help screen.
        opts.banner = "Usage: deploop [options]"

        opts.separator ""
        opts.separator "Specific options:"

        # Define the options, and what they do
        
        # Mandatory argument.
        opts.on("-j", "--json CLUSTER_SCHEMA",
                "Require the JSON file describing your cluster for deploy") do |json|
          options.json << json
        end

        # Optional argument; multi-line description.
        opts.on("-i", "--inplace [EXTENSION]",
                "Edit ARGV files in place",
                "  (make backup if EXTENSION supplied)") do |ext|
          options.inplace = true
          options.extension = ext || ''
          options.extension.sub!(/\A\.?(?=.)/, ".")  # Ensure extension begins with dot.
        end

        # Cast 'delay' argument to a Float.
        opts.on("--delay N", Float, "Delay N seconds before executing") do |n|
          options.delay = n
        end

        # Cast 'time' argument to a Time object.
        opts.on("-t", "--time [TIME]", Time, "Begin execution at given time") do |time|
          options.time = time
        end

        # Cast to octal integer.
        opts.on("-F", "--irs [OCTAL]", OptionParser::OctalInteger,
                "Specify record separator (default \\0)") do |rs|
          options.record_separator = rs
        end

        # List of arguments.
        opts.on("--list x,y,z", Array, "Example 'list' of arguments") do |list|
          options.list = list
        end

        # Keyword completion.  We are specifying a specific set of arguments (CODES
        # and CODE_ALIASES - notice the latter is a Hash), and the user may provide
        # the shortest unambiguous text.
        code_list = (CODE_ALIASES.keys + CODES).join(',')
        opts.on("--code CODE", CODES, CODE_ALIASES, "Select encoding",
                "  (#{code_list})") do |encoding|
          options.encoding = encoding
        end

        # Optional argument with keyword completion.
        opts.on("--type [TYPE]", [:text, :binary, :auto],
                "Select transfer type (text, binary, auto)") do |t|
          options.transfer_type = t
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


