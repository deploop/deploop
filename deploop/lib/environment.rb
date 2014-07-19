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

require 'erb'

module ExtLookup
  class CSVExtLookup
    def initialize(arg1, arg2)
      @csvfile_template = File.read('templates/site.csv.erb')
      @arg1 = arg1;  @arg2 = arg2
      renderTemplate
    end

    def renderTemplate()
      template = ERB.new @csvfile_template
      template.result
    end
  end # class ExtLookup
end



