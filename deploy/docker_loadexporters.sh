#!/bin/bash
source .env
CONTAINER_ENGINE="docker"
if [[ " $@ " =~ " --podman " ]]; then
    CONTAINER_ENGINE="podman"
fi
set -- "${@/--podman/}"

$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py loadexporters
