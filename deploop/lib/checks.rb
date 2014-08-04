# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
#
## Licensed to the Apache Software Foundation (ASF) under one
## or more contributor license agreements. See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership. The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License. You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied. See the License for the
## specific language governing permissions and limitations
## under the License.
#
# == checkJson.rb
# == Contact
#
# Author:: Juan Carlos Fernandez <jcfernandez@redoop.org>
# Date:: 29-07-2014
#
require 'json'
require 'json-schema'
module Checks
  class CheckJson 

    def initialize(file, schema = ENV['DPROOT'] + "/conf/conf.schema")
      @file = file
      @schema = schema
      @errors = []
      @fatal_error = false
      @json = nil
    end

    def fatal()
      return @fatal_error
    end

    def loadJson()
      return @json
    end

    def check()
      if !File.exist?(@file)
        @errors += [{"severity" => "FATAL", "message" => "Json file doesn't exists"}]
        @fatal_error = true
      elsif !File.exist?(@schema)
        @errors += [{"severity" => "FATAL", "message" => "Json schema doesn't exists"}]
        @fatal_error = true
      else
        begin
          configuration = File.read(@file)
          validation = JSON::Validator.fully_validate(@schema,configuration)
          parsed_obj = JSON.parse(configuration)
        rescue SystemCallError => e
          errors += [{ "severity" => "FATAL", "message" => e.message}]
          @fatal_error = true
        rescue JSON::ParserError => e
          errors += [{ "severity" => "FATAL", "message" => "JSON file parsing error"}]
          @fatal_error = true
        end

        #if !@fatal_error 
        #  hostnames = get_hostnames_roles(parsed_obj)
        #  hostnames.each do |host, roles|
        #    if roles.size > 1
        #      @errors += [{"severity" => "FATAL", 
        #        "message" => "Only one rol could be applied by hostname. Host: " + 
        #        host + ", Roles: " + roles.to_s }]
        #      @fatal_error = true
        #    end
        #  end
        #end

      end
      if @errors.size == 0
        @json = parsed_obj
      end
      return @errors
    end

   private def get_hostnames_roles(parsed_obj)
      hosts_roles = Hash.new([])
      parsed_obj['cluster_layout'].each do |layer_key, layer_val|
        case layer_key
        when "name"
          next
        when "batch"
          layer_val.each do |rol, hosts|
            case rol
            when 'nn1','nn2','rm'
              hosts_roles[hosts['hostname']] += [rol]
            when 'dn'
              for host in hosts 
                hosts_roles[host['hostname']] += [rol]
              end
            end
          end
        when "bus","speed","serving"
          for host in layer_val['worker'] 
            hosts_roles[host['hostname']] += ['worker']
          end
          if layer_key == "bus"
            next
          else
            hosts_roles[layer_val['master']['hostname']] += ['master']
          end
        end
      end
      return hosts_roles
    end

  end
end
