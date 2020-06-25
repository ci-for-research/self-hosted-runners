# Title

Title format:

- Setting up a CI server for a GitHub Action runner with [Docker|Virtualbox|Vagrant] from [Linux Ubuntu|MacOS|Windows]
- Setting up a CI server for a GitHub Action runner on [HPC Cloud|other hardware] from [Linux Ubuntu|MacOS|Windows]

_Describe the plan, what will be the outcome of this guide_

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is <something something, e.g. a HPC cloud machine, a VirtualBox Vm running on localhost, etc.>.
For guides on how to configure alternative setups, go [here](/README.md).

## Prerequisites

_Describe things that users need to install on their system to follow the guide. Things like Ansible, ssh, putty, Windows Subsystem for Linux, etc._


## Server side configuration

E.g. how to configure VirtualBox, how to run docker container, how to configure HPC cloud machine

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

### Monitoring the service logs

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

### Verify that Pull Requests trigger your newly configured runner

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
