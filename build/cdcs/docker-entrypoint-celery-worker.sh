#!/bin/bash
PROJECT_NAME=$1

# FIXME: concurrency issue (See README.md)
sleep 30

/scripts/start-celery-worker.sh $PROJECT_NAME