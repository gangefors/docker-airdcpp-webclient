FROM ubuntu:16.04
MAINTAINER Stefan Gangefors <stefan@gangefors.com>

ENV VERSION=1.3.0

RUN buildDeps=' \
        cmake \
        g++ \
        gcc \
        git \
        libboost1.5*-dev \
        libbz2-dev \
        libgeoip-dev \
        libleveldb-dev \
        libminiupnpc-dev \
        libnatpmp-dev \
        libssl-dev \
        libtbb-dev \
        libwebsocketpp-dev \
        npm \
        pkg-config \
        python \
        zlib1g-dev \
    ' && \
    runtimeDeps=' \
        libboost-regex1.5* \
        libboost-system1.5* \
        libboost-thread1.5* \
        libbz2-1.0 \
        libgeoip1 \
        libleveldb1v5 \
        libminiupnpc10 \
        libnatpmp1 \
        libssl1.0.0 \
        libstdc++6 \
        libtbb2 \
        libwebsockets7 \
        zlib1g \
    ' \
# Install build and runtime dependencies
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps $runtimeDeps \
# Build and install airdcpp-webclient
    && git clone https://github.com/airdcpp-web/airdcpp-webclient.git /tmp/aw \
    && cd /tmp/aw \
    && git checkout $VERSION \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j4 \
    && make install \
    && rm -rf /tmp/aw \
    && rm -rf /root/.npm \
# Remove build dependencies
    && apt-get purge --auto-remove -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

# Install default webserver settings
COPY WebServer.xml /root/.airdc++/WebServer.xml

# Install and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

VOLUME /root/.airdc++

EXPOSE 5600 5601

CMD airdcppd
