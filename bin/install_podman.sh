#!/usr/bin/env bash

if ! command -v podman &> /dev/null; then
    echo "Podman not found, installing..."
    if ! sudo apt-get install -y podman; then
        echo "Failed to install podman"
        exit 1
    else
        echo "Podman installed."
    fi
else
    echo "Podman is already installed."
fi

podman machine init
podman machine start
podman --version