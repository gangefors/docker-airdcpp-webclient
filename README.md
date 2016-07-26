AirDC++ Web Client Docker image
===============================

Run the image with the following command.

`docker run -d --name airdcpp-web -p 80:5600 -p 443:5601 -v ~/.airdc++:/root/.airdc++ -v ~/Downloads:/root/Downloads -v ~/Shared/:/root/Shared gangefors/airdcpp-webclient`

Username / password for the default admin account is `admin` / `password`

Volumes
-------

- `/root/.airdc++`
This volume have all application settings.

You also want to mount the Download folder and any folders that you want to share.

- `/root/Downloads`
This path is the default Download folder, but you can change this in the settings.

Exposed ports
-------------

- `5600`
HTTP port

- `5601`
HTTPS port
