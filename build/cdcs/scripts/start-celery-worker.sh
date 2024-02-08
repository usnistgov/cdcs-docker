#!/bin/bash
PROJECT_NAME=$1

/scripts/wait-psql.sh

echo "********* Starting Celery worker... *********"
celery -A $PROJECT_NAME worker -E -l info