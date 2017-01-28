# How-to Install our Docker Registry

## Initialization & First Run

- Install Docker
- Install Docker Compose
- Create a folder where to install the registry (ex. ``/home/docker/registry``)
- Inside that folder create a folder ``auth``
- Inside that folder create a folder ``letsencrypt``
- Inside the folder 'letsencrypt' create an empty file ``cachefile``
- Download the ``docker-compose.yml`` and put if inside the main folder
- Execute ``docker run --entrypoint htpasswd registry:2 -Bbn testuser testpassword > auth/htpasswd``
  replacing ``testuser`` and ``testpassword`` with a real user and password
- Start the registry with ``docker-compose up -d``
- Check if the container is running with ``docker ps``
- The default port is ``443`` so under ``PORTS`` you should see ``0.0.0.0:443->5000/tcp``;
  it means that we opened the port ``443`` on our host server 
  and the registry is listening to ``5000``.

### Change the host port

If the default port ``443`` is already used by another service
we need to change it to another one, so follow the instruction below.

- Edit the file ``docker-compose.yml`` and under ``ports`` just switch the port binding with the port you want.

## Test

    $ docker pull alpine
    $ docker tag alpine dev.sangah.com/alpine
    $ docker push dev.sangah.com/alpine


Remember to add the port after the domain if different from ``443`` 
and change the domain with the right one.

## Start & Stop

If is the first time you run the registry you should follow the above instruction first...

To stop the service run:

    $ docker stop registry

To start again run:

    $ docker start registry

## Build & Re-deploy

before building and deploying again the registry, 
make sure you stop and remove the previous container with:

    $ docker stop registry
    $ docker rm registry

## Check Status

Check the registry log with:

    $ docker logs registry | less

### Awesome now we have our little tiny docker registry just for us yay!