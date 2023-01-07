# winvnc

Ubuntu based docker image for running secure VNC server on browser.

## Building locally

```bash
git clone https://github.com/eminmuhammadi/winvnc.git && \
cd winvnc && \
chmod +x build.sh && bash build.sh
```

## Simple usage

```bash
docker run -it --rm \
    --name winvnc \
    -p 80:8080/tcp \
    -p 443:8443/tcp \
    --memory="1g" \
    --memory-swap="2g" \
    --cpus="1.0" \
    -e VNC_PASSWORD=MY_WEAK_PASSWORD \
    -e HTTP_PORT=8080 \
    -e HTTPS_PORT=8443 \
    -e TZ=UTC \
    eminmuhammadi/winvnc:latest
```