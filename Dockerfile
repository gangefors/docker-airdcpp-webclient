FROM debian:stable-slim

ARG dl_url=http://web-builds.airdcpp.net/stable/airdcpp_latest_master_64-bit_portable.tar.gz

RUN installDeps=' \
        curl \
        gnupg \
    ' \
    && runtimeDeps=' \
        ca-certificates \
        locales \
        openssl \
    ' \
# Install runtime dependencies
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends $installDeps $runtimeDeps \
# Install node.js to enable airdcpp extensions
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
# Setup application
    && mkdir /Downloads /Share \
    && echo "Downloading ${dl_url}..." \
    && curl -# $dl_url | tar -xz -C / \
# Cleanup
    && apt-get purge --autoremove -y $installDeps \
    && rm -rf /var/lib/apt/lists/*

# Configure locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen && dpkg-reconfigure -f noninteractive locales

WORKDIR /airdcpp-webclient
COPY dcppboot.xml dcppboot.xml
COPY .airdcpp/ /.airdcpp
RUN chmod -R ugo+w /.airdcpp

VOLUME /.airdcpp
EXPOSE 5600 5601
ENTRYPOINT ["./airdcppd"]
