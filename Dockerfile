FROM ubuntu:16.04
MAINTAINER Stefan Gangefors <stefan@gangefors.com>

RUN buildDeps=' \
        cmake \
        g++ \
        gcc \
        git \
        libboost1.5*-dev \
        npm \
        pkg-config \
        python \
    ' && \
    runtimeDeps=' \
        libboost-regex1.5* \
        libboost-system1.5* \
        libboost-thread1.5* \
        libbz2-dev \
        libgeoip-dev \
        libleveldb-dev \
        libminiupnpc-dev \
        libnatpmp-dev \
        libssl-dev \
        libstdc++6 \
        libtbb-dev \
        libwebsocketpp-dev \
        zlib1g-dev \
    ' && \
# Install build and runtime dependencies
    apt-get update && apt-get install -y $buildDeps $runtimeDeps \
# Build and install airdcpp-webclient
    && git clone https://github.com/airdcpp-web/airdcpp-webclient.git /tmp/aw \
    && cd /tmp/aw \
    && cmake . \
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
