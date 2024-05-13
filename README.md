# CDCS Docker

This repository contains `docker-compose` files to build and deploy CDCS containers.

## Prerequisites

Install [Docker](https://docs.docker.com/engine/install/#server) first, then install [Docker Compose](https://docs.docker.com/compose/install/).


## Build a CDCS image

### 1. Customize the build

Update the values in the `.env` file:

```shell
cd build
vim .env
```

Below is the list of environment variables to set and their description.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS/Django project to build (e.g. mdcs, nmrr) |
| IMAGE_NAME            | Name of the image to build (e.g. mdcs, nmrr) |
| IMAGE_VERSION         | Version of the image to build (e.g. latest, 2.10.0) |
| CDCS_REPO             | URL of the CDCS repository to clone to build the image (e.g. https://github.com/usnistgov/mdcs.git) |
| BRANCH                | Branch/Tag of the repository to pull to build the image (e.g. master, 2.10.0) |
| PIP_CONF              | Pip configuration file to use to build the image |
| PYTHON_VERSION        | Version of the Python image to use as a base image for the CDCS image |


### 2. Build the image

```shell
docker-compose build --no-cache
```

### 3. Build a custom image (optional)

Different images may be needed for different deployment contexts 
(development/CI/production, docker-compose/K8s, ...).

The `custom` build configuration allows adding the following elements
to an existing CDCS image, by editing the following files:
- `packages.txt`: install additional linux packages (see [example_packages.txt](build/custom/examples/example_packages.txt)),
- `requirements.txt`: install additional python packages (see [example_requirements.txt](build/custom/examples/example_requirements.txt)),
- `settings.py`: add settings to settings.py file (see [example_settings.py](build/custom/examples/example_settings.py)).

To configure the image to build, edit the following variables in the `.env` file.

| Variable | Description                                              |
| ----------- |----------------------------------------------------------|
| BASE_IMAGE_NAME       | Name of the base image (e.g. mdcs, nmrr)          |
| BASE_IMAGE_VERSION    | Version of the base image (e.g. latest, 2.10.0)   |
| PROJECT_NAME          | Name of the CDCS/Django project to build (e.g. mdcs, nmrr) |
| IMAGE_VERSION         | Version of the image to build (e.g. latest, 2.10.0)      |
| IMAGE_VERSION         | Version of the image to build (e.g. latest, 2.10.0)      |

Then build the custom image.

```commandline
cd build/custom
vim .env
vim packages.txt
vim requirements.txt
vim settings.py
docker-compose build --no-cache
``` 

## Deploy a CDCS

### 1. Customize the deployment

Update the values in the `.env` file:

```shell
cd deploy
vim .env
```
Below is the list of environment variables that can be set and their
description. Commented variables in the `.env` need to be uncommented
and filled.

| Variable | Description |
| ----------- | ----------- |
| PROJECT_NAME          | Name of the CDCS/Django project to deploy (e.g. mdcs, nmrr) |
| IMAGE_NAME            | Name of the CDCS image to deploy (e.g. mdcs, nmrr) |
| IMAGE_VERSION         | Version of the CDCS image to deploy (e.g. latest, 2.10.0) |
| HOSTNAME              | Hostname of the server (e.g. for local deployment, use the machine's IP address xxx.xxx.xxx.xxx) |
| SERVER_URI            | URI of server (e.g. for local deployment, http://xxx.xxx.xxx.xxx) |
| ALLOWED_HOSTS         | Comma-separated list of hosts (e.g. ALLOWED_HOSTS=127.0.0.1,localhost), see [Allowed Hosts](https://docs.djangoproject.com/en/4.2/ref/settings/#allowed-hosts) |
| SERVER_NAME           | Name of the server (e.g. MDCS) |
| SETTINGS              | Settings file to use during deployment ([more info in the Settings section](#settings))|
| SERVER_CONF           | Mount appropriate nginx file (e.g. `default` for http deployment using a uWSGI UNIX socket, `https` to enable SSL, or `gunicorn_http[s]`. The protocol of the `SERVER_URI` should be updated accordingly) |
| MONGO_PORT            | MongoDB Port (default: 27017) |
| MONGO_ADMIN_USER      | Admin user for MongoDB (should be different from `MONGO_USER`) |
| MONGO_ADMIN_PASS      | Admin password for MongoDB |
| MONGO_USER            | User for MongoDB (should be different from `MONGO_ADMIN_USER`) |
| MONGO_PASS            | User password for MongoDB |
| MONGO_DB              | Name of the Mongo database (e.g. cdcs) |
| POSTGRES_PORT         | Postgres Port (default: 5432) |
| POSTGRES_USER         | User for Postgres |
| POSTGRES_PASS         | User password for Postgres |
| POSTGRES_DB           | Name of the Postgres database (e.g. cdcs) |
| REDIS_PORT            | Redis Port (default: 6379) |
| REDIS_PASS            | Password for Redis |
| DJANGO_SECRET_KEY     | [Secret Key](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/#secret-key) for Django (should be a "large random value") |
| NGINX_PORT_80         | Expose port 80 on host machine for NGINX |
| NGINX_PORT_443        | Expose port 443 on host machine for NGINX |
| MONGO_VERSION         | Version of the MongoDB image |
| REDIS_VERSION         | Version of the Redis image |
| POSTGRES_VERSION      | Version of the Postgres image |
| NGINX_VERSION         | Version of the NGINX image |
| WEB_SERVER            | Web server for the CDCS (e.g. `uwsgi`, `gunicorn`)
| PROCESSES             | Number of uWSGI processes (default `--processes=8`) / Gunicorn workers to start (default `workers=cpu_count() * 2 + 1`) |
| THREADS               | Number of uWSGI/Gunicorn threads per process/worker (default 8)|
| MONITORING_SERVER_URI | (optional) URI of an APM server for monitoring |

A few additional environment variables are provided to the CDCS
container. The variables below are computed based on the values of
other variables. If changed, some portions of the `docker-compose.yml`
might need to be updated to stay consistent.

| Variable | Description |
| ----------- | ----------- |
| DJANGO_SETTINGS_MODULE  | [`DJANGO_SETTINGS_MODULE`](https://docs.djangoproject.com/en/4.2/topics/settings/#envvar-DJANGO_SETTINGS_MODULE) (set using the values of `PROJECT_NAME` and `SETTINGS`)  |
| MONGO_HOST | Mongodb hostname (set to `${PROJECT_NAME}_cdcs_mongo`) |
| POSTGRES_HOST | Postgres hostname (set to `${PROJECT_NAME}_cdcs_postgres`) |
| REDIS_HOST | REDIS hostname (set to `${PROJECT_NAME}_cdcs_redis`) |


#### SAML2

Configure SAML2 authentication by providing values for the following environment variables in the `saml2/.env` file.
See `saml2/.env.example` for an example of SAML2 configuration with a Keycloak server.

| Variable | Description |
| ----------- | ----------- |
| ENABLE_SAML2_SSO_AUTH | Enable SAML2 authentication (e.g. `ENABLE_SAML2_SSO_AUTH=True`)|
| SAML_ATTRIBUTE_MAP_DIR | Points to a directory which has the attribute maps in Python modules (see [attribute_map_dir](https://pysaml2.readthedocs.io/en/latest/howto/config.html#attribute-map-dir))|
| SAML_ATTRIBUTES_MAP_IDENTIFIER | SAML attribute map supported name-format (see [attribute_map_dir](https://pysaml2.readthedocs.io/en/latest/howto/config.html#attribute-map-dir)) |
| SAML_ATTRIBUTES_MAP_UID | SAML attribute mapping to uid |
| SAML_ATTRIBUTES_MAP_UID_FIELD | SAML attribute mapping uid field name |
| SAML_ATTRIBUTES_MAP_EMAIL| SAML attribute mapping to email |
| SAML_ATTRIBUTES_MAP_EMAIL_FIELD| SAML attribute mapping email field name |
| SAML_ATTRIBUTES_MAP_CN | SAML attribute mapping to common name |
| SAML_ATTRIBUTES_MAP_CN_FIELD | SAML attribute mapping common name field name |
| SAML_ATTRIBUTES_MAP_SN | SAML attribute mapping to surname |
| SAML_ATTRIBUTES_MAP_SN_FIELD | SAML attribute mapping surname field name |
| SAML_DJANGO_USER_MAIN_ATTRIBUTE | Django field to use to find user and create session (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_USE_NAME_ID_AS_USERNAME | Use SAML2 name id as username (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_CREATE_UNKNOWN_USER | Create user if not found in Django database (see [user attributes and account linking](https://djangosaml2.readthedocs.io/contents/setup.html#users-attributes-and-account-linking))|
| SAML_KEY_FILE | Path to private key (see [key_file](https://pysaml2.readthedocs.io/en/latest/howto/config.html#key-file)) |
| SAML_CERT_FILE | Path to the public key (see [cert_file](https://pysaml2.readthedocs.io/en/latest/howto/config.html#cert-file)) |
| SAML_METADATA_REMOTE_URL | Url to remote SAML metadata file (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_METADATA_REMOTE_CERT | (Optional) Certificate for the remote (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_METADATA_LOCAL | Path to local SAML metadata file (see [metadata](https://pysaml2.readthedocs.io/en/latest/howto/config.html#metadata))|
| SAML_XMLSEC_BIN_PATH | Full path to xmlsec1 binary program (see [xmlsec_binary](https://pysaml2.readthedocs.io/en/latest/howto/config.html#xmlsec-binary)) |
| SAML_WANT_RESPONSE_SIGNED | Set to `True` if responses must be signed (see [want_response_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#want-response-signed))|
| SAML_WANT_ASSERTIONS_SIGNED | Set to `True` if assertions must be signed  (see [want_assertions_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#want-assertions-signed)) |
| SAML_LOGOUT_REQUESTS_SIGNED | Set to `True` if logout requests must be signed  (see [logout_requests_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#logout-requests-signed)) |
| SAML_LOGOUT_RESPONSES_SIGNED | Set to `True` if logout responses must be signed  (see [logout_responses_signed](https://pysaml2.readthedocs.io/en/latest/howto/config.html#logout-responses-signed)) |
| SAML_SIGNING_ALGORITHM | Signing algorithm  (see [signing_algorithm](https://pysaml2.readthedocs.io/en/latest/howto/config.html#signing-algorithm)) |
| SAML_DIGEST_ALGORITHM | Digest algorithm  (see [digest_algorithm](https://pysaml2.readthedocs.io/en/latest/howto/config.html#digest-algorithm))|
| CONTACT_PERSON_N | Contact information for person N (see [contact_person](https://pysaml2.readthedocs.io/en/latest/howto/config.html#contact-person))  |
| ORGANIZATION_NAME_N | Organization name N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|
| ORGANIZATION_DISPLAY_NAME_N | Organization display name N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|
| ORGANIZATION_URL_N | Organization url N (see [organization](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization))|

##### Contact Person and Organization environment variables

Environment variables ending with suffix `_N` are expecting `N` to be a sequence of integers starting at `1`.
For example, if two contact persons need to be added to the SAML configuration, the following variables should be set:
```
CONTACT_PERSON_1=
CONTACT_PERSON_2=
```

1. Contact Person

A contact person environment variable is expecting a comma separated list of values in the following order:
- given name,
- surname,
- company,
- email address,
- type (technical, support, administrative, billing or other).

For example:
```
CONTACT_PERSON_1=Firstname1,Lastname1,Example Co.,contact1@example.com,technical
```

2. Organization

Each section of the SAML organization configuration is stored in a separate environment variable. Each variable is expecting a comma separated pair
composed of:
- label,
- language code.

Below is an example from the Pysaml2 documentation and how to represent it in the CDCS using environment variables.

Example from the [documentation](https://pysaml2.readthedocs.io/en/latest/howto/config.html#organization):
```
"organization": {
    "name": [
        ("Example Company", "en"),
        ("Exempel AB", "se")
    ],
    "display_name": ["Exempel AB"],
    "url": [
        ("http://example.com", "en"),
        ("http://exempel.se", "se"),
    ],
}
```

Equivalent CDCS configuration using environment variables:
```
ORGANIZATION_NAME_1=Example Company,en
ORGANIZATION_NAME_2=Exempel AB,se
ORGANIZATION_DISPLAY_NAME_1=Exempel AB,se
ORGANIZATION_URL_1=http://example.com,en
ORGANIZATION_URL_2=http://exemple.se,se
```

#### hdl.net PID Integration

CDCS supports integration of a hdl.net server to issue and resolve PIDs for
data and blobs. This requires some setting of environment variables at deploy
time to configure effectively. Please see the file
`./deploy/handle/.env.example` for more details.

| Variable                             | Description                                                                                                                                                                                                                                                                                                                           |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ENABLE_HANDLE_PID`                  | Controls whether CDCS is configured to use a handle server for PIDs. If so, all the values below should be set to values specific for your handle server config (contact your handle server administrator for any help). If you enable Handle integration but don't set these values correctly; it's _very_ likely things won't work. |
| `HANDLE_NET_LOOKUP_URL`              | The URL of the handle server to display links (e.g. https://hdl.handle.net)                                                                                                                                                                                                                                                           |
| `HANDLE_NET_REGISTRATION_URL`        | The URL of the handle server for registering records (e.g. https://my-handle-net.domain)                                                                                                                                                                                                                                              |
| `ID_PROVIDER_PREFIXES`               | Prefixes to use when creating handles for data and blobs in CDCS. Comma-separated values.                                                                                                                                                                                                                                             |
| `HANDLE_NET_USER`                    | Handle server authentication for a user that has admin rights to list and create handles on the provided prefix. The value provided here will be encoded as "300:{HANDLE_NET_PREFIX}/{HANDLE_NET_USER}" when it is sent to the handle server, so this value should be just the suffix of the admin handle                             |
| `HANDLE_NET_SECRET_KEY`              | The "secret key" for the admin user specified above. This should be provided as plain text and not encoded in any way. This value corresponds to the secret key that would be used if you were creating a handle via batch file                                                                                                       |
| `PID_XPATH`                          | The location in the default schema in which to store and search for PID values. Should be provided in "dot" notation, with attributes indicated using the "@" character. For example, if your PIDs are stored in an attribute named "pid" on the root element named "Resource", the PID_XPATH value should be "Resource.@pid"         |
| `AUTO_SET_PID`                       | Whether to auto-create PIDs for records that are curated or uploaded without them. Should likely be True if you're using PIDs at all                                                                                                                                                                                                  |
| `HANDLE_NET_RECORD_INDEX`            | Starting index for records when minting handles                                                                                                                                                                                                                                                                                       |
|                                      | _The following are admin settings for the handle config. The default values are probably fine, but they should match any example batch files you have for creating handles on your handle server_                                                                                                                                     |
| `HANDLE_NET_ADMIN_INDEX`             | The admin index value (default: `100`)                                                                                                                                                                                                                                                                                                |
| `HANDLE_NET_ADMIN_TYPE`              | The admin type (default: `HS_ADMIN`)                                                                                                                                                                                                                                                                                                  |
| `HANDLE_NET_ADMIN_DATA_FORMAT`       | The admin data format (default: `admin`)                                                                                                                                                                                                                                                                                              |
| `HANDLE_NET_ADMIN_DATA_INDEX`        | The admin data index value (default: `200`)                                                                                                                                                                                                                                                                                           |
| `HANDLE_NET_ADMIN_DATA_PERMISSIONS`  | The admin data permissions (default: `011111110011`)                                                                                                                                                                                                                                                                                  |


#### Settings

Starting from MDCS/NMRR 2.14, repositories of these two projects will
have settings ready for deployment (not production).

The deployment can be further customized by mounting additional settings
to the deployed containers:
- **Option 1:** Use settings from the image. This option is recommended
if the settings in your image are already well formatted for deployment.
    - Update the `docker-compose.yml` file and comment the line that
    mounts the settings:
    ```
    # - ./cdcs/${SETTINGS}.py:/srv/curator/${PROJECT_NAME}/${SETTINGS}.py
    ```
    - set the `SETTINGS` variable to `settings`.
- **Option 2**: Use default settings from the CDCS image and customize
them. Custom settings can be used to provide CI or production
configurations. For example:
    - Create a `custom_settings.py` file (see `ci_settings.py` or
     `test_settings.py` as examples),
    - set the `SETTINGS` variable to `custom_settings`.
- **Option 3**: Override settings from the image. This will
ignore settings already present in the CDCS image. This option is
recommended for MDCS/NMRR 2.14 and below.
    - Update the `docker-compose.yml` file and change the line that
    mounts the settings to:
    ```
    - ./cdcs/${PROJECT_NAME}.settings.py:/srv/curator/${PROJECT_NAME}/settings.py
    ```
    - set the `SETTINGS` variable to `settings`.

The [`DJANGO_SETTINGS_MODULE`](https://docs.djangoproject.com/en/4.2/topics/settings/#envvar-DJANGO_SETTINGS_MODULE)
environment variable can be set to select which settings to use. By
default the `docker-compose` file sets it using the values of
`PROJECT_NAME` and `SETTINGS` variables.

For more information about production deployment of a Django project,
please check the [Deployment Checklist](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/#deployment-checklist)

#### Web Server

The following web servers are available for the CDCS: uWSGI and Gunicorn. 

The CDCS image contains a default configurations for each:
- The default uWSGI configuration writes in a UNIX socket, that Nginx reads from.
A socket file is mounted in both containers (`cdcs_socket`). 
- Gunicorn on the other hand, communicates with Nginx via a port (8000).

You can switch from one web server to the other by setting `WEB_SERVER` in the `.env` 
file to either `uwsgi` or `gunicorn`.
The Nginx configuration is a little different depending on the web server, so `SERVER_CONF` needs to be updated accordingly:
use `default` (HTTP deployment with uWSGI) or `https` (HTTPS deployment with uWSGI) for uWSGI, and `gunicorn_http` or `gunicorn_https` for Gunicorn.


## 2. Deploy the stack

```shell
docker-compose up -d
```

(Optional) For testing purposes, using the HTTPS protocol, you can then run the following script to generate and copy 
self-signed certificates to the container.
```shell
./docker_set_ssl.sh
```

## 3. Create a superuser

The superuser is the first user that will be added to the CDCS. This is the
main administrator on the platform. Once it has been created, more users
can be added using the web interface. Wait for the CDCS server to start, then run:

```shell
./docker_createsuperuser ${username} ${password} ${email}
```

## 4. Initialize database

From CDCS 2.9, to prevent concurrency issues and avoid running database operations multiple times,
some database initialization commands have been added. These commands need to be run once, 
after the initial deployment of the application.  

- To load the **modules**, run the following command:
```commandline
./docker_loadmodules.sh
```
**NOTE**: If modules are added/removed from the project's `INSTALLED_APPS`, the commands needs to be run again.

- To load the **exporters**, run the following command:
```commandline
./docker_loadexporters.sh
```

## 5. Access

The CDCS is now available at the `SERVER_URI` set at deployment.
Please read important deployment information in the troubleshoot section below.


## 6. Troubleshoot

## Local deployment

**DO NOT** set `HOSTNAME`, `SERVER_URI` and `ALLOWED_HOSTS` to localhost or 127.0.0.1.
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
ALLOWED_HOSTS=xxx.xxx.xxx.xxx
```

**NOTE:** For testing purposes, `ALLOWED_HOSTS` can be set to `*`:
```
ALLOWED_HOSTS=*
```

## Production deployment

- Set `SERVER_CONF` to `https`
- Update the file `nginx/https.conf` if necessary
- Add HTTPS configuration to the mounted `settings.py` file
- Have a look at the [deployment checklist](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/#deployment-checklist)

## Logs

Make sure every component is running properly by checking the logs.
For example, to check the logs of an MDCS instance (`PROJECT_NAME=mdcs`), use the following commands:
```shell
docker logs -f mdcs_cdcs
docker logs -f mdcs_cdcs_nginx
docker logs -f mdcs_cdcs_mongo
docker logs -f mdcs_cdcs_postgres
docker logs -f mdcs_cdcs_redis
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

### MongoDB

In preparation for the release of CDCS 3.x, MongoDB becomes an optional component and 
will not be part of the default stack. It will need to be added for any CDCS 2.x deployment.

To add MongoDB to the CDCS stack, you can do the following:

Update the `.env` file to deploy MongoDB:
```
COMPOSE_FILE=docker-compose.yml:mongo/docker-compose.yml
```

### :construction: Celery (WIP)

By default, CDCS images have been running the django web server but also celery worker and celery beat.
It is now also possible to change this default behavior and run these services 
separately by selecting one of the following entrypoint:
- `docker-entrypoint.sh`: starts the django server, celery worker and celery beat (default)
- `docker-entrypoint-django.sh`: starts the django server only
- `docker-entrypoint-celery-worker.sh`: starts the celery worker only
- `docker-entrypoint-celery-beat.sh`: starts the celery beat only

The default behavior will continue to run these 3 services within the same container.
To deploy the 3 services separately in a docker-compose deployment, you can do the following:

1) Update the file `docker-compose.yml` and set the default entrypoint of the cdcs service to 
only start the django server:

```yaml
cdcs:
  entrypoint: /docker-entrypoint-django.sh
```

2) Then add celery worker and celery beat services to the CDCS stack, by updating the 
`COMPOSE_FILE` variable from the `.env` file:

```
COMPOSE_FILE=docker-compose.yml:celery/docker-compose.yml
```

> :warning: **Concurrency Issue in CDCS < 2.9:** Some CDCS applications make database modifications during their initialization.
> Starting Django and Celery services in parallel can make these scripts run multiple times, 
> causing inconsistencies in the database. The issue needs to be resolved in the code of the
> CDCS apps. In the meantime, a startup delay has been implemented for celery services.

> :page_facing_up: The default entrypoint runs the scripts synchronously and does not have this issue.

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
| ELASTIC_VERSION          | Version of the Elasticsearch image (e.g. 7.16.2) |

On linux, you will need to increase the available [virtual memory](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/vm-max-map-count.html).

## Delete the containers and their data

To delete all the containers of the CDCS stack, run:

```shell
docker-compose down
```

To delete all containers and **all the data**, run:

```shell
docker-compose down -v
```

## Upgrade the CDCS container

When a new version of a CDCS image becomes available, the system can be upgraded by doing the following steps:

1. Stop the stack

```shell
docker-compose stop
```

2. Update the version of the image in `deploy/.env`:

```shell
IMAGE_VERSION=3.6.0 # set the version of the new image
```

3. Restart the stack with the new image:

```shell
docker-compose up -d
```

4. Run the migration script (that will update static files and apply database migrations):

```shell
./docker_migrate.sh
```

**NOTE**: the script will do dry runs and ask for confirmation before applying the changes, but it is  
recommended to create a back up of the databases before starting the migration.

# Disclaimer

[NIST Disclaimer](https://www.nist.gov/disclaimer)
