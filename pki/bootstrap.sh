#!/usr/bin/env bash

echo "Step 1: Generating 4096-bit private key for the Root CA..."
echo "-----------------------------------------------------------------------------"
openssl genrsa -aes256 -out keys/ca.key.pem 4096
chmod 400 keys/ca.key.pem
echo ""

echo "Step 2: Creating self-signed certificate for the Root CA..."
echo "-----------------------------------------------------------------------------"
openssl req -config openssl.cnf \
      -key keys/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certificates/completed/ca.cert.pem
chmod 444 certificates/completed/ca.cert.pem
echo ""