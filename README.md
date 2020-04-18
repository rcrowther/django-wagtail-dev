# What are Django and Wagtail?
Django is a web framework. The word '''framework' commonly means you must use code to produce webpages.

Wagtail is a Content Management System built on top of Django. The words ''Content Management System' commonly mean, ''a system that generate webpages by providing visual administration and entry for non-users'. Wagtail is notable because in many places it must still be coded to produce these effects. But it adds extra code to Django to handle the visual administrative tasks.

Find out more at the [Django project](https://docs.djangoproject.com) and [Wagtail](https://wagtail.io) websites.
   
<img src="https://upload.wikimedia.org/wikipedia/commons/1/1a/Citrine_wagtail_I_IMG_8326.jpg" width="128" height="128" alt="A Wagtail looks West"/>

<h2 style="font-weight:bolder; font-color:#44B78B;">Django</h2>



# About this image
It was built on an old Debian-based Linux laptop. I can't vouch for performance anywhere else.
 
This image is slightly different to others, and mainly intended for development. However, if that is your approach, it can be stage-rebuilt for deployment.

Advantages,

<dl>
 <dt>Runs with no host dependencies</dt> 
<dd> No virtual env, Pip, or Python required, only Docker. All dependencies locked in the Docker Container.</dd>
 <dt>Build and serve Django/Wagtail sites in seconds</dt>
<dd>Granted you have Docker installed and the image built. By seconds, I mean two commandlines, one to build a scaffold, another to run the server. My computer is slow, and these steps take forty seconds. </dd>
 <dt>Run multiple sites</dt>
 <dd>Try things out</dd>
</dl>

Disadvantages,
<dl>
 <dt>The development image is large</dt>
 <dd>Currently one gigabyte</dd>
 <dt>Requires execution in the container</dt>
 <dd> In the main container, you must keep a terminal running</dd>
 <dt>Not as flexible as a raw container </dt>
 <dd> But fairly neutral</dd>
</dl>

## Overview
The image can be used in a few ways,

- As a container containing Django/Wagtail dependencies
- Using scripts, it can generate multiple sites with no further code
- If you work on one site, the site can be decorated with extra containers to make steps towards deployment. Below are instructions for Nginx and Postgre

Also, the staged build can be used to generate an image with only necessary software.
 
These ideas have a natural workflow, but there is no need to follow them. Use the image and instructions as you need.


## Build an image
Use the DockerFile,

    cd DockerFileDirectory
    docker build -t dw-dev:2.8 .

For production (leaves out dev scripts and dependencies),

    docker build --target production -t wagtail:2.8 .

<dl>
<dt>`-t`</dt><dd> tag the image as `wagtail`, as it is a general 'handles Wagtail' container. </dd>
<dl>


# Working with multiple sites in the single image
You are not interested in complex Docker setups. You want to try Wagtail or experiment.

This setup places Wagtail sites in `/srv`, uses Django builtin Sqlite databases, and serves using Gunicorn. 


## Note, work in the container
You can, by the magic of Docker's filesystem mounts, ask a container to read code from outside. This means you can use your favourite editors and other tools to develop the site. The Docker container provides a version-locked virtual environment.

A basic of this approach is that, inside the container, you keep a terminal running. This will do the interactive website building. Don't run `manage.py` from the outside, or you defeat the purpose.


## Make a container
Create and run a container with a shell,

    docker run --name dw-dev -it -v /srv:/srv -p8000:8000 dw-dev:2.8 /bin/bash

Note we do not use docker-compose. Without a running process, the container will stop. Also, we name the container. No use if we run lots of them, because then we need unique ids, but we are only running one, so make it easy on ourselves.

The command includes host-mount and host-port bindings. You can change these, for example to use Docker volumes and a different host port,

    docker run -mount type=volume,source=/var/www/data,target=/srv -p8100:8000 -it wagtail-dev:2.8 /bin/bash

If you need to restart the container,

    docker start containerName
    docker exec -it containerName /bin/bash
    ./runserver.sh siteName


However, if you loose the container, it is usually easier to `docker run` again. Your sites will persist.


## Use the scripts
The image contains scripts to help use Django/Wagtail. They work by default at `/srv`. This is where shells enter too. The scripts are on-path. They ask questions. If you don't like commandline Q&A, you can use options. Try `scriptName --help`.

Build a site,

    createsite

Serve the site (continuous loading),

    runserver siteName

List sites,

    listsites

Delete a site,

    deletesite

That's it. Start one or many sites. 

(http://localhost:8000/)

Start work.

## I have a site!
Put it in `/srv` on the host machine. The image uses the magic of Gunicon. Unless you fiddled with the WSGI config, it should run.

## Run and serve in one
You have one site you have decided to work on? A convenience, you can override the image entrypoint. Like this,

    docker run -v /srv:/srv --name webapp --entrypoint "runserver" -it dw-dev:2.8 siteName

Note the funny order of options and args. `--entrypoint` only takes the executable `runserver`. The name of the site goes on the end of the commandline, passed in with other unknown args.

## Deploy
Once your site is developed it's up to you to deploy. If you followed the instructions above, you have a stock Django/Wagtail site (or sites) sitting in a safe place on `/srv`.




# One site, extended environment
You'd like to move the container setup towards a real deploy, especially a Docker deploy.

If you want to use the instructions below for a new site, do not generate the new site first. Follow the order below.

## Finding software versions
Whenever you add programs to a Docker setup, in a container or through new services, you need to decide versions. An easy way to decide is to use versions packaged in the base system of the image. Start a bash prompt e.g.

    docker run -it dw-dev:2.8

For Debian-based images like Pyrhon, available packages,

    apt-cache search someProgramName

List what is installed,

    dpkg --get-selections | grep someProgramName

Installed by Pip,

    pip list

Now you know a version which is probably compatible.


## Nginx
Using the main container as a self-contained environment.


### Load an image of Nginx

    docker pull nginx:version


### Nginx config
Create a file on the host filesystem,

    sudo mkdir -p /cfg/docker/nginx
    touch local.conf

Put this in,

    upstream dw_server {
        # Note this host! Declared as an alias in DockerCompose.
        server webapp:8000;
    }

    server {
        listen 80;
        server_name localhost;
        location / {
            # everything is passed to Gunicorn
            proxy_pass http://web_server;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_redirect off;
        }
    }

## Nginx wiring
Make a file `docker-compose.yaml`, which you can place anywhere. It contains,

        webapp:
          image: dw-dev:2.8
          restart: always
          entrypoint: ["runserver", "siteName"]
          volumes:
            - type: bind
              source: /srv
              target: /srv
          networks: 
            nginx_network:


        nginx:
          image: nginx:1.17
          depends_on: 
            - webapp
          ports:
            - 8000:80
          volumes:
            - /cfg/docker/nginx:/etc/nginx/conf.d
          networks:
            - nginx_network

    networks:
        nginx_network:
          driver: bridge


Notes:

- The entrypoint of the container is overridden to provide a service that runs without a terminal. Docker Compose rearranges the args in the array.

- The name of the service is used in the Nginx config file. If you inspect the Nginx container, you will find a hostname with the same name as the service. This is how Nginx finds the address.

- The app is launched before the server, so Nginx can look for the addresses.



### Postgres Database
You may be gaining some confidence this is possible?

#### Load an image of Postgres
Point to note: I use an AlpineOS-variant because it is known to work well with Postgres, 

    docker pull postgres:version-alpine



#### Initialise the database
Sadly, like any big database, Postgres requires initialising. Documentation of the Docker image shows several ways. There seems to be no easy way to automate. I've tried a few ways, and prefer the following,

1. Wire the database with a docker-compose file
2. Adapt the docker-compose file for initialisation, then run it. It will fail, but configures the database
3. Bring docker-compose down, finish the initialisation

The main reason for initialising via docker-compose is that docker-compose modifies mount names. Let it have it's say.


#### Wiring containers 
The container needs to be wired to the Postgres container. Along the way, we add enough configuration to initialise. Somewhere, make a `docker-compose` file,

        postgres1:
          image: postgres:imageVersionTag
          environment:
            POSTGRES_USER: adminUser
            POSTGRES_PASSWORD: adminPassword
            POSTGRES_DB: initialDatabaseName 
            # POSTGRES_INITDB_ARGS: "--locale=en_GB --encoding=UTF8"
          restart: always
          ports: 
            - "5432:5432"
          volumes:
            - postgres_data:/var/lib/postgresql/data
          networks:
            - postgres1_network


        webapp:
          # Add this!
          depends_on:
            - postgres1
          image: dw-dev:2.8
          restart: always
          entrypoint: ["runserver", "siteName"]
          volumes:
            - type: bind
              source: /srv
              target: /srv
          networks: 
            nginx_network:
            # Add this!
            postgres1_network:

    # Add this!
    volumes:
       postgres_data:
     
    networks:
        nginx_network:
          driver: bridge
        # Add this!
        postgres1_network:
          driver: bridge

The database data is mounted to a volume. Docker volumes are located in strange places, but this is an intended use.

The environment variables are configuration for Postgres---no need for an external file. Note that POSTGRES_PASSWORD is the only essential item here, POSTGRES_USER and POSTGRES_DB are used for initialisation,

<dl>
<dt>POSTGRES_PASSWORD</dt>
<dd>Don't make it complicated! Postgres and it's support code can be fussy about non-alphanumeric characters, and may handle escapes. You should make the password long---it's a critical security measure on your site.</dd> 
<dt>POSTGRES_USER</dt>
<dd>Without this, there is a default??? </dd>
<dt>POSTGRES_DB</dt>
<dd>An initial database is created by Postgres. You may as well use this database for a website, so I'd base the name on a compact variant of the sitename.</dd>
</dl>

Bring the services up,

    docker-compose up


#### Extra step, create site
If your environment container has no site in it, then `docker-compose up` will only partially succeed. In the Django/Wagtail container, the `entrypoint` tries to launch a site which doesn't exist, so stops. The container has no process, so it stops. When the environment container stops, Nginx has nothing to serve, so it and it's container stop too.

However, Docker has initialised the database and created a volume. 

Bring the services down,

    docker-compose down

To make a site, you can use use Django methods, or the script. To use the script, start a new, temporary, container,

    docker run --name temp -it -v /srv:/srv dw-dev:2.8 /bin/bash

Make a new site,

    createscaffold

Not a lot will happen (try `ls`). 

We need to connect this code to the database. A good start, the env container has a site to work with. Leave the temp container and remove it. 

    CTRL-D
    docker rm temp

The docker-compose services should now stay up and running,

    docker-compose up

To connect the site to the database, follow the notes below. Or, if you want a stock installation, this script can configure the site, reboot the server, migrate basic data, then set the superuser,

    docker exec -it directoryName_dw_1 /bin/bash
    configuredbsu

Answer the questions. If it all runs, you are ready to go.


#### Existing site, alter DB settings
The Django/Wagtail filebase needs to use another kind of database. 

If you don't need anything special,

    docker exec -it directoryName_dw_1 /bin/bash
    configuredb

will make a configuration file.

Or work by hand. In `/srv/siteName/siteName/settings` make a file `local.py`. This will override surrounding settings. Put this in the file,

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'USER': 'adminUser',
            'PASSWORD': 'adminPassword',
            'NAME': 'siteName',
             # Note this host! Declared in DockerCompose.
            'HOST': 'postgres1', 
            'PORT': '5432',
        }
    }

In case you wonder, `psycopg2` is installed in the image.

Point to note, you can override other Django/Wagtail setting in this file too. The settings are not special.


#### Reboot with the new configuration 
The server needs to know. Easy way,

    docker-compose restart


#### Install Django/Wagtail data in the database
Start a shell,

    docker exec -it directoryName_dw_1 /bin/bash

Navigate to `manage.py`, then run,

    ./manage migrate

If that works, try,

    (http://localhost:8000)

Hopefully you have a working Postgres-driven website.

If you started a new site, you need to create a superuser. Either use the web interface, or,

    ./manage.py createsuperuser

Phew.


#### Psql--- database CRUD from the commandline

Without leaving the main container, you can use the Django/Wagtail utility,

    ./manage.py dbshell

Or, the Postgres container has `psql` in it. Either way, you can examine and manipulate the database from the commandline,

    docker exec -it postgres1 psql -U adminUsername databaseName

From a container shell,

    psql -h localhost -U adminUser databaseName


After reaching the commandline, you can try something like these. These commands will tell you about the database. You should see your configuration values in there,

    \d show tables
    \l show databases
    \q quit

For more, much much more, see [psql documentation](https://www.postgresql.org/docs/9.2/app-psql.html).


# Reference
## Built-in

### Production
- Django
- [Wagtail](https://wagtail.io)
- psycopg2
- [Gunicorn](https://gunicorn.org/)
- [WagtailMenus](https://wagtailmenus.readthedocs.io/en/stable/index.html)

Wagtail is not version locked, relies on Docker Python and Pip.

### Dev
- inotify
- [PSQL Client](https://www.postgresql.org/docs/12/app-psql.html)
- Sqlite3 (and so the CL interface)
- django-extensions
- scripts

Nothing is configured beyond Wagtail. If Wagtail doesn't pull the code in, then you need to configure e.g. for WagtailMenus.

## Missing
Should probably be in, but unexplored,
- SASS or Node
- ElasticSearch

## Links
[Official Docker docs about Django](https://docs.docker.com/compose/django/)


# License
Please bear in mind this is an image, so has a vast variety of software within the build. If you have concerns about licensing, you need to raise them with the responsible sources.
