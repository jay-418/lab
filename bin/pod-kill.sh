#!/usr/bin/env bash

read -p "Are you sure you want to kill absolutely everything? (y/n) " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo; echo "Killing everything..."
    podman rm "$(podman ps -a | grep node | awk '{print $1}' | xargs)"
    podman network rm "$(podman network ls | grep network | awk '{print $2}' | xargs)"
fi
