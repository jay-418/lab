#!/usr/bin/env bash

network_name="network-$(date +%s)"
echo "Creating network: $network_name"



podman network create "$network_name"


node_qty=3
for i in $(seq 1 $node_qty); do
    name="node-$i"
    nodes+=("$name")
    podman run -d \
        --name $name \
        -p 800"$i":800"$i" \
        --env CONTAINER_NAME="$name" \
        --network "$network_name" \
        --volume ./shared:/shared \
        ubuntu bash -c \
            "chmod +x /shared/init.sh; \
            ./shared/init.sh; sleep infinity"
done
trap 'kill_all' EXIT

# prxy_qty=1


# # Run three Ubuntu containers and connect them to the network
# podman run -d \
#     --name inside \
#     --env CONTAINER_NAME=$container_name \
#     --network "$network_name" \
#     --volume ./shared:/shared \
#     ubuntu bash -c \
#     "chmod +x /shared/init.sh; ./shared/init.sh; python3 -m http.server 8888 --directory /shared; sleep infinity"



wait_for_start() {
    nodes_qty=${#nodes[@]}
    echo "nodes ($nodes_qty): ${nodes[*]}"
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
    echo "Waiting for containers to start... ($nodes_up of $nodes_qty)"
    sleep 1
}
wait_for_start
echo "All containers are running:"

podman ps -a

# podman run -d --name proxy --network $network_name ubuntu sleep infinity
# podman run -d --name outside --network $network_name ubuntu sleep infinity

# # Log in to the 'inside' container
podman exec -it "${nodes[0]}" bash

kill_all () {
    echo "Stopping and removing containers, this may take a few seconds..."
    for node in "${nodes[@]}"; do
        podman stop "$node"
        podman rm "$node"
    done
    podman network rm "$network_name"
}

