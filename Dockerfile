FROM ubuntu:22.04

LABEL maintainer="tejasmr07"
LABEL description="GNS3 Server - Dockerized for college labs"

ENV DEBIAN_FRONTEND=noninteractive
ARG GNS3_VERSION=2.2.44

# Install dependencies (removed ubridge from apt - not available in 22.04)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    software-properties-common \
    dynamips \
    vpcs \
    iproute2 \
    libpcap-dev \
    libpcap0.8 \
    net-tools \
    openssh-client \
    telnet \
    && rm -rf /var/lib/apt/lists/*

# Build and install ubridge from source
RUN git clone https://github.com/GNS3/ubridge.git /tmp/ubridge \
    && cd /tmp/ubridge \
    && make \
    && make install \
    && rm -rf /tmp/ubridge

# Install GNS3 server
RUN pip3 install --no-cache-dir gns3-server==${GNS3_VERSION}

# Set ubridge permissions
RUN chmod +s /usr/local/bin/ubridge || true

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

EXPOSE 3080

VOLUME ["/root/GNS3/projects", "/root/GNS3/images"]

ENTRYPOINT ["/entrypoint.sh"]