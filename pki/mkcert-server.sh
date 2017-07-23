#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./mkcert-server.sh <domain-name>"
    exit
fi

domain=$1

echo "Generating server certificate for domain '$domain' and validity of 2 years..."
echo "--> Step 1: generating private key with 2048 bit length"
openssl genrsa -aes256 -out keys/$domain.key.pem 2048
chmod 400 keys/$domain.key.pem
echo "--> Step 2: converting private key to pk8 format"
openssl pkcs8 -in keys/$domain.key.pem -topk8 -out keys/$domain.key.p8
chmod 400 keys/$domain.key.p8
echo "--> Step 3: creating signing request"
openssl req -config ./openssl.cnf -key keys/$domain.key.pem -new -sha256 -out requests/$domain.csr.pem \
    -subj "/CN=$domain"
echo "--> Step 4: signing request with private key from CA"
openssl ca -config ./openssl.cnf \
    -extensions server_cert -days 740 -notext -md sha256 \
    -in requests/$domain.csr.pem \
    -out certificates/completed/$domain.cert.pem
chmod 444 certificates/completed/$domain.cert.pem
echo "Done."