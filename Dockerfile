FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ARG GNS3_VERSION=2.2.44

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev git curl wget \
    build-essential cmake software-properties-common \
    dynamips vpcs iproute2 libpcap-dev libpcap0.8 \
    net-tools openssh-client telnet \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/GNS3/ubridge.git /tmp/ubridge \
    && cd /tmp/ubridge && make && make install \
    && rm -rf /tmp/ubridge

RUN pip3 install --no-cache-dir gns3-server==${GNS3_VERSION}
RUN chmod +s /usr/local/bin/ubridge || true

RUN mkdir -p /root/GNS3/{projects,appliances,images/{IOS,QEMU}} /root/.config/GNS3

COPY config/gns3_server.conf /root/.config/GNS3/gns3_server.conf

# Create entrypoint directly in Dockerfile - avoids CRLF issues
RUN printf '#!/bin/bash\nset -e\necho "GNS3 Server - Docker Edition"\nexec gns3server --host 0.0.0.0 --port 3080 "$@"\n' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 3080
VOLUME ["/root/GNS3/projects", "/root/GNS3/images"]
ENTRYPOINT ["/entrypoint.sh"]