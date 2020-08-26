# Get
```
gnmic \
    --config gnmiClient_srl.yaml \
    get --path "/system/gnmi-server/admin-state"
```
```
gnmic \
    --config gnmiClient_srl.yaml \
    get --path "/network-instance[name=default]/interface[name=ethernet*]"
```
```
gnmic \
    --config gnmiClient_srl.yaml \
    get --path "/network-instance[name=default]/interface[name=ethernet*]/oper-state"
```
```
gnmic \
    --config gnmiClient_srl.yaml \
    get --path "/interface[name=ethernet-1/1]/subinterface[index=1]/admin-state"
```
# Subscribe
```
gnmic \
    --config gnmiClient_srl.yaml \
    subscribe  --path "/interface[name=ethernet-1/1]/traffic-rate"
```