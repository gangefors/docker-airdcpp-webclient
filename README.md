AirDC++ Web Client Docker image
===============================

Docker image running [AirDC++ Webclient software][airdcpp-github].
You must have proper knowledge of [Docker] to use this image.


Run the application
-------------------

    docker volume create --name airdcpp
    docker run -d --name airdcpp \
        -p 5600:5600 -p 5601:5601 -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -u $(id -u):$(id -g) \
        -v airdcpp:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

The web UI will be available on http://localhost:5600 or https://localhost:5601.

If you want to access the Web UI on any other port than 5600/5601, just update
the `-p` option in the command, e.g `-p 8081:5600` to bind to port 8081.
See [Exposed Ports] below for details.

Username / password for the default admin account is: `admin` / `password`

##### Explanation

    docker volume create --name airdcpp

This command creates a named volume that will store the application settings.

> Run the `volume create` command only once.

    docker run -d --name airdcpp \
        -p 80:5600 -p 443:5601 -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        --user $(id -u):$(id -g) \
        -v airdcpp:/.airdcpp \ 
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

This command starts a container using the default settings built into the
image, binding the application to port 80/443 (default http/https port) so
it's readily available on http://localhost and https://localhost.
The container is started as the user running the command meaning that all files
created by the container will be owned by the current user.
It will also mount Downloads and Share from you home directory, change these
according to your personal setup.

> If you already have run the container without the --user option, the files in
the config volume might be owned by root. Fix that by `chown`ing the files to
the user you run as.

    docker run --rm \
        -v airdcpp:/.airdcpp \
        debian:stable-slim \
        chown -R $(id -u):$(id -g) /.airdcpp


docker-compose
--------------

There is a docker-compose file available to set up the application as a
service on a docker host. Just run the following.

    docker-compose up -d

**Environment**

You can configure some aspects of the application when using docker-compose
by setting these environment variables before running `docker-compose up -d`.

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
  changed you have to change it in the application settings as well.

- `UDP_PORT`

  Published UDP port for incoming connections. Defaults to 21248. If this is
  changed you have to change it in the application settings as well.

- `TLS_PORT`

  Published TLS port for incoming connections. Defaults to 21249. If this is
  changed you have to change it in the application settings as well.


Volumes
-------

- `/.airdcpp`

  This volume stores the application settings.

  Note that if you bind mount this volume using a directory on your
  host you will see the following output when running the container.

      No valid configuration found. Run the application with --configure parameter to set up initial configuration.

  This is caused by the fact that bind mounting a volume [will obscure
  any existing content][bindmount] of that volume to the bind mounted
  directory. This causes the configuration files to be missing.
  You need to prepopulate the host directory with the default
  configuration. These files can be found in the [.airdcpp] directory
  in this repo. Just copy those files to the bind mounted directory.
  
  You can also solve this by using the commands below. Notice how we
  use a bind mounted volume `-v $HOME/.airdcpp:/.airdcpp` instead of
  a named Docker volume `-v airdcpp:/.airdcpp`.

      mkdir $HOME/.airdcpp
      curl -o $HOME/.airdcpp/DCPlusPlus.xml https://raw.githubusercontent.com/gangefors/docker-airdcpp-webclient/master/.airdcpp/DCPlusPlus.xml
      curl -o $HOME/.airdcpp/WebServer.xml https://raw.githubusercontent.com/gangefors/docker-airdcpp-webclient/master/.airdcpp/WebServer.xml
      docker run -d --name airdcpp \
        -p 5600:5600 -p 5601:5601 -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -u $(id -u):$(id -g) \
        -v $HOME/.airdcpp:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/airdcpp-webclient

- `/Downloads`

  This is the default Download folder, but you can change this in the
  settings through the web UI.

- `/Share`

  This is the default share folder.


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

The incoming connection ports are used to be able to be in *active mode*. This
allows you to connect to all peers in a hub, including the ones in *passive mode*.

Read more about connectivity modes in the [official FAQ][conn_faq].


Add/modify admin users
----------------------

To add/modify _administrative_ users to the web interface, run the following.

    docker stop airdcpp
    docker run --rm -it --volumes-from airdcpp \
        gangefors/airdcpp-webclient --add-user
    docker start airdcpp

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
    docker stop airdcpp
    docker rm airdcpp
    docker run -d --name airdcpp \
        -p 80:5600 -p 443:5601 -p 21248:21248 -p 21248:21248/udp -p 21249:21249 \
        -v airdcpp:/.airdcpp \
        -v $HOME/Downloads:/Downloads \
        -v $HOME/Share:/Share \
        gangefors/docker-airdcpp-webclient


Enable HTTPS
------------

The image comes with self-signed certificates so you should be able to use
HTTPS out of the box. But if you want to generate your own certificates here's
how you do it.

> The container must be running.

    docker exec -it airdcpp openssl req \
        -subj "/C=US/ST=State/L=City/O=/CN=localhost" \
        -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /.airdcpp/Certificates/client.key \
        -out /.airdcpp/Certificates/client.crt

Change the CN string to whatever the domain name or IP you are running your
service on. You can also add more information in the -subj string if you want.
Check [this site][certs] for more information on the different fields.


Building the Docker image
-------------------------

> This is not needed since the images are already pushed to Docker hub.

If you want to build your own image run the following command.

    docker build --no-cache --pull -t gangefors/airdcpp-webclient:latest .

The Dockerfile is set up to fetch the latest version on master branch in the
[airdcpp-webclient git repo][airdcpp-github].


### Build a different version

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
[http://localhost:5600]: http://localhost:5600
[https://localhost:5601]: https://localhost:5601
