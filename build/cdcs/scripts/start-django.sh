#!/bin/bash
PROJECT_NAME=$1
WEB_SERVER=$2

echo "********* Collect static files... *********"
/srv/curator/manage.py collectstatic --noinput
echo "********* Compile messages... *********"
/srv/curator/manage.py compilemessages

/scripts/start-django-$WEB_SERVER.sh $PROJECT_NAME