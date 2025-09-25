#!/bin/bash
PROJECT_NAME=$1
WEB_SERVER=$2

# WEB_SERVER = runserver or uwsgi
/scripts/start-django-$WEB_SERVER.sh $PROJECT_NAME