#!/usr/bin/env sh
sudo docker build --pull -t gangefors/airdcpp-webclient:$VERSION --build-arg VERSION=$VERSION .
sudo docker tag gangefors/airdcpp-webclient:$VERSION gangefors/airdcpp-webclient:latest
