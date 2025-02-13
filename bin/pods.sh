#!/usr/bin/env bash

if [[ "$DEBUG" == 1 ]]; then
	set -x
fi

if ! ./bin/install_podman.sh; then
    echo "Failed to install podman"
    exit 1
fi

network_name="network-$(date +%s)"
echo "Creating network: $network_name"

podman network create "$network_name"

node_qty=3
for i in $(seq 1 $node_qty); do
    name="node-$i"
    port=8$(printf "%03d" "$i")
    nodes+=("$name")
    podman run -d \
        --name "$name" \
        -p "$port":"$port" \
        --privileged \
        --env CONTAINER_NAME="$name" \
        --env PORT="$port" \
        --network "$network_name" \
        --volume ./shared:/shared \
        ubuntu bash -c \
            "chmod +x /shared/init.sh; \
            ./shared/init.sh; sleep infinity"
done
trap 'kill_all' EXIT INT

# prxy_qty=1


# # Run three Ubuntu containers and connect them to the network
# podman run -d \
#     --name inside \
#     --env CONTAINER_NAME=$container_name \
#     --network "$network_name" \
#     --volume ./shared:/shared \
#     ubuntu bash -c \
#     "chmod +x /shared/init.sh; ./shared/init.sh; python3 -m http.server 8888 --directory /shared; sleep infinity"

kill_all () {
    echo "Stopping and removing containers and networks, this may take a few seconds..."
    for node in "${nodes[@]}"; do
        stop_rm "$node" &
    done
    wait # don't kill network until all nodes are stopped
    podman network rm "$network_name"
}

stop_rm () {
    podman stop "$1" && podman rm "$1"
}

wait_for_start() {
    started=$(date +%s)
    nodes_qty=${#nodes[@]}
    # echo "nodes ($nodes_qty): ${nodes[*]}"
    nodes_up=0
    for container_name in "${nodes[@]}"; do
        if podman ps -a | grep -q container_name; then
            ((nodes_up++))
            echo "$container_name is running."
            if ((nodes_up == nodes_qty)); then
                echo "All containers are running."
                break
            fi
        fi    
    done
    now=$(date +%s)
    elapsed=$((now - started))
    echo "${elapsed}s - Waiting for containers to start... ($nodes_up of $nodes_qty)"
    sleep 1
}

wait_for_start
echo "All containers are running:"
podman ps -a
echo "Login to a node with:"
echo "  podman exec -it <node> bash"
sleep 600
