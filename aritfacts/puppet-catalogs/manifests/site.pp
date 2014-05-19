# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base configuration variables

$extlookup_datadir="/etc/puppet/manifests/extdata"
$extlookup_precedence = ["site", "default"]

# defaults
$puppetserver = 'mncarsnas.condor.local'
$jdk_package_name = extlookup("jdk_package_name", "jdk")
$default_buildoop_yumrepo_uri = "http://192.168.33.1:8080/"

# Base resources for all servers
case $::operatingsystem {
	 /(CentOS|RedHat)/: {
	yumrepo { "buildoop":
   		baseurl => extlookup("buildoop_yumrepo_uri", $default_buildoop_yumrepo_uri),
   		descr => "Buildoop Hadoop Ecosystem",
   		enabled => 1,
   		gpgcheck => 0,
	}
      }
      default: {
	 notify{"WARNING: running on a non-yum platform -- make sure Buildoop repo is setup": }
      }
}
	
package { $jdk_package_name:
	ensure => "installed",
	alias => "jdk",
}

exec { "yum makecache":
  command => "/usr/bin/yum makecache",
  require => Yumrepo["buildoop"]
}

import "nodes.pp"

# Server node roles available:
#   NameNodes
#   ResourceManager
#   Client
#   Gateway
#   HistoryServer
#   Workers
node default {
	case $::deploop_collection {
    "batch": {
      info("Node in BATCH collection: ${fqdn}")
    }
    "realtime": {
      info("Node in REALTIME collection ${fqdn}")
    }
    default: {
    		    info("uncategorized node ${fqdn}")
    }
  }
}

# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
