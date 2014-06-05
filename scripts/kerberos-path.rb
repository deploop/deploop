#!/usr/bin/env ruby
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
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed
#
# Software:
# rvm install ruby-2.1.1
# rvm use 2.1.1
# gem install mcollective-client

require 'open3'
require 'fileutils'
require 'socket'
require "mcollective"

include MCollective::RPC

def runCommand(cmd)
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdout.each_line { |line| puts line }
  end
end

def sanityChecking()
  # $min_release  = '1.8.7 (2011-06-30)'
  $min_release  = '2.1.1 (2014-02-24)'
  $ruby_release = "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE})"
  if $ruby_release != $min_release
    abort "This program requires Ruby version #{$min_release}.
    You're running #{$ruby_release}; please upgrade to continue."
  end
  puts "The Marionette Collective version #{MCollective.version}"
end

sanityChecking

# kerberos
$principals=['hdfs', 'yarn', 'mapred', 'HTTP', 'vagrant', 'zookeeper', 'flume', 'oozie']
$realm='DEPLOOP.ORG'
$security_path='/var/kerberos/principals'
$adm_keytab='/root/deploop.keytab'
$adm_princ='deploop/admin'
$kdm='/usr/bin/kadmin'

# mcollective
$mc = rpcclient "rpcutil"
$mc.compound_filter 'deploop_collection=/.*/'
$nodes = $mc.discover

puts "Creating keytab per node: "

FileUtils::mkdir_p $security_path

# each node in mcollective discover
$nodes.each do |h| 

  fqdn = Socket.gethostbyname(h)[0]
  # each principal in kerberos
  FileUtils::mkdir_p $security_path + '/' + fqdn
  $principals.each do |p|
    $cmds = ["#{$kdm} -kt #{$adm_keytab} -p #{$adm_princ} \
      -q \'delprinc -force #{p}/#{fqdn}.#{$realm.downcase}@#{$realm}\'",
    "#{$kdm} -kt #{$adm_keytab} -p #{$adm_princ} \
      -q \'ank -randkey #{p}/#{fqdn}.#{$realm.downcase}@#{$realm}\'",
    "#{$kdm} -kt #{$adm_keytab} -p #{$adm_princ} \
      -q \'xst -k #{$security_path}/#{fqdn}/#{p}.keytab #{p}/#{fqdn}.#{$realm.downcase}@#{$realm}\'",
    "#{$kdm} -kt #{$adm_keytab} -p #{$adm_princ} \
      -q \'xst -k #{$security_path}/#{fqdn}/#{p}.keytab HTTP/#{fqdn}.#{$realm.downcase}@#{$realm}\'"]

    # each command per principal
    $cmds.each do |c|
      puts c
      cmd = c
      runCommand cmd
    end
  end
end


