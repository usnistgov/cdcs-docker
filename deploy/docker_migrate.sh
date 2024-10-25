#!/bin/bash
source .env
docker exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py collectstatic --clear --dry-run --no-input
read -p "Press enter to apply changes:"
docker exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py collectstatic --clear --no-input
docker exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py migrate --plan
read -p "Press enter to apply changes:"
docker exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py migrate