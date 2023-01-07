FROM --platform=amd64 ubuntu:jammy as winvnc_base

USER root
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

# Set build arguments
ARG VNC_RESOLUTION=1920x1080
ARG VNC_DEPTH=24
ARG HTTP_PORT=8080
ARG TZ=UTC

# Set environment variables
ENV VNC_RESOLUTION=${VNC_RESOLUTION}
ENV VNC_DEPTH=${VNC_DEPTH}
ENV HTTP_PORT=${HTTP_PORT}
ENV TZ=${TZ}

# Install base packages
RUN apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends \
    # VNC packages
    supervisor xfce4 xfce4-goodies x11vnc xvfb \
    # OpenSSH server
    openssh-server openssh-client tzdata vim-tiny \
    # Install firefox
    software-properties-common net-tools \
    && add-apt-repository ppa:mozillateam/ppa \
    && apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends \
    -t 'o=LP-PPA-mozillateam' firefox \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install WineHQ
RUN apt-get update --fix-missing --install-recommends \    
    && apt-get install -y gnupg gnupg2 gnupg1 wget --fix-missing --install-recommends \
    && dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends winehq-stable winetricks \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN apt-get update --fix-missing --install-recommends \
    && apt-get install -y --fix-missing --install-recommends \
    novnc python3-websockify python3-numpy \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Password for root user
ARG VNC_PASSWORD=weakpassword
ENV VNC_PASSWORD=${VNC_PASSWORD}

# Enable SSH root login
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
    -subj "/C=US/ST=Denial/L=Springfield/O=winvnc/CN=localhost" 

ADD ./src/supervisord.conf /root/supervisord.conf

ADD ./src/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

CMD ["bash", "/usr/local/bin/startup.sh"]

EXPOSE ${HTTP_PORT}