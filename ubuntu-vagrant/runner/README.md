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

## Test ssh connection to VM

Login with vagrant ssh and get the hostname with

```shell
vagrant ssh -c hostname
```

This should output `vagrant`, which is the hostname of the VM.

(If you get `Host key verification failed` error then clear previous key with `ssh-keygen -R "[127.0.0.1]:2222"` and try again)

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

So to login with ssh client and to get hostname use

```shell
ssh -i .vagrant/machines/default/virtualbox/private_key -p 2222 vagrant@127.0.0.1 hostname
```

It should output `vagrant`, which is the hostname of the VM.

## Configure

To use Ansible you need an [inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html). An example inventory file called `hosts.example` should be copied to `hosts` and updated to reflect your situation.

```shell
cp hosts.example hosts
```

Ansible must be configured for which GitHub account/organization and repository it should setup a runner for.
The repository must be configured in `github_account` and `github_repo` fields in the `hosts` file.
As a repository, you can use a duplicate of [https://github.com/ci-for-science/example-python-1](https://github.com/ci-for-science/example-python-1) repository which has a workflow that runs on a self-hosted runner or any repository which has a GitHub Action workflow that has `runs-on: self-hosted`.

The Ansible playbook uses Personal Access Token for GitHub account to register the runner.
The token needs to have full admin rights for the repo. At the moment the checkbox that needs to be checked is called `repo          Full control of private repositories`. The token can be created [here](https://github.com/settings/tokens).

The token should be set as the `PAT` environment variable.

```shell
export PAT=xxxxxxxxxxxxxxx
```

## Install GitHub Action runner

To install GitHub Action runner we use an Ansible playbook to provision the VM.

Test that Ansible can ping server with

```shell
ansible vagrants -m ping
```

Should output something like

```shell
vagrant | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

(If ping fails please check the connection configuration in `hosts` file matches output of `vagrant ssh-config`)

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
