AirDC++ Web Client Docker image
===============================

Username / password for the default admin account is `admin` / `password`

Example command to run the application.

`docker run -d --name airdcpp-webclient -p 80:5600 - 443:5601 -v ~/.airdc++:/root/.airdc++ -v ~/Downloads:/root/Downloads -v ~/Shared:/shared gangefors/docker-airdcpp-webclient`


Volumes
-------

- `/root/.airdc++`
This volume have all application settings.

NOTE: If you host mount this folder you will not have a WebServer.xml file in
your settings folder so you need to generate one or copy the one from this repo.

You can generate one by running the following command.

`docker run --rm -it -v ~/.airdc++:/root/.airdc++ gangefors/docker-airdcpp-webclient --configure`

You also want to mount the Download folder and any folders that you want to share.

- `/root/Downloads`
This path is the default Download folder, but you can change this in the settings.


Exposed ports
-------------

- `5600`
HTTP port

- `5601`
HTTPS port


Upgrade
-------
1. Pull the latest image.
2. Stop and remove the container.
3. Start a new container the same way you started the old one.

Example:
```
docker pull gangefors/docker-airdcpp-webclient
docker rm -f airdcpp-webclient
docker run -d --name airdcpp-webclient -p 80:5600 - 443:5601 -v ~/.airdc++:/root/.airdc++ -v ~/Downloads:/root/Downloads -v ~/Shared:/shared gangefors/docker-airdcpp-webclient
```

Enable HTTPS
------------

TODO
