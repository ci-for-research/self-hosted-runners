
# WORK IN PROGRESS

## Linux Ubuntu client to local machine via Docker

Describe general layout of the approach


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


# ==========================================


# Setting up a CI server for a GitHub Action runner with Dockerfrom Ubuntu Linux

In this guide we will run Github runner using Docker. First we will setup

#TODO: Extend the story


This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever machine will run the tests. This document describes the case where the server is running locally using Docker.
For guides on how to configure alternative setups, go [here](/README.md).

## Prerequisites

_Describe things that users need to install on their system to follow the guide. Things like Ansible, ssh, putty, Windows Subsystem for Linux, etc._

- Install Docker

## Server side configuration

How to run docker container

### Build image

```shell
docker build -t ghrunner \
  --build-arg SSH_USER="ubuntu" \
  --build-arg SSH_PASS="ubuntu" \
  .
```

### Run the server

```shell
docker run -ti --rm -p 2222:2222 --name test_sshd  ghrunner
```

### Test

Use `docker inspect` to find out the IP address of the container
```shell
docker inspect --format '{{ .NetworkSettings.IPAddress }}' test_sshd
```

Output:
```
172.17.0.2
```

```shell
ssh-copy-id -i ./id_rsa -p 2222 ubuntu@172.17.0.2
```

```shell
ssh -i ./id_rsa -p 2222 ubuntu@172.17.0.2
```

docker run --rm -ti -v $PWD:/data --workdir=/data ansible/ansible-runner ansible all -m ping

docker run --rm -ti -v $PWD:/data --workdir=/data ansible/ansible-runner ansible-playbook playbook.yml

ansible-galaxy install -r requirements.yml

ansible-playbook playbook.yml --ask-become-pass

docker exec -ti test_sshd /bin/bash


### Cleanup

```shell
docker container stop test_sshd
docker container rm test_sshd
docker image rm ghrunner
```

## Client side configuration

### Install Ansible

TODO: Explain what is Ansible, why is it useful.

- version >= 2.9.9
- Options (multiple options can apply)
    - default repositories for the OS if they're available (apt, ndf, apk, homebrew)
    - PPA for Ubuntu
    - PyPI: ``pip install ansible``
    - Ansible [docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#selecting-an-ansible-version-to-install)

### Install SSH Client

e.g.

- sudo apt install openssh-client
- install putty
- homebrew install ssh

### Generate key pair

e.g.

- ssh-keygen something something

### Copy key pair to server

e.g.

- ssh-copy-id something something

### Test connection with server using ``ssh``

```
ssh -i <keyfile> -p <port> <username>@<hostname>
```

### Troubleshooting SSH

Getting SSH connections to work can be tricky. Check out [this document](/docs/troubleshooting-ssh.md) if you're experiencing
difficulties.

### The inventory file

TODO: Explain what ``hosts`` is, why you need it, what the options are for (see below)

```yaml
all-my-hosts:
  hosts:
    my-first-host:
  vars:
    ansible_connection: ssh
    ansible_host: <hostname>
    ansible_port: <port>
    ansible_python_interpreter: /usr/bin/python3
    ansible_ssh_private_key_file: <path to keyfile>
    ansible_user: <username>
```

### The Ansible configuration file

TODO: Explain what ``ansible.cfg`` is, why you need it, what the options are for (see below)

```ini
[defaults]
bin_ansible_callbacks = True
inventory = ./hosts
stdout_callback = yaml
```

### Test connection with server using ``ansible``

TODO: Explain command

Introduce concept of what is a module

```shell
ansible all -m ping
```

### Install the runner using the playbook

- Introduce concept of an ansible playbook, and of ``ansible-playbook``
- Introduce concept of what is a role
- Introduce concept of ansible requirements file
- Get a personal access token from GitHub
- Explain why the playbook asks for REPO, ORG and TOKEN

```shell
ansible-playbook playbook.yml
```

### Monitoring the runner service's logs

The log of the runner can be viewed with

```shell
ssh -i <keyfile> -p <port> <username>@<hostname>
```

Then

```shell
journalctl -u actions.runner.*
```

### Start the runner each time the machine boots

```shell
ansible-playbook playbook.yml --tags enable
```

### Start the runner

```shell
ansible-playbook playbook.yml --tags start
```

### Managing the runner service through the playbook

```shell
ansible-playbook playbook.yml --tags start
ansible-playbook playbook.yml --tags stop
ansible-playbook playbook.yml --tags restart
ansible-playbook playbook.yml --tags status
ansible-playbook playbook.yml --tags enable
ansible-playbook playbook.yml --tags disable
```

Uninstalling the runner

```shell
ansible-playbook playbook.yml --tags uninstall
```

### Verify that your newly configured runner is triggered on new Pull Requests and new commits

Add the following simple workflow as ``.github/workflows/self_hosted_ci.yml`` in your repository https://github.com/ORG/REPO:

```yaml
name: Self-hosted CI example

on: [push, pull_request]

jobs:
  test:
    name: test
    runs-on: self-hosted
    steps:
      - name: Show directory listing
        shell: bash -l {0}
        run: |
          ls -la
```

With this workflow in place, new pushes and new pull requests should trigger your self-hosted server. You can see a
record of past and current GitHub Actions by pointing your browser to
https://github.com/ORG/REPO/actions?query=workflow%3A%22Self-hosted+CI+example%22.


### What's next

Find instructions for provisioning additional functionality [here](../README.md).
