#!/usr/bin/ruby

require 'rubygems'
require 'json'
require 'pp'

json = File.read('deploy.json')
obj = JSON.parse(json)

pp obj
