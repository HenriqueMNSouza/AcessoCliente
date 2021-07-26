#!/bin/bash

path_conf =''
ssh_pass=''
ssh_port=''
ssh_user=''

conf="$path_conf/conf.txt"
opts=()
nomes=()
ips=()

read_config_file(){
	while read line; 
	do 
		for i in $(echo $line | tr "<>" '\n')
		do
			opts+=("$i")
		done
	done < $conf 
}

organize_opts(){
	count=0
	for value in "${opts[@]}"
	do
		if [ $(($count%2)) == 0  ] ; then
			nomes+=("$value")
		else
			ips+=("$value")
		fi
		count=$((count+1))
	done
}

print_opts(){
	count=1
	echo 'Enter client number:'
	for nome in "${nomes[@]}" 
	do
		echo "$count - $nome"
		count=$((count+1))
	done
}


exec_for_opt(){
	ip=${ips[$1]}

	ref="sshpass -p '$ssh_pass' ssh $ssh_user@localhost -p $ssh_port -o 'StrictHostKeyChecking no' -o TCPKeepAlive=yes -o ServerAliveInterval=10 -L22080:$ip:80  -L22022:$ip:22 "

	echo "Comando: $ref"

	eval $ref
}

load_config_file(){
	read_config_file
    organize_opts
}

main(){
	load_config_file
	print_opts

	read iopt
	#Como a contagem de array comeca em 0...
	iopt=$((iopt-1))

	exec_for_opt $iopt
}

main