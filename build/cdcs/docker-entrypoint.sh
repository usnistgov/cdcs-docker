#!/bin/bash

PROJECT_NAME=$1

# Wait for Postgres: https://docs.docker.com/compose/startup-order/
echo "********* Wait for Postgres... *********"
until PGPASSWORD=$POSTGRES_PASS psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "********* Check Postgres tables... *********"
tables_found=`PGPASSWORD=$POSTGRES_PASS psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt' | wc -l`

if [ $tables_found -eq 0 ]; then
    echo "********* Migrate apps... *********"
    /srv/curator/manage.py migrate
fi
echo "********* Collect static files... *********"
/srv/curator/manage.py collectstatic --noinput
echo "********* Compile messages... *********"
/srv/curator/manage.py compilemessages

echo "********* Starting Celery worker... *********"
celery -A $PROJECT_NAME worker -E -l info &
celery -A $PROJECT_NAME beat -l info &

echo "********* Starting UWSGI... *********"
uwsgi --chdir /srv/curator/ \
      --uid cdcs \
      --gid cdcs \
      --socket /tmp/curator/curator.sock \
      --wsgi-file /srv/curator/$PROJECT_NAME/wsgi.py \
      --chmod-socket=666 \
      --processes=$UWSGI_PROCESSES \
      --enable-threads \
      --lazy-apps
echo "UWSGI started"
