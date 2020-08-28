#! /bin/bash

source srl.env

if [[ ! -f .srl.running ]]; then
    echo "[INFO] Nothing to delete"
    exit
fi

# Read '.srl.running' file and delete container, namespace, cnf directory
while IFS= read -r srl_name; do
    echo "[INFO] deleting $srl_name"
    docker rm $srl_name -f 2>/dev/null
    ip netns delete $srl_name 2>/dev/null
    read -r -p "[WARNING] Delete \"$srl_name\" configuration files? [y/N]: " response </dev/tty
    case "$response" in
        [yY][eE][sS]|[yY])
            rm -rf cfg/$srl_name
            ;;
        *)
            ;;
    esac
done < .srl.running
rm -rf .srl.running

