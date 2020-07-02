# Linux Ubuntu client to local machine via Docker

Describe general layout of the approach

## prerequisites

- install docker

## server side configuration

- build included Dockerfile
- run docker container

## client side configuration

- install ansible from PPA (mind the version)
- install openssh-client
- generate key pair
- copy key pair to server
- test ssh -i keyfile -p 2222 username@127.0.0.1|localhost
- test hello world playbook
