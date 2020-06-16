# Linux Ubuntu client to remote machine at SURF HPC Cloud

Describe general layout of the approach

## prerequisites

- account
- url to HPC Cloud frontend for managing VMs
 
## server side configuration

## client side configuration

- install ansible from PPA (mind the version)
- install openssh
- generate key pair
- copy key pair to server
- test ssh -i keyfile -p 2222 username@127.0.0.1|localhost
- test hello world playbook
