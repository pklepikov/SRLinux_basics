source srl.env

# Delete containers
    docker rm $srl_a -f
    docker rm $srl_b -f

# Delete Namespaces
    ip netns delete $srl_a
    ip netns delete $srl_b
