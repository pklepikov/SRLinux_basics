#! /bin/bash

source srl.env

# Create VETH connection between $srl_a and $srl_b containers
    ip link add tmp_a type veth peer name tmp_b
    ip link set tmp_a netns $srl_a
    ip link set tmp_b netns $srl_b
    ip netns exec $srl_a ip link set tmp_a name $srl_a_int
    ip netns exec $srl_b ip link set tmp_b name $srl_b_int
    ip netns exec $srl_a ip link set $srl_a_int up
    ip netns exec $srl_b ip link set $srl_b_int up

# Verify newely created interfaces
    docker exec -ti $srl_a ip link
    echo
    docker exec -ti $srl_b ip link

#Disable Offload option for both container
    docker exec -ti $srl_a ethtool --offload $srl_a_int rx off tx off
    docker exec -ti $srl_b ethtool --offload $srl_b_int rx off tx off
