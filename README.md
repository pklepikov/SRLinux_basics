# Basic SRL demo
## Run a standalone SRL container.

1. Copy the SRL inmage X.Y.Z-N.tar.xz file into Project directory on Centos 8 Host Machine.
    - Out of scope
2. Copy the license.key into Project directory.
    - Out of scope
3. Load the docker image. To load the image, the user must have root privilege, or be part of the docker group.
    ```bash
    docker image load -i 20.6.1-286.tar.xz
    ```
4. Check that the docker image was imported correctly:
    ```bash
    docker images
    REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
    srlinux                        20.6.1-286          79019d14cfc7        3 weeks ago         1.32GB
    ```
5. Deploy a SRL container
    - [01.start_srl_a.sh](01.start_srl_a.sh)
    - [02.start_srl_b.sh](02.start_srl_b.sh)
    ```
    docker run -t -d --rm --privileged \
    --sysctl net.ipv6.conf.all.disable_ipv6=0 \
    --sysctl net.ipv4.ip_forward=0 \
    --sysctl net.ipv6.conf.all.accept_dad=0 \
    --sysctl net.ipv6.conf.default.accept_dad=0 \
    --sysctl net.ipv6.conf.all.autoconf=0 \
    --sysctl net.ipv6.conf.default.autoconf=0 \
    -u $(id -u):$(id -g) \
    -v $SRL_LICENSE:/opt/srlinux/etc/license.key:ro \
    --name $SRL_NAME srlinux:20.6.1-286 \
    bash -c 'sudo opt/srlinux/bin/sr_linux'
    ```
6. Check if container runs
    ```bash
    docker ps
    CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS               NAMES
    2919c2a3705d        srlinux:20.6.1-286   "/tini -- fixuid -q …"   4 minutes ago       Up 3 minutes                            srlinux_dut1
    ```

7. Find mgmt IP address
    ```
    SRL_NAME='srlinux_dut1'
    docker inspect $SRL_NAME  --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}"
    172.17.0.2
    ```
8. Access SRL CLI (via SSH or via 'Console')

    ```
    docker exec -ti srlinux_dut1 sr_cli
    ```
    
## Add a virtual link between containers

1. Create usable names for Namespaces
    - [11.create_namespaces.sh](11.create_namespaces.sh)
    ```bash
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
    ```
2. Create VETH links and glue them to SRL containers
    - [12.create_virtual_link.sh](12.create_virtual_link.sh)
    - Note: SRL requires a special naming for the interfaces
    ```bash
    # Create VETH connection between $srl_a and $srl_b containers
        ip link add tmp_a type veth peer name tmp_b
        ip link set tmp_a netns $srl_a
        ip link set tmp_b netns $srl_b
        ip netns exec $srl_a ip link set tmp_a name $srl_a_int
        ip netns exec $srl_b ip link set tmp_b name $srl_b_int
        ip netns exec $srl_a ip link set $srl_a_int up
        ip netns exec $srl_b ip link set $srl_b_int up
    # Disable Offload option for both container
        docker exec -ti $srl_a ethtool --offload $srl_a_int rx off tx off
        docker exec -ti $srl_b ethtool --offload $srl_b_int rx off tx off
    ```
## Configuration
- Interface IP
    - [DUT_1: Assign IPv4 to interface 1/1.0](./config/srl_dut_1.cfg)
    - [DUT_2: Assign IPv4 to interface 1/1.0](./config/srl_dut_2.cfg)
