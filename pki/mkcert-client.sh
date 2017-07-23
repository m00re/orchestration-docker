#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./mkcert-client.sh <common-name>"
    exit
fi

commonName=$1

echo "Generating client certificate for common name '$commonName' and validity of 2 years..."
echo "--> Step 1: generating private key with 2048 bit length"
openssl genrsa -aes256 -out keys/$commonName.key.pem 2048
chmod 400 keys/$commonName.key.pem
echo "--> Step 2: converting private key to pk8 format"
openssl pkcs8 -in keys/$commonName.key.pem -topk8 -out keys/$commonName.key.p8
chmod 400 keys/$commonName.key.p8
echo "--> Step 3: creating signing request"
openssl req -config ./openssl.cnf -key keys/$commonName.key.pem -new -sha256 -out requests/$commonName.csr.pem \
    -subj "/CN=$commonName"
echo "--> Step 4: signing request with private key from CA"
openssl ca -config ./openssl.cnf \
    -extensions client_cert -days 740 -notext -md sha256 \
    -in requests/$commonName.csr.pem \
    -out certificates/completed/$commonName.cert.pem
chmod 444 certificates/completed/$commonName.cert.pem
echo "Done."