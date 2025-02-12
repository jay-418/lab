#!/usr/bin/env bash

# Setup an existing Ubuntu container with required tools,
# writing logs and public keys to a shared volume

error() {
    echo "$(ts)" ERR "[$CONTAINER_NAME]" "$1" >> /shared/logs/"$CONTAINER_NAME.log"
    exit 1
}

info() {
    echo "$(ts)" INF "[$CONTAINER_NAME]" "$1" >> /shared/logs/"$CONTAINER_NAME.log"
}

reset() {
    echo "$(ts)" INF "[$CONTAINER_NAME]" "$1" > /shared/logs/"$CONTAINER_NAME.log"
}

ts() {
    date +"%Y-%m-%d.%H:%M:%S"
}

reset "starting $0"

# apt-get update
if ! apt-get update; then
    error "apt-get update failed"
fi
info "apt-get updated"

# curl
if ! apt-get install -y curl; then
    error "apt-get install curl failed"
fi
info "curl installed"

# python3
if ! apt-get install -y python3; then
    error "apt-get install python3 failed"
fi
info "python3 installed"

# ip
if ! apt-get install -y iproute2; then
    error "apt-get install iproute2 failed"
fi

# iw
if ! apt-get install -y iw; then
    error "apt-get install iw failed"
fi

# ping
if ! apt-get install -y iputils-ping; then
    error "apt-get install iputils-ping failed"
fi

# wireguard
if ! apt-get install -y wireguard; then
    error "apt-get install wireguard failed"
fi

# setup wireguard
# https://www.wireguard.com/quickstart/

# generate keys
if ! wg genkey | tee privatekey | wg pubkey > publickey; then
    error "wg genkey failed"
fi

info "wireguard keys generated: $(cat publickey)"
info "$(cat privatekey)"
cat publickey > "/shared/keys/$CONTAINER_NAME.pub"

ip link add wg0 type wireguard
number="${CONTAINER_NAME#node-}"
ip="10.0.0.$number/24"
ip addr add "$ip"
wg set wg0 private-key ./privatekey
ip link set wg0 up
info "wireguard setup complete"


# set all keys in /shared/keys as peers
# Add WireGuard peers
for pubkey_file in /shared/keys/node-*.pub; do
    pubkey=$(cat "$pubkey_file")
    info "adding allowed ip: $pubkey"
    wg set wg0 peer "$pubkey" allowed-ips 0.0.0.0/0
done



info "init complete"

## announce self
default=8000
if [ -z "$PORT" ]; then
    error "PORT env var not set, defaulting to $default. This could cause collisions!"
fi
PORT=${PORT:-$default}

mkdir -p /self
echo "Hello, world! I'm $CONTAINER_NAME!" > /self/whoami
info "starting http server at port $PORT"
if ! python3 -m http.server "$PORT" --directory "/self"; then
    error "python3 -m http.server failed"
fi
