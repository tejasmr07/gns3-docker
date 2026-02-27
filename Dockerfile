FROM ubuntu:22.04

LABEL maintainer="Tejas"
LABEL description="GNS3 Server - Dockerized for college labs (no VM needed)"

ENV DEBIAN_FRONTEND=noninteractive
ENV GNS3_VERSION=2.2.44

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    curl \
    wget \
    software-properties-common \
    dynamips \
    vpcs \
    ubridge \
    iproute2 \
    libpcap-dev \
    net-tools \
    openssh-client \
    telnet \
    && rm -rf /var/lib/apt/lists/*

# Install GNS3 server via pip (clean, version-pinned)
RUN pip3 install gns3-server==${GNS3_VERSION}

# ubridge needs setuid to create network interfaces
RUN which ubridge && chmod +s $(which ubridge) || true

# Create GNS3 directories
RUN mkdir -p /root/GNS3/projects \
             /root/GNS3/appliances \
             /root/GNS3/images/IOS \
             /root/GNS3/images/QEMU \
             /root/.config/GNS3

# Copy config and entrypoint
COPY config/gns3_server.conf /root/.config/GNS3/gns3_server.conf
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# GNS3 server port
EXPOSE 3080

VOLUME ["/root/GNS3/projects", "/root/GNS3/images"]

ENTRYPOINT ["/entrypoint.sh"]