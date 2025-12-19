#!/bin/bash
source .env
CONTAINER_ENGINE="docker"
if [[ " $@ " =~ " --podman " ]]; then
    CONTAINER_ENGINE="podman"
fi
set -- "${@/--podman/}"

$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py collectstatic --clear --dry-run --no-input
read -p "Press enter to apply changes:"
$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py collectstatic --clear --no-input
$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py migrate --plan
read -p "Press enter to apply changes:"
$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py migrate