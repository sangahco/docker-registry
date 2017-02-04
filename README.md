# How-to Install our Docker Registry

## What configuration I have to use?

You will find three configuration to choose from:

- **docker-compose.yml**

    This is used for *testing the registry*, without ssl and without authentication.
    Use this configuration just for testing the registry 
    and because docker by default want a secured connection to the registry 
    you need to follow the steps [here](https://docs.docker.com/registry/insecure/#/deploying-a-plain-http-registry)

    The registry is available at ``127.0.0.1:5000``

- **docker-compose-ssl.yml**

    This version has ssl and authentication, it will use letsencrypt internally to generate 
    a valid ssl certification for the registry.

    The registry is available at `[DOMAIN]:443`

    The port can be change but letsencrypt need the port `443`
    in order to generate the certificate the first time it is run (pull or push).

- **docker-compose-nginx-ssl.yml**

    Nginx over Docker Registry with secured connection and authentication required. 
    **This is the recommended configuration to use in production**,
    but you need to provide valid tls certificate (`cert.pem`) and key (`privkey.pem`).
    Before building put the certificate and key inside the `tls` folder under `nginx`.

    The registry is available at `[DOMAIN]:5043`

---

*IMPORTANT*

> In order to use ``docker-compose-nginx-ssl.yml`` and ``docker-compose-ssl.yml`` 
> add the option ``-f <configuration file>`` JUST after ``docker-compose`` and BEFORE any commands.
>
>    $ docker-compose -f docker-compose-nginx-ssl.yml build


## Initialization & First Run

- Install Docker
- Install Docker Compose
- If you want to add authentication to the registry (recommended) run the following commands, under this folder 
  replacing ``testuser`` and ``testpassword`` with a real user and password:
  
        $ docker run --entrypoint htpasswd registry:2 -Bbn testuser testpassword > auth/htpasswd
  
  Just make sure that the folder ``auth`` has been created with a file ``htpasswd`` inside.
- Start the registry with ``docker-compose up -d``
- Check if the container is running with ``docker ps``


### Change the host port

If the default port ``443`` is already used by another service
we need to change it to another one, so follow the instruction below.

- Edit the file ``docker-compose.yml`` and under ``ports`` just switch the port binding with the port you want.

Remember to restart the service with:

    $ docker-compose restart

## Test

In case you secured the registry you need to login first and than you can pull and push images,
otherwise skip the login step.

    $ docker login dev.sangah.com

    $ docker pull alpine
    $ docker tag alpine dev.sangah.com/alpine
    $ docker push dev.sangah.com/alpine


Remember to add the port after the domain if different from ``443`` 
and change the domain with the right one.

## Start & Stop

If is the first time you run the registry you should follow the above instruction first...

To stop the service, from the folder containing the docker-compose.yml run:

    $ docker-compose down

To start again run:

    $ docker-compose up -d

## Build & Re-deploy

before building and deploying again the registry, 
make sure you stop and remove the previous container with:

    $ docker-compose down

then rebuild with:

    $ docker-compose build

## Check Status

Check the registry log with:

    $ docker logs registry-srv | less

**Awesome now we have our little tiny docker registry just for us yay!**