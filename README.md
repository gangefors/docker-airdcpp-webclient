AirDC++ Web Client Docker image
===============================

Run the application
-------------------

    docker volume create --name airdcpp
    docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \
        gangefors/airdcpp-webclient

The web UI will be available on [http://localhost]

Username / password for the default admin account is: `admin` / `password`

_Explanation_

    docker volume create --name airdcpp

This command creates a named volume that will store the application settings.
_Run this only once._

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

_NOTE_
If you already have run the container as root, the files in the volume might
be owned by root. Fix that by `chown`ing the files to the user you run as.

    docker run --rm -v airdcpp:/.airdcpp ubuntu:16.04 \
        chown -R $(id -u):$(id -g) /.airdcpp


docker-compose
--------------

There is a docker-compose file available to set up the application as a service
on a docker host. Just run the following.

    docker-compose up -d

### Environment

- `UID`

  Container is started with this user id. Defaults to 0 (root).
  Usually you want this to be $(id -u).

- `GID`

  Container is started with this group id. Defaults to 0 (root).
  Usually you want this to be $(id -g).

- `HTTP_PORT`

  Published HTTP port. Defaults to 5600.

- `HTTPS_PORT`

  Published HTTPS port. Defaults to 5601.

- `TCP_PORT`

  Published TCP port for incoming connections. Defaults to 21248. If this is
  change you have to change it in the application settings as well.

- `UDP_PORT`

  Published TCP port for incoming connections. Defaults to 21248. If this is
  change you have to change it in the application settings as well.

- `TLS_PORT`

  Published TLS port for incoming connections. Defaults to 21249. If this is
  change you have to change it in the application settings as well.

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

- `21248` TCP and UDP port for incoming connections

- `21249` TCP port for incoming encrypted connections

You are able to change the incoming connection ports under
Settings>Connectivity>Advanced>Ports in the web UI.


Add/modify admin users
----------------------

To add/modify _adminitrative_ users to the web interface, run the following.

    docker run --rm -it -v airdcpp:/.airdcpp \
        gangefors/airdcpp-webclient --add-user

If the container was running you need to restart it for the changes to take
effect.

    docker restart airdcpp


Upgrade
-------

1. Pull the latest image.
2. Stop and remove the container.
3. Start a new container the same way you started the old one.

Example:

    docker pull gangefors/docker-airdcpp-webclient
    docker rm -f airdcpp
    docker run -d --name airdcpp -p 80:5600 -v airdcpp:/.airdcpp \
        gangefors/docker-airdcpp-webclient


Enable HTTPS
------------

The image comes with self-signed certificates so you should be able to use
HTTPS out of the box. But if you want to generate your own certificates here's
how you do it. _The container must be running._

    docker exec -it airdcpp openssl req -subj "/C=/ST=/L=/O=/CN=localhost" \
        -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /.airdcpp/Certificates/client.key \
        -out /.airdcpp/Certificates/client.crt

Change the CN string to whatever the domain name or IP you are running your
service on. You can also add more information in the -subj string if you want.
Check [this site](certs) for more information on the different fields.


[http://localhost]: http://localhost
[.airdcpp]: .airdcpp
[certs]: http://www.shellhacks.com/en/HowTo-Create-CSR-using-OpenSSL-Without-Prompt-Non-Interactive
