#!/bin/bash

. /docker-entrypoint-common.sh $1

echo "********* Starting Gunicorn... *********"
gunicorn --config=/etc/gunicorn.conf.py $PROJECT_NAME.wsgi:application
echo "Gunicorn started"