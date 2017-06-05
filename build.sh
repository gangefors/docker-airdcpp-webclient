#!/bin/bash
if [ -z $1 ]; then
    sudo docker build --no-cache --pull -t gangefors/airdcpp-webclient:latest .
else
    sudo docker build --no-cache --pull -t gangefors/airdcpp-webclient:$1 --build-arg VERSION=$1 .
    sudo docker tag gangefors/airdcpp-webclient:$1 gangefors/airdcpp-webclient:latest
fi
