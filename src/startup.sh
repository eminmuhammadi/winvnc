#!/bin/bash

set -e

# Start SSH server
mkdir -p /var/run/sshd

# Start supervisord
/usr/bin/supervisord -c /root/supervisord.conf

for i in {1..10}; do
    if [ $i -eq 10 ]; then
        cat /var/log/sshd.err
        exit 1
    fi

    if netstat -tulpn | grep :40022; then
        break
    fi

    sleep 1
done

for i in {1..10}; do
    if [ $i -eq 10 ]; then
        cat /var/log/x11vnc.err
        cat /var/log/reverse_ssh.err
        exit 1
    fi

    if netstat -tulpn | grep :45900; then
        break
    fi

    sleep 1
done

for i in {1..10}; do
    if [ $i -eq 10 ]; then
        cat /var/log/novnc_http.err
        exit 1
    fi
    
    if netstat -tulpn | grep :$HTTP_PORT; then
        echo "winvnc is available at http://$HOSTNAME:$HTTP_PORT/vnc.html?password=$VNC_PASSWORD"
        break
    fi
    sleep 1
done

for i in {1..10}; do
    if [ $i -eq 10 ]; then
        cat /var/log/novnc_https.err
        exit 1
    fi

    if netstat -tulpn | grep :$HTTPS_PORT; then
        echo "winvnc is available at https://$HOSTNAME:$HTTPS_PORT/vnc.html?password=$VNC_PASSWORD"
        break
    fi
    sleep 1
done

# Sleep forever
while true; do sleep 1000; done