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


docker-compose
--------------

There is a docker-compose file available to set up the application as a service
on a docker host. Just run the following.

    docker-compose up -d

This will start a service as a non-privileged user using your UID as the one
that runs the application.

If you get warnings about UID or GID not being set then add them as environment
variables to the command.

    UID=$(id -u) GID=$(id -g) docker-compose up -d

The warnings look like this.

    WARNING: The UID variable is not set. Defaulting to a blank string.
    WARNING: The GID variable is not set. Defaulting to a blank string.

If these env vars are not set the service will run as root. Only UID is needed
for the application to run properly as a non-privileged user. If only UID is
set all files will be owned by that id but belong to the root group.


Add/modify admin users
----------------------

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

The image comes with self-signed certificates so you should be able to use
HTTPS out of the box. But if you want to generate your own certificates here's
how you do it.

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
