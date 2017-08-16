# Setting up the documentation services 

For this to work, the Jenkins Slave with Sphinx/Doxygen supports needs to be able to access the filesystem of the 
HTTP server hosting the documentation via SSH. The followings steps have to be followed to guarantee that this is
  working properly:
  
  1. We need to create SSH key-pairs for both services
     - one key-pair ```p1``` for ```jenkins-slave-sphinx```
     - one key-pair ```p2``` for ```documentation``` 
  2. We need to inject the pairs into the respectives containers
  3. We need to add the public key of ```p1``` as an ```authorized key``` for accessing the ```documentation``` service.
  4. We need to add the public key of ```p2``` as ```known host``` inside of the ```jenkins-slave-sphinx``` service.
  
## Generating the key pairs

Inside of this folder, execute the following commands:

```bash
# First we create the SSH host key for the documentation service
$ mkdir ssh-keypairs/ && \
  ssh-keygen -t ed25519 -f ./ssh-keypairs/documentation/ssh_host_ed25519_key

# Then we create the SSH identity key for the Jenkins slave service 
$ cd ../jenkins-slave/
$ mkdir ssh-keypairs/ && \
  ssh-keygen -t ed25519 -f ./ssh-keypairs/id_ed25519
```

When being asked for a passphrase, keep it empty.

## Adding p1 as authorized key

First we need to generate the ```authorized_keys``` file.

```bash
$ cat ../jenkins-slave/ssh-keypairs/id_ed25519.pub > ./authorized_keys
```

Afterwards we can make sure that they keys and the authorized_keys file are injected into the documentation service.

```
volumes:
  - ./ssh-keypairs/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key:Z
  - ./ssh-keypairs/ssh_host_ed25519_key.pub:/etc/ssh/ssh_host_ed25519_key.pub:Z
  - ./authorized_keys:/root/.ssh/authorized_keys:Z
```

## Adding p2 as known host

First we need to generate the ```known_hosts``` file.

```bash
$ awk '{ print "documentation", $1, $2 }' ./ssh-keypairs/ssh_host_ed25519_key.pub > ../jenkins-slave/known_hosts
```

Afterwards we can make sure that the keys and the known_hosts file are injected into the Jenkins slave service.

```
volumes:
  - ./ssh-keypairs/id_ed25519:/root/.ssh/id_ed25519:Z
  - ./ssh-keypairs/id_ed25519.pub:/root/.ssh/id_ed25519.pub:Z
  - ./known_hosts:/root/.ssh/known_hosts:Z
```