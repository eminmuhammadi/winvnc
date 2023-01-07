#!/bin/env bash

random_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo $random_password > .passwd

HTTP_PORT=8080

# Run the container
# --gpus all  For GPU support
docker run -it --rm \
    --name winvnc \
    -p $HTTP_PORT:$HTTP_PORT/tcp \
    --memory="1g" \
    --memory-swap="2g" \
    --cpus="1.0" \
    -e VNC_PASSWORD=$random_password \
    -e HTTP_PORT=$HTTP_PORT \
    winvnc:latest