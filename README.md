# winvnc

Ubuntu based docker image for running VNC server on browser.

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
    -p 8080:8080/tcp \
    --memory="1g" \
    --memory-swap="2g" \
    --cpus="1.0" \
    -e VNC_PASSWORD="VNC_PASSWORD" \
    -e HTTP_PORT=8080 \
    -e VNC_RESOLUTION=1920x1080 \
    -e VNC_DEPTH=24 \
    -e TZ=UTC \
    winvnc:latest
```