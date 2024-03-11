#!/bin/bash

PROJECT_NAME=$1
WEB_SERVER=$2

echo "********* Initialization... *********"
/scripts/init.sh

echo "********* Starting Django server... *********"
/scripts/start-django.sh $PROJECT_NAME $WEB_SERVER