FROM debian:stable-slim

ARG version=2.3.0
ARG dl_url=http://web-builds.airdcpp.net/stable/airdcpp_${version}_webui-${version}_64-bit_portable.tar.gz

RUN runtimeDeps=' \
        curl \
        locales \
    ' \
# Install runtime dependencies
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends $runtimeDeps \
# Install node.js to enable airdcpp extensions
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Setup application
RUN mkdir /Downloads /Share
RUN curl $dl_url | tar -xz -C /
WORKDIR /airdcpp-webclient
COPY dcppboot.xml dcppboot.xml
COPY .airdcpp/ /.airdcpp
RUN chmod -R ugo+w /.airdcpp

# Install and set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

VOLUME /.airdcpp
EXPOSE 5600 5601
ENTRYPOINT ["./airdcppd"]
