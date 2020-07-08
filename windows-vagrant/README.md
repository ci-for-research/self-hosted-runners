# Setting up a CI server for a GitHub Action runner with Vagrant from Windows

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is VirtualBox Vm, setup through Vagrant, running on localhost.

For guides on how to configure other features in addition to just the runner, go [here](/README.md).

Vagrant is a tool to build a VirtualBox virtual machine (VM).
We will use a [Vagrant](https://www.vagrantup.com) to create a VM and an Ansible playbook to install a [GitHub Action runner](https://help.github.com/en/actions/hosting-your-own-runners) on it. When done a GitHub action workflow configured with `runs-on: self-hosted` will run on that runner in the VM.

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads)
* [Windows subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
* [Ansible installed within WSL](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html),
    I suggest using a Python virtual environment within WSL and `pip install ansible`.

## Starting a VM

Virtual machine can be started from this (/window-vagrant) directory with

```shell
vagrant up
```

This will have started a Ubuntu 18.04 virtual machine in VirtualBox.

## Login to VM

To login to VM with ssh use

```shell
vagrant ssh
```

To use other ssh client get the ssh config with

```shell
vagrant ssh-config
```

This will output something like

```shell
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /<path-to-repo/windows-vagrant/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

**We will use Windows Subsystem for Linux (WSL) from from here on.**
Clone the repo again, this time within the disk space managed by WSL. Because of specific file permissions required, it is easier to work from the disk space with posix permissions, than to use the existing clone on the mounted Windows drive.

To have access to the machine from WSL, the private key needs to be copied from Windows to the WSL repo. To do this, copy the `/window-vagrant/.vagrant` into WSL. Correct the permissions with chmod

```shell
chmod go-rwx .vagrant/machines/default/virtualbox/private_key
```

When this is done, login with ssh using

```shell
ssh -i .vagrant/machines/default/virtualbox/private_key -p 2222 vagrant@127.0.0.1
```

## Client side configuration


## Ansible

Ansible is a tool with which you can do so-called _provisioning_, i.e. automated system administration of remote
machines. We'll use it to set up the GitHub Actions runner.

Ansible does not support Windows. Installing Ansible, and the major part of the rest of this guide, should be done from a Windows Subsystem for Linux (WSL) shell.

Install Ansible.
We recommend installing ansible through pip/PyPi. For more installation options see the list below.

- PyPI: ``pip install ansible``
- default repositories for the OS if they're available (apt, ndf, apk, homebrew)
- PPA (for Ubuntu)
- other options see [docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#selecting-an-ansible-version-to-install)

Make sure your Ansible version is 2.9.9 or later with:
```shell
ansible --version
```

(Find more information [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)).

An example inventory file called `hosts.example` should be copied to `hosts` and updated to reflect your situation.

```shell
cp hosts.example hosts
```

Ansible must be configured for which GitHub account/organization and repository it should setup a runner.
Edit the `hosts` file and set `github_account` key and repository `github_repo` key.

The Ansible playbook uses personal Access Token for GitHub account to register the runner.
The token has to have admin rights for the repo.
Token can be created [here](https://github.com/settings/tokens).

The token should be set as the `PAT` environment variable.

```shell
export PAT=xxxxxxxxxxxxxxx
```

## Install GitHub Action runner using the playbook

To install GitHub Action runner we use an Ansible playbook to provision the VM.

### Test connection with server using ``ansible``

We're about ready to test if we can connect to the server using Ansible. For this we will use the ``ping`` module, and
we'll instruct Ansible to run the module on all hosts as defined in the inventory, as follows:

```shell
ansible all -m ping
```

Which should return:


```shell
vagrant | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

For more complicated tasks than ``ping``, it's often inconvenient having to put everything on the command line. Instead,
a better option is to create a so-called _playbook_ containing all the steps that you want to include in your
provisioning. The playbook is a YAML file that defines a series of ``tasks``. When creating new tasks, one can start
from scratch, or make use of tasks that have been published by others (see [https://galaxy.ansible.com/](https://galaxy.ansible.com/)).



The playbook uses roles from [Ansible galaxy](https://galaxy.ansible.com/), they must be downloaded with

```shell
ansible-galaxy install -r requirements.yml
```

To provision VM use

```shell
ansible-playbook playbook.yml
```

The log of the runner can be viewed with

```shell
vagrant ssh -- journalctl -u actions.runner.*
```

## Destroy VM

First unregister runner with

```shell
ansible-playbook playbook.yml --tags uninstall
```

To get rid of VM use

```shell
vagrant destroy
```

