AirDC++ Web Client Docker image
===============================

Docker image running [AirDC++ Webclient software][airdcpp-github].
You must have proper knowledge of [Docker] to use this image.


Run the application
-------------------

    docker volume create --name airdcpp-volume
    docker run -d --name airdcpp-container \
        -p 80:5600 -p 443:5601 \
        -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -e PUID=$(id -u) \
        -e PGID=$(id -g) \
        -v airdcpp-volume:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

The web UI will be available on http://localhost and https://localhost.
HTTPS is using self-signed certs, see [Enable HTTPS] for more details.

If you want to access the Web UI on any other port, just update the `-p`
option in the command, e.g `-p 8081:5600` to bind to port 8081 instead.
See [Exposed Ports] for more details.

> Username / password for the default admin account is: `admin` / `password`

> PUID / PGID environment variables are only available using the `latest`
> tag and versions later than 2.11.0. Older images will *not* be rebuilt.

#### Command Explanation

    docker volume create --name airdcpp-volume

This command creates a named volume that will store the application settings.

> Run the `volume create` command only once.


    docker run -d --name airdcpp-container \
        -p 80:5600 -p 443:5601 \
        -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -e PUID=$(id -u) \
        -e PGID=$(id -g) \
        -v airdcpp-volume:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

This command starts a container using the default settings built into the
image, binding the application to port 80/443 (default http/https ports) so
it's readily available on http://localhost and https://localhost.

The container is started as root but the application within will be running as
the user running the docker command. This is necessary to make the files
written by the application to be owned by your local user even outside the
container.

It will also mount "Downloads" and "Share" from you home directory. Change
these according to your personal setup.

#### Environment variables

If you run the container as root you need to set the following environment
variables. Example: `-e PUID=1000 -e PGID=1000`.
All files written by the application will be owned by this user and group.

- `PUID`

  Application runs as this user id.
  Usually you want this to be your local user id. **Must be >= 101.**

- `PGID`

  Application runs as this group id.
  Usually you want this to be your local user's group id. **Must be >= 101.**

> The reason for the >= 100 limitation is that the image already contains
> accounts and groups with IDs lower than that. Use `--user` if you need to
> use IDs lower than 101.


#### Run container as non-root

You can also start the container as a non-root user. This is another way of
telling the application which user you want it to run as.

Add `--user $(id -u):$(id -g)` to the `docker run` command and the container
will start as the user that runs the command.

    docker run -d --name airdcpp-container \
        -p 80:5600 -p 443:5601 \
        -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        --user $(id -u):$(id -g) \
        -v airdcpp-volume:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

You can also put in specific IDs if you want to run as a different user than
the current, for example if you need to use an ID that is lower than the ones
supported by PUID/PGID (but not 0).


docker-compose
--------------

There is a docker-compose file available to set up the application as a
service on a docker host. Just run the following.

    docker-compose up -d

#### Compose variables

You can configure some aspects of the application when using docker-compose
by setting these environment variables before running `docker-compose up -d`.

- `PUID`

  Application runs as this user id. Defaults to 1000.
  Usually you want this to be your local user id. Must be >= 101.

- `PGID`

  Application runs as this group id. Defaults to 1000.
  Usually you want this to be your local user's group id. Must be >= 101.

- `HTTP_PORT`

  Published HTTP port. Defaults to 80.

- `HTTPS_PORT`

  Published HTTPS port. Defaults to 443.

- `TCP_PORT`

  Published TCP port for incoming connections. Defaults to 21248.
  If this is changed you have to change it in the application settings as well.

- `UDP_PORT`

  Published UDP port for incoming connections. Defaults to 21248.
  If this is changed you have to change it in the application settings as well.

- `TLS_PORT`

  Published TLS port for incoming connections. Defaults to 21249.
  If this is changed you have to change it in the application settings as well.


Volumes
-------

- `/.airdcpp`

  This volume stores the application settings.

  On launch it will be populated with default settings unless the folder
  already contains the DCPlusPlus.xml configuration file.

