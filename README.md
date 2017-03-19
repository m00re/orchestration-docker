# Docker Orchestration Template: OpenLDAP-based Gitlab, Taiga, Jenkins & Vagrant Repo

This is an orchestration template for Docker, that helps to setup a working Gitlab, Taiga & Jenkins environment
within a few minutes. It uses the following Docker Images:

 - Gitlab: https://hub.docker.com/r/sameersbn/gitlab/
 - Taiga: https://hub.docker.com/r/m00re/taiga/
 - Jenkins: https://hub.docker.com/r/m00re/jenkins-docker/ and https://hub.docker.com/r/m00re/jenkins-slave-hashicorp/
 - Vagrant Repository: https://github.com/m00re/nginx-ldap-docker

## Starting up all containers

Before starting all services, you need to override the default login, account and hostname environment variables. Simply
use the file `docker-compose.override.yml.template` as a starting point and name it `docker-compose.override.yml`.

```
$ cp docker-compose.override.yml.template docker-compose.override.yml
$ nano -w docker-compose.override.yml
```

Edit the existing environment variables as you prefer. You can override also the environment variables that are defined
in the `docker-compose.yml` definitions of each respective application.

Once you are done, you can launch the services via

```
$ docker-compose up -d openldap
$ docker-compose up -d taiga
$ docker-compose up -d jenkins-master
$ docker-compose up -d jenkins-slave-vagrant-instance-1
$ docker-compose up -d gitlab
$ docker-compose up -d vagrant-repository
```

To make sure all LDAP accounts are created prior to starting the services, proceed with the next section directly after
starting the `openldap` container.

## Initialising LDAP directory

Before importing the directory structure, you have to generate new passwords for the user/applications accounts and 
need to insert them into the file `openldap/init.ldif`. This can easily be done using the following command:

```
$ docker exec <DockerComposePrefix>_openldap_1 slappasswd -s <YourSecurePassword>
```

By default, the following three user/application accounts are created:

 - maintainer: the main developer account
 - admin: the administration account for Jenkins, Taiga and Gitlab
 - swarm: the Jenkins slave node account

Feel free to add more accounts. 

Once you are done with editing the file `init.ldif`, copy it to the docker volume directory 
`/var/lib/docker/volumes/<DockerComposePrefix>_openldap_1/_data` and run the following command.

```
docker exec <DockerComposePrefix>_openldap_1 ldapadd -x -D "cn=admin,dc=example,dc=com" -f /var/lib/ldap/init.ldif -w <YourLdapAdminPassword>
```

## Configuring Jenkins for LDAP-based authentication

As the Jenkins docker container does not automatically configure LDAP authentication, you need to configure it manually.
After logging in with the defined Jenkins admin account, go to `Manage Jenkins - Configure Security` and enable the LDAP
 realm using the following extended settings:
 
 - Server name: `openldap`
 - Stamm-DN: `dc=example,dc=com`
 - Base for user queries: `ou=accounts`
 - Filter for user names: `uid={0}`
 - Base for group queries: `ou=groups`
 - Group membership: select `Search for groups containing user`
 - Manager DN: `cn=readonly,dc=example,dc=com`
 - Manager Password: enter the configured password from `init.ldif
 - Display name LDAP attribute: `displayName`
 - E-Mail address LDAP attribute: `mail`

## Configuring Vagrant Box Repository

To make sure that the private Vagrant box repository performes proper authentication and authorization against the LDAP
directory, rename (or copy) the provided template ```vbox-repository/nginx.conf.template``` to 
```vbox-repository/nginx.conf.template``` and adjust the LDAP-parameters as required. Afterwards, bring up the repository
via

```
$ docker-compose up -d vagrant-repository
```

## Notes

Even though you can specify initial admin credentials for the Docker images of Jenkins, Taiga, and Gitlab, those will not
work. All services always use the admin account defined in LDAP, hence you have to use the password stored in the LDAP
directory.