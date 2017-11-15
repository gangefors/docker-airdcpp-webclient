ARG arch=""
FROM ${arch}ubuntu:16.04

ARG version=2.2.1
ARG threads=4

RUN buildDeps=' \
        cmake \
        curl \
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
        locales \
        openssl \
        zlib1g \
    ' \
# Install build and runtime dependencies
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps $runtimeDeps \
# Install node.js to enable airdcpp extensions
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
# Build and install airdcpp-webclient
    && git clone git://github.com/airdcpp-web/airdcpp-webclient.git /tmp/aw \
    && cd /tmp/aw \
    && git checkout ${version} \
    && cmake -DCMAKE_BUILD_TYPE=Release . \
    && make -j${threads} \
    && make install \
    && cd - \
    && rm -rf /tmp/aw \
    && rm -rf /root/.npm \
# Remove build dependencies
    && apt-get purge --auto-remove -y $buildDeps \
    && rm -rf /var/lib/apt/lists/*

# Setup application
COPY dcppboot.xml /usr/local/etc/airdcpp/dcppboot.xml
COPY .airdcpp/ /.airdcpp/
RUN chmod -R ugo+w /.airdcpp
RUN mkdir /Downloads /Share

# Install and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

VOLUME /.airdcpp
EXPOSE 5600 5601
ENTRYPOINT ["airdcppd"]
