#!/bin/bash
source .env

docker exec $PROJECT_NAME"_cdcs" python ./manage.py loadmodules
