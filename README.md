AirDC++ Web Client Docker image
===============================

Run the application
-------------------

	docker volume create --name airdcpp
	docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \
	    gangefors/airdcpp-webclient

The web UI will be available on [http://localhost]

Username / password for the default admin account is: `admin` / `password`

*Explanation*

    docker volume create --name airdcpp

This command creates a named volume that will store the application settings.
*Run this only once.*

    docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \ 
        gangefors/airdcpp-webclient

This command starts a container using the default settings built into the
image.


Run as non-privileged user
--------------------------

If you'd like to run in a non-privileged container you can do that as well.
It might even be preferable since then you get to decide who owns the
downloaded files.

    docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \
        -u $(id -u):$(id -g) gangefors/airdcpp-webclient

*NOTE*
If you already have run the container as root, the files in the volume might
be owned by root. Fix that by `chown`ing the files to the user you run as.

    docker run --rm -v airdcpp:/.airdcpp ubuntu:16.04 \
        chown -R $(id -u):$(id -g) /.airdcpp


Add admin users
---------------

To add/modify *adminitrative* users to the web interface, run the following.

    docker run --rm -it -v airdcpp:/.airdcpp \
        gangefors/airdcpp-webclient --add-user

If the container was running you need to restart it for the changes to take
effect.

    docker restart airdcpp    


Volumes
-------

- `/.airdcpp`

  This volume stores the application settings.

  *NOTE*
  If you mount this directory from your host you will not have the default
  configuration files in the settings directory. You need to copy them from
  this repo. The files are found in the [.airdcpp] directory.

- `/Downloads`

  This is the default Download folder, but you can change this in the
  settings through the web UI.

- `/Share`

  This is the default share folder.


Ports
-----

- `5600` HTTP port

- `5601` HTTPS port

You are able to change the web UI ports by running the following command.

    docker run --rm -it -v airdcpp:/.airdcpp \
        gangefors/airdcpp-webclient --configure
        
- `21248` TCP and UDP port for incoming connections

- `21249` TCP port for incoming encrypted connections

You are able to change the incoming connection ports under
Settings>Connectivity>Advanced>Ports in the web UI.


Upgrade
-------
1. Pull the latest image.
2. Stop and remove the container.
3. Start a new container the same way you started the old one.

Example:

    docker pull gangefors/docker-airdcpp-webclient
    docker rm -f airdcpp-webclient
    docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \
        gangefors/docker-airdcpp-webclient


Enable HTTPS
------------

*TODO*


[http://localhost]: http://localhost
[.airdcpp]: .airdcpp