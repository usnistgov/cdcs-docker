#!/bin/bash

# Wait for Postgres: https://docs.docker.com/compose/startup-order/
echo "********* Wait for Postgres... *********"
until PGPASSWORD=$POSTGRES_PASS psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

if [ ! -z $POSTGRES_REPLICA_HOST ]; then
  echo "********* Wait for Postgres read replica... *********"
  until PGPASSWORD=$POSTGRES_REPLICA_PASS psql -h "$POSTGRES_REPLICA_HOST" -p "$POSTGRES_REPLICA_PORT" -U "$POSTGRES_REPLICA_USER" -d "$POSTGRES_REPLICA_DB" -c '\q'; do
    >&2 echo "Postgres read replica is unavailable - sleeping"
    sleep 1
  done
fi