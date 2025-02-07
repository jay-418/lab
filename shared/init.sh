#!/usr/bin/env bash

# Setup an Ubuntu container with required tools,
# writing logs to a shared volume

error() {
    echo "$(ts)" ERR "[$CONTAINER_NAME]" "$1" >> /shared/"$CONTAINER_NAME.log"
    exit 1
}

info() {
    echo "$(ts)" INF "[$CONTAINER_NAME]" "$1" >> /shared/"$CONTAINER_NAME.log"
}

ts() {
    date +"%Y-%m-%d.%H:%M:%S"
}

info "starting $0"

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

info "init complete"

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
