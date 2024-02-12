#!/bin/bash

/scripts/wait-psql.sh

echo "********* Check Postgres tables... *********"
tables_found=`PGPASSWORD=$POSTGRES_PASS psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\dt' | wc -l`

if [ $tables_found -eq 0 ]; then
    echo "********* Migrate apps... *********"
    /srv/curator/manage.py migrate
fi