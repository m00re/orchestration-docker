# Log management

Simple log management is implemented based on the popular ELK stack. The setup comprises four services:

1. An Elasticsearch instance for managing the log indices
2. A Kibana instance without X-Pack security and without X-Pack monitoring support
3. A Nginx web server that protects access to Kibana via Basic-Auth using an LDAP-authenticator
4. A Logstash instance that listens for incoming log reports

## Elasticsearch setup

No special setup required, simply start the service via

```
$ docker-compose up -d elasticsearch
```

## Kibana setup

No special setup required, simply start the service via

```
$ docker-compose up -d kibana
```

but keep in mind that no Kibana-ports (e.g. port 5601) are exposed to the host environment. You can not access Kibana
from outside.

## Nginx web server setup

The Nginx webserver proxies all incoming requests to the Kibana instance on port 5601. Since X-Pack security is disabled,
 authentication is performed using the LDAP directory that was already set up for Jenkins, Gitlab, etc. 
 
> The provided configuration example in ```nginx.conf.template``` ensures that only the ```admin``` user can access Kibana.
 
Before starting the service, make sure that the configuration template is renamed and adjusted as required.

```
$ cp monitoring/nginx.conf.template monitoring/nginx.conf
$ docker-compose up -d kibana-protect
```

By default, Kibana can be accessed at http://YOUR_SERVER_NAME:9005/

## Logstash setup

Log reports can be sent to Logstash using the [Beats input plugin](https://github.com/logstash-plugins/logstash-input-beats).
 The default configuration accepts log reports only from trusted clients via TLS on port 5044. As a consequence,
 it is required to setup a small PKI and distribute the server and client certificates accordingly. Based on the documentation
 given [here](../pki/README.md), that translates into the following tasks:
 
1. A root CA needs to be set up.
2. A server certificate for the Logstash instance needs to be generated and signed by the root CA.
3. A client certificate needs to be generated and signed by the root CA for each Filebeat log reporter.

### Logstash server configuration

The existing configuration template expects the following files to be existing:
 
- ```pki/certificates/completed/ca.cert.pem```: the certificate of the root CA
- ```pki/certificates/completed/logstash.example.com.cert.pem```: the server certificate of the Logstash instance
- ```pki/keys/logstash.example.com.key.p8```: the private key of the Logstash instance in PKCS #8 format

If you named your certificates and private keys differently, please adjust the paths of the corresponding Logstash 
instance volumes in ```docker-compose.override.yml```.

If your private key is protected by a passphrase (which you should do), also adjust the environment variable 
```INPUT_BEATS_SSL_KEY_PASSPHRASE``` in ```docker-compose.override.yml``` and ensure that this file can only be read by
the root user.

Once everything is configured, the Logstash service can be started.

```
$ docker-compose up -d logstash
```

### Filebeat client configuration

This is an example configuration for Filebeat, that monitors all JSON log files from Docker and reports changes to the
 Logstash server configured above.
 
```
filebeat.prospectors:
- input_type: log
  paths:
    - /var/lib/docker/containers/**/*-json.log
  json.keys_under_root: true
  json.message_key: log
  fields:
    source: docker

name: dev.example.com
tags: []

output.logstash:
  hosts: ["logstash.example.com:5044"]
  ssl.certificate_authorities: ["__ROOT_OF_ORCHESTRATION_FOLDER__/pki/certificates/completed/ca.cert.pem"]
  ssl.certificate: "__ROOT_OF_ORCHESTRATION_FOLDER__/pki/certificates/completed/dev.example.com.cert.pem"
  ssl.key: "__ROOT_OF_ORCHESTRATION_FOLDER__/pki/keys/dev.example.com.key.pem"
  ssl.key_passphrase: "12345678"
  ssl.verification_mode: "full"
```

The following key aspects have to be guaranteed:
- The domain name of the Logstash server certificate (i.e. the common name part) has to be identical to the hostname 
specified in ```output.logstash.hosts```.
- The verification mode needs to be set to ```full```, else the server certificate will not be checked properly.
- The certificate used by Filebeat needs to be a client certificate. Using a server certificate will not work.
- In the above example snippet, you need to replace the placeholder ```__ROOT_OF_ORCHESTRATION_FOLDER__``` with the absolute
path to where you checked out this repository.