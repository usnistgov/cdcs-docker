#!/bin/bash

PROJECT_NAME=$1
WEB_SERVER=$2

echo "********* Initialization... *********"
/scripts/init.sh

if [ "${START_CELERY:-true}" = "true" ]; then
  echo "********* Starting Celery... *********"
  /scripts/start-celery-worker.sh $PROJECT_NAME &
  /scripts/start-celery-beat.sh $PROJECT_NAME &
else
  echo "********* Skipping Celery startup (START_CELERY=${START_CELERY}) *********"
fi

echo "********* Starting Django server... *********"
/scripts/start-django.sh $PROJECT_NAME $WEB_SERVER
