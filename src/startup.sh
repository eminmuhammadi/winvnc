#!/bin/bash

# Start SSH server
mkdir -p /var/run/sshd

# Start supervisord
/usr/bin/supervisord -c /root/supervisord.conf

# Info 
echo "winvnc running at https://0.0.0.0:$HTTP_PORT/vnc.html?password=$VNC_PASSWORD"

# Sleep forever
while true; do sleep 1000; done