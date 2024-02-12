#!/bin/bash
PROJECT_NAME=$1

echo "********* Starting UWSGI... *********"
uwsgi --chdir /srv/curator/ \
      --uid cdcs \
      --gid cdcs \
      --socket /tmp/curator/curator.sock \
      --wsgi-file /srv/curator/$PROJECT_NAME/wsgi.py \
      --chmod-socket=666 \
      --processes=${PROCESSES:-8} \
      --threads=${THREADS:-8} \
      --enable-threads \
      --lazy-apps
echo "UWSGI started"