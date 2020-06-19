# Using SURF HPC Cloud

This guide assumes that the user already has a VM running on [SURF HPC Cloud](https://www.surf.nl/en/hpc-cloud-your-flexible-compute-infrastructure).

We will use a [Vagrant](https://www.vagrantup.com) to create a VM and an Ansible playbook to install a [GitHub Action runner](https://help.github.com/en/actions/hosting-your-own-runners) on it. When done a GitHub action workflow configured with `runs-on: self-hosted` will run on that runner in the VM.

## Prerequisites

* VM running on SURF HPC Cloud
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html),
    I suggest using a Python virtual environment and `pip install ansible`.

## Create a VM

#TODO: SURF_LINK

## Set SSH keys for the VM

#TODO: SURF_SSH_KEY_LINK

## Login to VM


To login to VM with ssh use

```shell
ssh -i $YOUR_KEY_PATH -p 22 $USER@$HOSTNAME
```

## Configure

To use Ansible you need an [inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html). An example inventory file called `hosts.example` should be copied to `hosts` and updated to reflect your situation.

```shell
cp hosts.example hosts
```

Ansible must be configured for which GitHub account/organization and repository it should setup a runner for.

When Ansible command is executed, the Ansible playbook will ask for

- the user or rganization name
- the repository name

As a repository, you can use a clone of [https://github.com/ci-for-science/python-example1](https://github.com/ci-for-science/python-example1) or any repository which has a GitHub Action workflow that has [`runs-on: self-hosted`](https://github.com/ci-for-science/python-example1/blob/4dea9c4f32a9bfcfcf166eb631c7aed3b2097d6c/.github/workflows/ci.yml#L15).

The Ansible playbook uses Personal Access Token for GitHub account to register the runner.
The token needs to have full admin rights for the repo. At the moment the checkbox that needs to be checked is called `repo          Full control of private repositories`. The token can be created [here](https://github.com/settings/tokens).

![Token permission](token_permissions.png?raw=true "Title")


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
hpc | SUCCESS => {
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

The log of the runner, ssh to the server and run

```shell
journalctl -u actions.runner.*
```

## Uninstalling the runner

First unregister runner with

```shell
ansible-playbook playbook.yml --tags uninstall
```


## Examples:

- [Simple Python example](https://github.com/ci-for-science/python-example1)

- [Simple GPU example](https://github.com/ci-for-science/example-gpu-houston)