- `/Downloads`

  This is the default Download folder, but you can change this in the
  settings through the web UI.

- `/Share`

  This is the default share folder.

  Any bind mounted folder under this will automatically be added to your Share.


Exposed Ports
-------------

- `5600` HTTP port

- `5601` HTTPS port

- `21248` TCP and UDP port for incoming connections. You have to publish this
  on the same port number otherwise clients will not be able to connect.

- `21249` TCP port for incoming encrypted connections. You have to publish this
  on the same port number otherwise clients will not be able to connect.

If you want to use other ports for incoming connections you can change them
under Settings>Connectivity>Advanced>Ports in the web UI.

The incoming connection ports are used to enable *active mode*. This allows
you to connect to all peers in a hub, including the ones in *passive mode*.

Read more about connectivity modes in the [official FAQ][conn_faq].


Add/modify admin users
----------------------

To add/modify _administrative_ users to the web interface, run the following.

    docker stop airdcpp-container
    docker run --rm -it --volumes-from airdcpp-container \
        -e PUID=$(id -u) -e PGID=$(id -g) \
        gangefors/airdcpp-webclient --add-user
    docker start airdcpp-container

> You must stop the webclient application container before running this
command. If you add a user while it's running, the configuration will be
overwritten when the application shuts down.


Upgrade
-------

- Pull the latest image.
- Stop and remove the container.
- Start a new container with the same command you started the old one.

Example:

    docker pull gangefors/docker-airdcpp-webclient
    docker stop airdcpp-container
    docker rm airdcpp-container
    docker run -d --name airdcpp-container \
        -p 80:5600 -p 443:5601 \
        -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -e PUID=$(id -u) \
        -e PGID=$(id -g) \
        -v airdcpp-volume:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient


Enable HTTPS
------------

The image comes with self-signed certificates so you should be able to use
HTTPS out of the box. But if you want to generate your own certificates here's
how you do it.

> The container must be running.

    docker exec -it airdcpp-container openssl req \
        -subj "/C=US/ST=State/L=City/O=/CN=localhost" \
        -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /.airdcpp/Certificates/client.key \
        -out /.airdcpp/Certificates/client.crt

Change the CN string to whatever the domain name or IP you are running your
service on. You can also add more information in the -subj string if you want.
Check [this site][certs] for more information on the different fields.


Troubleshooting
---------------

* If you get any permission issues with the config files you can solve this by
  running a temporary container and `chown`ing the files through that.

      docker run --rm \
        --volumes-from=airdcpp-container \
        debian:stable-slim \
        chown -R $(id -u):$(id -g) /.airdcpp


Building the Docker image
-------------------------

> This is not needed since the images are already pushed to Docker hub.

If you want to build your own image run the following command.

    docker build --no-cache --pull -t gangefors/airdcpp-webclient:latest .

The Dockerfile is set up to fetch the latest version on master branch in the
[airdcpp-webclient git repo][airdcpp-github].


#### Build a different version

To build a different version than `latest` supply the build-arg `dl_url`.
Find the URL for the version you want to build at https://web-builds.airdcpp.net/stable/

    export dl_url="https://web-builds.airdcpp.net/stable/airdcpp_2.7.0_webui-2.7.0_64-bit_portable.tar.gz"
    docker build --no-cache --pull -t gangefors/airdcpp-webclient:2.7.0 --build-arg dl_url .


[.airdcpp]: .airdcpp
[airdcpp-github]: https://github.com/airdcpp-web/airdcpp-webclient
[bindmount]: https://docs.docker.com/storage/bind-mounts/#mount-into-a-non-empty-directory-on-the-container
[certs]: http://www.shellhacks.com/en/HowTo-Create-CSR-using-OpenSSL-Without-Prompt-Non-Interactive
[conn_faq]: http://dcplusplus.sourceforge.net/webhelp/faq_connection.html
[docker]: https://docs.docker.com/learn/
[Exposed Ports]: #exposed-ports
[Enable HTTPS]: #enable-https
