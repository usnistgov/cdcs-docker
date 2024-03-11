#!/bin/bash
PROJECT_NAME=$1

# FIXME: concurrency issue (See README.md)
sleep 30

/scripts/start-celery-beat.sh $PROJECT_NAME