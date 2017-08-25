#!/usr/bin/env sh
set -ex

if [ -z "$1" ]; then
    docker build --no-cache --pull -t gangefors/airdcpp-webclient:latest .
    DOCKER_HOST=tcp://192.168.0.51:2376 docker build \
            --no-cache --pull -t gangefors/arm32v7-airdcpp-webclient:latest \
            --build-arg version=$1 --build-arg threads=1 --build-arg arch="arm32v7/" .
else
    docker build --no-cache --pull -t gangefors/airdcpp-webclient:$1 --build-arg version=$1 .
    docker tag gangefors/airdcpp-webclient:$1 gangefors/airdcpp-webclient:latest
    DOCKER_HOST=tcp://192.168.0.51:2376 docker build \
            --no-cache --pull -t gangefors/arm32v7-airdcpp-webclient:$1 \
            --build-arg version=$1 --build-arg threads=1 --build-arg arch="arm32v7/" .
    DOCKER_HOST=tcp://192.168.0.51:2376 docker tag \
            gangefors/arm32v7-airdcpp-webclient:$1 gangefors/arm32v7-airdcpp-webclient:latest
fi
