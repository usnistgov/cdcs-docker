#!/bin/bash
set -euo pipefail

PROJECT_NAME=$1

RUNSERVER_ADDR=0.0.0.0
RUNSERVER_PORT=80
RUNSERVER_SETTINGS=${PROJECT_NAME}.dev_settings

echo "********* Starting Django development server... *********"

python3 /srv/curator/manage.py runserver \
  "${RUNSERVER_ADDR}:${RUNSERVER_PORT}" \
  --settings="${RUNSERVER_SETTINGS}"
