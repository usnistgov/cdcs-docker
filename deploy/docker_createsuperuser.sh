#!/bin/bash
source .env
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

docker exec $PROJECT_NAME"_cdcs" python ./manage.py shell -c  "from django.contrib.auth.models import User; User.objects.create_superuser('$user', '$email', '$pass')"
