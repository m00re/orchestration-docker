# Docker Orchestration Template: OpenLDAP-based Gitlab, Taiga, Jenkins & Vagrant Repo

This is an orchestration template for Docker, that helps to setup a working Gitlab, Taiga & Jenkins environment
within a few minutes. It uses the following Docker Images:

 - Gitlab:
 - Taiga:
 - Jenkins:
 - Vagrant Repo:

## How to use



## Starting up all containers

## Initialising LDAP directory

### Preparing the initialisation
Before importing the directory structure, you have to generate new passwords for the user/applications accounts.
This can easily be done using the following command:

```
docker exec openldap slappasswd -s <YourSecurePassword>
```

### Performing the initialisation

## Disclaimer
Please use at your own risk.
