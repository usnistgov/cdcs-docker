#!/bin/bash
source .env
CONTAINER_ENGINE="docker"
if [[ " $@ " =~ " --podman " ]]; then
    CONTAINER_ENGINE="podman"
fi
set -- "${@/--podman/}"

email=""
if [ $# -ge 2 ]
  then
    user=$1
    pass=$2
    if [ $# -ge 3 ]
      then
        email=$3
    fi
fi

$CONTAINER_ENGINE exec $COMPOSE_PROJECT_NAME"_cdcs" python ./manage.py shell -c  "from django.contrib.auth.models import User; User.objects.create_superuser('$user', '$email', '$pass')"
