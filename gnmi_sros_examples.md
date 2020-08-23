# Subscribe example
```
gnmic \
    --config gnmiClient_sros.yaml 
    subscribe \
    --path /state/port[port-id=1/1/c1/1]/statistics/in-packets
```
