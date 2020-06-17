# Setup a server for a GitHub Action runner with Vagrant

Vagrant is a tool to build a VirtualBox virtual machine (VM).

We will use a [Vagrant](https://www.vagrantup.com) to create a VM and an Ansible playbook to install a [GitHub Action runner](https://help.github.com/en/actions/hosting-your-own-runners) on it. When done a GitHub action workflow configured with `runs-on: self-hosted` will run on that runner in the VM.

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html),
    I suggest using a Python virtual environment and `pip install ansible`.

## Start VM

Virtual machine can be started from this (/ubuntu-vagrant) directory with

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
  IdentityFile /home/verhoes/git/NLESC-JCER/linux_actions_runner/ubuntu-vagrant/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

So to login with ssh use

```shell
ssh -i .vagrant/machines/default/virtualbox/private_key -p 2222 vagrant@127.0.0.1
```

## Configure

Ansible must be configured for which GitHub account/organization and repository it should setup a runner.
Edit the `inventory.yml` file and set `github_account` key and repository `github_repo` key.

The Ansible playbook uses personal Access Token for GitHub account to register the runner.
The token has to have admin rights for the repo.
Token can be created [here](https://github.com/settings/tokens).

The token should be set as the `PAT` environment variable.

```shell
export PAT=xxxxxxxxxxxxxxx
```

## Install GitHub Action runner

To install GitHub Action runner we use an Ansible playbook to provision the VM.

Test that Ansible can ping server with

```shell
ansible all -m ping
```

Should output something like

```shell
vagrant | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

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
