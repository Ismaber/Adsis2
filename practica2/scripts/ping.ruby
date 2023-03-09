#!/usr/bin/env ruby

require 'net/ping'

hostnames = File.read("lab102.txt")
lines = hostnames.split("\n")

lines.each_line do |host|
    check = Net::Ping::External.new(host)
    check.ping?
end