#! /bin/bash

source srl.env

srl_a=$(echo $1 | awk -F: '{print $1}')
srl_a_int=$(echo $1 | awk -F: '{print $2}')
srl_b=$(echo $2 | awk -F: '{print $1}')
srl_b_int=$(echo $2 | awk -F: '{print $2}')

#echo "$srl_a port $srl_a_int connect to $srl_b port $srl_b_int"

# Basic verification
    if ! docker inspect $srl_a &>/dev/null; then
        echo "[ERROR] Container $srl_a doesn't exist"
        exit
    fi
    
    if ! docker inspect $srl_b &>/dev/null; then
        echo "[ERROR] Container $srl_b doesn't exist"
        exit
    fi
    
    if [[ ! $srl_a_int =~ ^e[1-9]\-[1-3]{0,1}[0-9]{0,1}$ ]]; then
        echo "[ERROR] $srl_a: Interface $srl_a_int has a wrong format"
        exit
    fi
    
    if [[ ! $srl_b_int =~ ^e[1-9]\-[1-3]{0,1}[0-9]{0,1}$ ]]; then
        echo "[ERROR] $srl_b: Interface $srl_b_int has a wrong format"
        exit
    fi
    
    if ip netns exec $srl_a ip link | grep $srl_a_int@ &>/dev/null; then
        echo "[ERROR] $srl_a: Interface $srl_a_int is busy"
        exit
    fi
    
    if ip netns exec $srl_b ip link | grep $srl_b_int@ &>/dev/null; then
        echo "[ERROR] $srl_b: Interface $srl_b_int is busy"
        exit
    fi

# Final confirmation    
    read -r -p "Do you want to create a virtual link? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            exit
            ;;
    esac

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
