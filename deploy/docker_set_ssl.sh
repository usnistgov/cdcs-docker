#!/usr/bin/env bash

source .env

echo "generate self signed certificate"
openssl req -newkey rsa:2048 -nodes -subj "/CN="$HOSTNAME -keyout cdcs.key -x509 -days 365 -out cdcs.crt

echo "copy certificate and key to nginx container"
docker cp cdcs.key $COMPOSE_PROJECT_NAME"_cdcs_nginx:/etc/nginx/cdcs.key"
docker cp cdcs.crt $COMPOSE_PROJECT_NAME"_cdcs_nginx:/etc/nginx/cdcs.crt"

echo "copy certificate to cdcs container"
docker exec $COMPOSE_PROJECT_NAME"_cdcs" mkdir -p /srv/curator/certs
docker cp cdcs.crt $COMPOSE_PROJECT_NAME"_cdcs:/srv/curator/certs/cdcs.crt"

echo "run c_rehash on the certs folder"
docker exec $COMPOSE_PROJECT_NAME"_cdcs" c_rehash /srv/curator/certs/

echo "restart containers"
docker restart $COMPOSE_PROJECT_NAME"_cdcs_nginx"
docker restart $COMPOSE_PROJECT_NAME"_cdcs"

echo "delete certificate and key from host"
rm cdcs.key cdcs.crt