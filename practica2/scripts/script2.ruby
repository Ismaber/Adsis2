#!/usr/bin/env ruby

require "net/ssh"

def execute(ssh, command, target = "")
	result = ssh.exec!("virsh -c qemu:///system #{command} #{target}")
	puts result
end

def option(command, flags, ssh, lines)
	if flags == 'all'
		lines.each do |host|
			execute(ssh, command, host)
		end
	else
		execute(ssh, command, host)
	end
end

if ARGV.length != 0
	host = "155.210.154.#{ARGV[0]}"
	username = 'a796902'

	hostnames = File.read("maquinas.txt")
	lines = hostnames.split("\n")

	Net::SSH.start(host, username) do |ssh|
		if ARGV[1] == 'e'
			option("start", ARGV[2], ssh, lines)
		elsif ARGV[1] == 'a'
			option("shutdown", ARGV[2], ssh, lines)
		elsif ARGV[1] == 'u'
			option("undefine --domain", ARGV[2], ssh, lines)
		elsif ARGV[1] == 'l'
			execute(ssh, "list --all")
		else
			puts "Parámetros incorrectos"
			puts "script2.ruby [n_maquina] [opcion] [flags] "
		end
		ssh.close
	end
else
	puts "Parámetros incorrectos"
    puts "script2.ruby [n_maquina] [opcion] [flags] "
end
