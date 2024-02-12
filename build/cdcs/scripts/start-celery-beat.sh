#!/bin/bash
PROJECT_NAME=$1

/scripts/wait-psql.sh

echo "********* Starting Celery beat... *********"
celery -A $PROJECT_NAME beat -l info