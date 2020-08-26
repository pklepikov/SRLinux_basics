#! /bin/bash

source srl.env

# Create DIR
    mkdir -p /run/netns/
# Get container PID and create a soft link for userfriendly CLI
    container_name=$srl_a
    container_pid=$(docker inspect $container_name  --format "{{json .State.Pid}}")
    ln -s /proc/$container_pid/ns/net /run/netns/$container_name
    
    container_name=$srl_b
    container_pid=$(docker inspect $container_name  --format "{{json .State.Pid}}")
    ln -s /proc/$container_pid/ns/net /run/netns/$container_name

# Report
    ip netns
