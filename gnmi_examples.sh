# Get
gnmic \
    --config gnmiClient.yaml \
    get --path "/system/gnmi-server/admin-state"

gnmic \
    --config gnmiClient.yaml \
    get --path "/network-instance[name=default]/interface[name=ethernet*]"

gnmic \
    --config gnmiClient.yaml \
    get --path "/network-instance[name=default]/interface[name=ethernet*]/oper-state"

gnmic \
    --config gnmiClient.yaml \
    get --path "/interface[name=ethernet-1/1]/subinterface[index=1]/admin-state"

# Subscribe 
gnmic \
    --config gnmiClient.yaml \
    subscribe  --path "/interface[name=ethernet-1/1]/traffic-rate"

