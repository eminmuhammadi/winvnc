FROM ubuntu:jammy as winvnc_base

USER root
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends \
    # xfce4 desktop environment
    supervisor xfce4 xfce4-goodies x11vnc xvfb xpra \
    # OpenSSH server
    openssh-server openssh-client tzdata vim-tiny \
    # Common packages
    gnupg gnupg2 gnupg1 wget tar curl git build-essential bc\
    software-properties-common net-tools ca-certificates locales locales-all \
    python3 python3-pip python3-numpy\
    # Install firefox
    && add-apt-repository ppa:mozillateam/ppa \
    && apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends \
    -t 'o=LP-PPA-mozillateam' firefox \
    && mkdir -p /etc/firefox \
    && echo 'pref("browser.tabs.remote.autostart", false);' >> /etc/firefox/firefox.js \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install WineHQ
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends winehq-staging winetricks \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# GStreamer plugins
RUN apt-get update -y && \
    apt-get install -y --install-recommends \
    libgl1-mesa-glx libgl1-mesa-dri \
    gstreamer1.0-libav:i386 \
    gstreamer1.0-plugins-bad:i386 \
    gstreamer1.0-plugins-base:i386 \
    gstreamer1.0-plugins-good:i386 \
    gstreamer1.0-plugins-ugly:i386 \
    gstreamer1.0-pulseaudio:i386 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install PyOpenGL PyOpenGL_accelerate

# Install noVNC
ARG NOVNC_VERSION=1.4.0-beta
ENV NOVNC_VERSION=${NOVNC_VERSION}
RUN mkdir -p /root/.novnc \
    && wget https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz -O /root/.novnc/novnc.tar.gz \
    && tar -xzf /root/.novnc/novnc.tar.gz -C /root/.novnc \
    && rm /root/.novnc/novnc.tar.gz \
    && mkdir -p /usr/share/novnc \
    && mkdir -p /usr/share/novnc/app \
    && mkdir -p /usr/share/novnc/core \
    && mkdir -p /usr/share/novnc/vendor \
    && cp -r /root/.novnc/noVNC-${NOVNC_VERSION}/app/* /usr/share/novnc/app \
    && cp -r /root/.novnc/noVNC-${NOVNC_VERSION}/core/* /usr/share/novnc/core \
    && cp -r /root/.novnc/noVNC-${NOVNC_VERSION}/vendor/* /usr/share/novnc/vendor \
    && cp /root/.novnc/noVNC-${NOVNC_VERSION}/vnc.html /usr/share/novnc/vnc.html \
    && cp /root/.novnc/noVNC-${NOVNC_VERSION}/vnc_lite.html /usr/share/novnc/vnc_lite.html \
    && cp /root/.novnc/noVNC-${NOVNC_VERSION}/package.json /usr/share/novnc/package.json

# Enable SSH root login
ARG VNC_PASSWORD=weakpassword
ENV VNC_PASSWORD=${VNC_PASSWORD}
ENV TZ=${TZ}
ARG TZ=UTC
RUN sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config \
    && sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && mkdir -p /root/.ssh \
    && ssh-keygen -t ed25519 -f "/root/.ssh/id_ed25519" -N '' \
    && cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    # Generate SSL certificate for noVNC
    && openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
    -keyout /etc/ssl/certs/novnc.pem \
    -out /etc/ssl/certs/novnc.pem \
    -subj "/C=US/ST=California/L=San Francisco/O=IT/CN=localhost"

ADD ./src/supervisord.conf /root/supervisord.conf

ADD ./src/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Default Settings
ARG VNC_RESOLUTION=1920x1080
ARG VNC_DEPTH=24
ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443
ENV VNC_RESOLUTION=${VNC_RESOLUTION}
ENV VNC_DEPTH=${VNC_DEPTH}
ENV HTTP_PORT=${HTTP_PORT}
ENV HTTPS_PORT=${HTTPS_PORT}

CMD ["bash", "/usr/local/bin/startup.sh"]

EXPOSE ${HTTP_PORT}
EXPOSE ${HTTPS_PORT}