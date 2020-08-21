source srl.env

srl_name=$srl_b

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
    --name $srl_name srlinux:20.6.1-286 \
    bash -c 'sudo opt/srlinux/bin/sr_linux'

# Populate /etc/hosts file
    srl_ip=$(docker inspect $srl_name --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}")
    sed -i "/${srl_name}/d" /etc/hosts
    echo "${srl_ip} ${srl_name}" >> /etc/hosts

