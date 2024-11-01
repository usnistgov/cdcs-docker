#!/bin/bash
source .env

docker exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py loadexporters
