#!/bin/bash
set -euo pipefail

IP='172.20.0.21'
VERSION='0.1.0'

image="minecraft:$VERSION"

docker image build --tag "$image" .

docker run \
    --rm \
    --name 'minecraft-dev' \
    --volume /opt/minecraft-dev:/app \
    --network='opt_unicumnet' \
    -ti \
    --ip "$IP" \
    --workdir /app \
    "$image" \
    '/minecraft-init.py'
