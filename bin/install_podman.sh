#!/usr/bin/env bash

sudo apt-get install -y podman
podman machine init
podman machine start
podman --version