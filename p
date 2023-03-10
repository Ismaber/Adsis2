#!/usr/bin/env ruby

require 'net/ping'

#direcciones
host_file = File.expand_path("hosts.txt", ".u")
hostnames = File.read(host_file)
lines = hostnames.split("\n")

#colores
rojo = "\033[1;31m"
verde = "\033[1;32m"

def putColor(color, host, linea)
	reset = "\033[0m"
	puts "#{host} #{color}#{linea}#{reset}"
end

time = 0.5
puts "Timeout: #{time}"
lines.each do |hostname|
	ping = Net::Ping::TCP.new(hostname, 22, time) 

	if ping.ping?
		putColor(verde, hostname, "FUNCIONA")
	else
		putColor(rojo, hostname, "FALLA")
	end
end