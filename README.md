AirDC++ Web Client Docker image
===============================

Username / password for the default admin account is `admin` / `password`

Example command to run the application.
```
docker run -d --name airdcpp -p 80:5600 -v ~/.airdc++:/root/.airdc++ -v ~/Downloads:/root/Downloads -v ~/Shared:/Shared gangefors/airdcpp-webclient
```

If you'd like to run in a non-privileged container you can do that as well. It might 
even be preferable since then you get to decide who owns the downloaded files.

```
docker run -d --name airdcpp -p 80:5600 -v ~/.airdc++:/.airdc++ -v ~/Downloads:/Downloads -v ~/Shared:/Shared -u $(id -u):$(id -g) gangefors/airdcpp-webclient airdcppd -c /.airdc++
```

*NOTE: If you have previously run a container the files in ~/.airdc++ might be owned
by root so you first have to `chown` them to yourself.*

Volumes
-------

- `/root/.airdc++`
This volume have all application settings.

*NOTE: If you host mount this folder with a previous AirDC++ install you might not
have a WebServer.xml file in your settings folder so you need to generate one or
copy the one from this repo.*

You can generate a WebServer.xml file by running the following command.

`docker run --rm -it -v ~/.airdc++:/root/.airdc++ gangefors/airdcpp-webclient --configure`

You also want to mount the Download folder and any folders that you want to share.

- `/root/Downloads`
This path is the default Download folder, but you can change this in the settings.


Exposed ports
-------------

- `5600`
HTTP port

- `5601`
HTTPS port

And you probably want to add ports for TCP/UDP/TLS to configure your client for Active mode.

`-p 55031:55031 -p 55032:55032/udp -p 55033:55033` 

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
