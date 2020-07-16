# CDCS Docker

This repository contains `docker-compose` files to build and deploy CDCS containers.

## Prerequisites

Install [Docker](https://docs.docker.com/engine/install/#server) first, then install [Docker Compose](https://docs.docker.com/compose/install/).


## Build a CDCS image

### 1. Customize the build

Update the values in the `.env` file:

``` bash
$ cd build
$ vim .env
```

Below is the list of environment variables to set and their description.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS image to build (e.g. mdcs, nmrr) |
| PROJECT_VERSION       | Name of the tag to build (e.g. latest, 2.10.0) |
| CDCS_REPO             | URL of the CDCS repository to clone to build the image (e.g. https://github.com/usnistgov/mdcs.git) |
| BRANCH                | Branch/Tag of the repository to pull to build the image (e.g. master, 2.10.0) |
| PIP_CONF              | Pip configuration file to use to build the image |
| PYTHON_VERSION        | Version of the Python image to use as a base image for the CDCS image |


### 2. Build the image

``` bash
$ docker-compose build --no-cache
```



## Deploy a CDCS

### 1. Customize the deployment

Update the values in the `.env` file:

``` bash
$ cd deploy
$ vim .env
```
Below is the list of environment variables to set and their description.
Commented variables in the `.env` need to be uncommented and filled.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS image to deploy (e.g. mdcs, nmrr) |
| PROJECT_VERSION       | Version of the CDCS image to deploy (e.g. latest, 2.10.0) |
| HOSTNAME              | Hostname of the server (e.g. for local deployment, use the machine's IP address xxx.xxx.xxx.xxx) |
| SERVER_URI            | URI of server (e.g. for local deployment, http://xxx.xxx.xxx.xxx) |
| SERVER_NAME           | Name of the server (e.g. MDCS) |
| SERVER_CONF           | Mount appropriate nginx file (e.g. default for http, https otherwise. The protocol of the `SERVER_URI` should be updated accordingly) |
| MONGO_ADMIN_USER      | Admin user for MongoDB (should be different from `MONGO_USER`) |
| MONGO_ADMIN_PASS      | Admin password for MongoDB |
| MONGO_USER            | User for MongoDB (should be different from `MONGO_ADMIN_USER`) |
| MONGO_PASS            | User password for MongoDB |
| MONGO_DB              | Name of the Mongo database (e.g. cdcs) |
| POSTGRES_USER         | User for Postgres |
| POSTGRES_PASS         | User password for Postgres |
| POSTGRES_DB           | Name of the Postgres database (e.g. cdcs) |
| REDIS_PASS            | Password for Redis |
| DJANGO_SECRET_KEY     | [Secret Key](https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/#secret-key) for Django (should be a "large random value") |
| NGINX_PORT_80         | Expose port 80 on host machine for NGINX |
| NGINX_PORT_443        | Expose port 443 on host machine for NGINX |
| MONGO_VERSION         | Version of the MongoDB image |
| REDIS_VERSION         | Version of the Redis image |
| POSTGRES_VERSION      | Version of the Postgres image |
| NGINX_VERSION         | Version of the NGINX image |
| MONITORING_SERVER_URI | (optional) URI of an APM server for monitoring |

#### Settings

The deployment can be further customized by editing the `settings.py` file located under `deploy/cdcs`.
The files are currently filled with default values for a deployment of an MDCS or an NMRR system.
It is recommended to customize the file before deploying.


## 2. Deploy the stack

``` bash
$ docker-compose up -d
```

(Optional) For testing purposes, using the HTTPS protocol, you can then run the following script to generate and copy self signed certificates to the container.
``` bash
$ ./docker_set_ssl.sh
```

## 3. Create a superuser

The superuser is the first user that will be added to the CDCS. This is the
main administrator on the platform. Once it has been created, more users
can be added using the web interface. Wait for the CDCS server to start, then run:

```bash
$ ./docker_createsuperuser ${username} ${password} ${email}
```

## 4. Access

The CDCS is now available at the `SERVER_URI` set at deployment.
Please read important deployment information in the troubleshoot section below.


## 5. Troubleshoot

## Local deployment

**DO NOT** set `HOSTNAME` and `SERVER_URI` to localhost or 127.0.0.1.
Even if the system, starts properly, some features may not work
(e.g. the search page may show an error instead of returning data).
When deploying locally, use the computer's IP address to set those two
variables, and use the same IP address **when accessing the CDCS via a web browser**:
If your machine's IP address is xxx.xxx.xxx.xxx, and the default server configuration was
used to deploy the system, access it by typing http://xxx.xxx.xxx.xxx in the address bar of the browser.

Find the IP of the local machine:
- On Linux and MacOS: `ifconfig`
- On Windows: `ipconfig`

Then update the `.env` file:

```
HOSTNAME=xxx.xxx.xxx.xxx
SERVER_URI=http://xxx.xxx.xxx.xxx
```

## Production deployment

- Set `SERVER_CONF` to `https`
- Update the file `nginx/https.conf` if necessary
- Add HTTPS configuration to the mounted `settings.py` file
- Have a look at the [deployment checklist](https://docs.djangoproject.com/en/2.2/howto/deployment/checklist/#deployment-checklist)

## Logs

Make sure every component is running properly by checking the logs.
For example, to check the logs of an MDCS instance (`PROJECT_NAME=mdcs`), use the following commands:
```
$ docker logs -f mdcs_cdcs
$ docker logs -f mdcs_cdcs_nginx
$ docker logs -f mdcs_cdcs_mongo
$ docker logs -f mdcs_cdcs_postgres
$ docker logs -f mdcs_cdcs_redis
```

## MongoDB RAM usage


From https://hub.docker.com/_/mongo
> By default Mongo will set the wiredTigerCacheSizeGB to a value
proportional to the host's total memory regardless of memory limits
you may have imposed on the container. In such an instance you will
want to set the cache size to something appropriate, taking into
account any other processes you may be running in the container
which would also utilize memory.

Having multiple mongodb containers on the same machine could be an
issue as each of them will try to use the same amount of RAM
from the host without taking into account the amount used by other
containers. This could lead to the server running out of memory.

### How to fix it?

The amount of RAM used by mongodb can be restricted by adding the
`--wiredTigerCacheSizeGB` option to the mongodb command:

**Example:**
```yml
command: "--auth --wiredTigerCacheSizeGB 8"
```

More information on MongoDB RAM usage can be found in the
[doc](https://docs.mongodb.com/manual/faq/diagnostics/#faq-memory)

## Additional components

Additional components can be added to the CDCS stack by providing `docker-compose.yml` files for those.
Update the `COMPOSE_FILE` variable in the `.env` file to do so. More information can be found in on this option in the
[documentation](https://docs.docker.com/compose/reference/envvars/#compose_file).

### Elasticsearch

Ongoing developments on the CDCS make use of Elasticsearch.
To add Elasticsearch to the CDCS stack, you can do the following:

Update the `.env` file to deploy Elasticsearch:
```
COMPOSE_FILE=docker-compose.yml:elasticsearch/docker-compose.yml
```

Add and fill the following environment variables:

| Variable | Description |
| ----------- | ----------- |
| ELASTIC_VERSION          | Version of the Elasticsearch image (e.g. 7.0.1) |

On linux, you will need to increase the available [virtual memory](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/vm-max-map-count.html).

## Delete the containers and their data

To delete the containers and **all the data** stored in the deployed CDCS system, run:

```
$ docker-compose down -v
```

# Disclaimer

[NIST Disclaimer](https://www.nist.gov/disclaimer)
