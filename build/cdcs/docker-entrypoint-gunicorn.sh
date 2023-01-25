#!/bin/bash
PROJECT_NAME=$1

echo "********* Starting Gunicorn... *********"
gunicorn --config=/etc/gunicorn.conf.py $PROJECT_NAME.wsgi:application
echo "Gunicorn started"