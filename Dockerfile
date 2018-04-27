FROM debian:stable-slim

ARG version=2.3.0
ARG dl_url=http://web-builds.airdcpp.net/stable/airdcpp_${version}_webui-${version}_64-bit_portable.tar.gz

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN installDeps=' \
        curl \
        gnupg \
    ' \
    && runtimeDeps=' \
        locales \
    ' \
# Install runtime dependencies
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends $runtimeDeps \
    && apt-get install -y --no-install-recommends $installDeps \
    && locale-gen en_US.UTF-8 \
# Install node.js to enable airdcpp extensions
    && curl -sL http://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
# Setup application
    && mkdir /Downloads /Share \
    && curl $dl_url | tar -xz -C / \
# Clean up
    && apt-get purge -y $installDeps \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /airdcpp-webclient
COPY dcppboot.xml dcppboot.xml
COPY .airdcpp/ /.airdcpp
RUN chmod -R ugo+w /.airdcpp

VOLUME /.airdcpp
EXPOSE 5600 5601
ENTRYPOINT ["./airdcppd"]
