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

port=8001 # TODO use env var
mkdir -p /self
echo "Hello, world! I'm $CONTAINER_NAME!" > /self/me.txt
info "starting http server at port $port"
if ! python3 -m http.server "$port" --directory "/self"; then
    error "python3 -m http.server failed"
fi
