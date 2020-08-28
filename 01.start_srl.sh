#! /bin/bash

source srl.env
touch .srl.running

# Basic verification for mandatory and optional arguments
    if [ ! $1 ]; then
        echo "[CRITICAL ERROR] Expected use of command: ./${0##*/} <name> [<name>]"
        echo "[INFO] Mandatory field <name> is missing"
        exit
    fi

# Iterate all arguments
    for arg in "$@"; do
        srl_name=$arg
        srl_config="$(pwd)/cfg/$arg"
        
        mkdir -p $srl_config 2>/dev/null
        chmod 777 $srl_config
        
        # Create SRL container
            docker run -t -d --rm --privileged \
            --sysctl net.ipv6.conf.all.disable_ipv6=0 \
            --sysctl net.ipv4.ip_forward=0 \
            --sysctl net.ipv6.conf.all.accept_dad=0 \
            --sysctl net.ipv6.conf.default.accept_dad=0 \
            --sysctl net.ipv6.conf.all.autoconf=0 \
            --sysctl net.ipv6.conf.default.autoconf=0 \
            -u $(id -u):$(id -g) \
            -v $srl_license:/opt/srlinux/etc/license.key:ro \
            -v $srl_config:/etc/opt/srlinux/:rw \
            --name $srl_name srlinux:20.6.1-286 \
            bash -c 'sudo opt/srlinux/bin/sr_linux'
        
        # Populate /etc/hosts file
            srl_ip=$(docker inspect $srl_name --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}")
            sed -i "/${srl_name}/d" /etc/hosts
            echo "${srl_ip} ${srl_name}" >> /etc/hosts

	# Create DIR
            mkdir -p /run/netns/ 2>/dev/null

        # Get container PID and create a soft link for userfriendly CLI
            srl_pid=$(docker inspect $srl_name  --format "{{json .State.Pid}}")
            ln -s /proc/$srl_pid/ns/net /run/netns/$srl_name

	# Report
	    echo -e "[INFO] name=$srl_name; pid=$srl_pid; mgmt_ip=$srl_ip"
	    echo $srl_name >> .srl.running
    done
