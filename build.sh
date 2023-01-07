#!/bin/env bash

random_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

docker -D build \
    --compress \
    -t winvnc \
    --build-arg VNC_PASSWORD=$random_password \
    -f ./Dockerfile \
    ./