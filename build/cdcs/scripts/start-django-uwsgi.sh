#!/bin/bash
PROJECT_NAME=$1

echo "********* Starting UWSGI... *********"
uwsgi_args=(
  --chdir /srv/curator/
  --uid cdcs
  --gid cdcs
  --socket /tmp/curator/curator.sock
  --wsgi-file /srv/curator/$PROJECT_NAME/wsgi.py
  --chmod-socket=666
  --processes=${PROCESSES:-8}
  --threads=${THREADS:-8}
  --enable-threads
  --lazy-apps
)

# Allow live reload for development when requested via env vars.
if [ -n "${UWSGI_AUTORELOAD:-}" ] && [ "${UWSGI_AUTORELOAD}" != "0" ]; then
  uwsgi_args+=(--py-autoreload "${UWSGI_AUTORELOAD}")
fi

if [ -n "${UWSGI_TOUCH_RELOAD:-}" ]; then
  uwsgi_args+=(--touch-reload "${UWSGI_TOUCH_RELOAD}")
fi

uwsgi "${uwsgi_args[@]}"
echo "UWSGI started"
