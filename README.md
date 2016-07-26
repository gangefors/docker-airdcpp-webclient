AirDC++ Web Client Docker image
===============================

Run the image with the following command.

`docker run -d --name airdcpp-web -p 80:5600 -p 443:5601 -v ~/.airdc++:/root/.airdc++ -v ~/Downloads:/root/Downloads -v ~/Shared/:/root/Shared gangefors/airdcpp-webclient`

Volumes
-------

- /root/.airdc++
This volume have all application settings.

Exposed ports
-------------

- 5600
HTTP port

- 5601
HTTPS port
