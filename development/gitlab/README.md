# Setting up certificates for trust between Gitlab and Docker Registry

In order to setup a trust relationship between the Gitlab server and the Docker registry, the following commands need
to be executed prior to the start of the containers.

```
mkdir certs
cd certs
openssl req -new -newkey rsa:4096 > registry.csr
openssl rsa -in privkey.pem -out registry.key
openssl x509 -in registry.csr -out registry.crt -req -signkey registry.key -days 10000
```

It doesn't matter which details (domain name, etc.) you enter during key creation. This information is not used at all.

More details can be found here: https://github.com/sameersbn/docker-gitlab/blob/master/docs/container_registry.md