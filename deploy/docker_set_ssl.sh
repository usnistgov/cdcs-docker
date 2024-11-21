#!/usr/bin/env bash

# used https://gist.github.com/sethvargo/81227d2316207b7bd110df328d83fad8 as
# inspiration source for creating own CA with CSR and SAN definition

source .env

# Define where to store the generated certs and metadata.
DIR="$(pwd)/tls"

# Optional: Ensure the target directory exists and is empty.
rm -rf "${DIR}"
mkdir -p "${DIR}"

# Create the openssl configuration file. This is used for both generating
# the certificate as well as for specifying the extensions. It aims in favor
# of automation, so the DN is encoding and not prompted.
cat > "${DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
encrypt_key  = no # Change to encrypt the private key using des3 or similar
default_md   = sha256
prompt       = no
utf8         = yes
# Speify the DN here so we aren't prompted (along with prompt = no above).
distinguished_name = req_distinguished_name
# Extensions for SAN IP and SAN DNS
req_extensions = v3_req
# Be sure to update the subject to match your organization.
[req_distinguished_name]
C  = US
ST = MD
O  = CDCS
CN = CDCS
# Allow client and server auth. You may want to only allow server auth.
# Link to SAN names.
[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names
# Alternative names are specified as IP.# and DNS.# for IP addresses and
# DNS accordingly. 
[alt_names]
DNS.1 = ${HOSTNAME}
EOF

echo "Create CA"
openssl req \
  -new \
  -newkey rsa:2048 \
  -days 365 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=MD/O=CDCS CA" \
  -keyout "${DIR}/cdcsCA.key" \
  -out "${DIR}/cdcsCA.crt"

echo "generate CDCS key"
# Generate the private key for the service
openssl genrsa -out "${DIR}/cdcs.key" 4096

echo "create the certificate signing request (csr)"
# Generate a CSR using the configuration and the key just generated. We will
# give this CSR to our CA to sign.
openssl req \
  -new -key "${DIR}/cdcs.key" \
  -out "${DIR}/cdcs.csr" \
  -config "${DIR}/openssl.cnf"

echo "sign CSR with our CA to generate CDCS certificate"
# Sign the CSR with our CA. This will generate a new certificate that is signed
# by our CA.
openssl x509 \
  -req \
  -days 365 \
  -in "${DIR}/cdcs.csr" \
  -CA "${DIR}/cdcsCA.crt" \
  -CAkey "${DIR}/cdcsCA.key" \
  -CAcreateserial \
  -extensions v3_req \
  -extfile "${DIR}/openssl.cnf" \
  -out "${DIR}/cdcs.crt"

echo "verifying certificate"
# (Optional) Verify the certificate.
openssl x509 -in "${DIR}/cdcs.crt" -noout -text

echo "copy certificate and key to nginx container"
docker cp "${DIR}/cdcs.key" $PROJECT_NAME"_cdcs_nginx:/etc/nginx/cdcs.key"
docker cp "${DIR}/cdcs.crt" $PROJECT_NAME"_cdcs_nginx:/etc/nginx/cdcs.crt"

echo "copy certificate to cdcs container"
docker exec $PROJECT_NAME"_cdcs" mkdir -p /srv/curator/certs
docker cp "${DIR}/cdcs.crt" $PROJECT_NAME"_cdcs:/srv/curator/certs/cdcs.crt"

echo "run c_rehash on the certs folder"
docker exec $PROJECT_NAME"_cdcs" c_rehash /srv/curator/certs/

echo "restart containers"
docker restart $PROJECT_NAME"_cdcs_nginx"
docker restart $PROJECT_NAME"_cdcs"

echo "delete certificate and key from host"
cp "${DIR}/cdcsCA.crt" "$(pwd)"
rm -r "${DIR}"

echo "To make things work locally, please trust cdcsCA.crt to identify websites on your local machine"