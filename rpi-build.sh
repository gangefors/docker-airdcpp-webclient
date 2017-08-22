#!/usr/bin/env bash
# Set docker host to a Raspberry Pi's IP address
export DOCKER_HOST=tcp://192.168.0.51:2376
if [ -z $1 ]; then
    docker build --no-cache --pull -f Dockerfile.rpi -t gangefors/arm32v7/airdcpp-webclient:latest .
else
    docker build --no-cache --pull -f Dockerfile.rpi -t gangefors/arm32v7/airdcpp-webclient:$1 --build-arg VERSION=$1 .
    docker tag gangefors/arm32v7/airdcpp-webclient:$1 gangefors/arm32v7/airdcpp-webclient:latest
fi
