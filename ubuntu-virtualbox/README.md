# Setting up a CI server with a GitHub Action runner using VirtualBox, from Linux Ubuntu

After following this guide, you'll have a simple GitHub action workflow on a GitHub repository of your choice. When new
commits are made to your repository, the workflow delegates work to a server which runs in a Virtual Machine on your own
computer.

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine runs the tests. This document describes the case where the server is a virtual machine, running on your own
physical machine. For guides on how to configure other features in addition to just the runner, go [here](/README.md).

## TL;DR

1. create a virtual machine with an SSH server
1. enable access to the server via SSH keys
1. ``ansible-playbook --ask-become-pass playbook.yml``

## Prerequisites

1. Install VirtualBox on the client: [https://www.virtualbox.org/wiki/Linux_Downloads](https://www.virtualbox.org/wiki/Linux_Downloads)
1. Download an Ubuntu iso image from [https://ubuntu.com/#download](https://ubuntu.com/#download). Both the desktop and the server variant are
suitable --choose whichever you're comfortable with.

## Server side configuration

1. Create a new virtual machine in VirtualBox. It's recommended to give it at least 4 GB memory, 2 CPUs, and 20 GB disk space (dynamically allocated).
1. For the new virtual machine, go to _Settings_ > _Storage_, then under _IDE controller_ select the item marked _Empty_. Then click the icon to load something into the virtual optical disk, then select the Ubuntu iso file.
1. For the new virtual machine, go to _Settings_ > _Network_
    1. On the _Adapter 1_ tab,
        - make sure that the _Enable Network Adapter_ checkbox is checked
        - set the _Attached to_ dropdown menu to _NAT_
        - Click _Advanced_, then _Port Forwarding_
        - Add a new rule, with _Protocol_ TCP, _HostIP_ 127.0.0.1, _Host Port_ 2222, leave _Guest IP_ empty, and _Guest Port_ 22
1. Start the Virtual Machine for the first time.
1. In Ubuntu's install wizard, call the user ``tester``
1. In Ubuntu's install wizard, set the user's password to ``password``
1. Update packages

    ```shell
    sudo apt update
    sudo apt upgrade
    ```

1. Configure an SSH server (OpenSSH) for remote connection; check permissions on relevant files and directories:

    ```shell
    sudo apt install openssh-server
    chmod go-w /home/tester
    mkdir /home/tester/.ssh
    chmod 700 /home/tester/.ssh
    touch /home/tester/.ssh/known_hosts && chmod 644 /home/tester/.ssh/known_hosts
    touch /home/tester/.ssh/config      && chmod 600 /home/tester/.ssh/config
    chown -R tester:tester /home/tester/.ssh
    ```

    Note you can use ``stat``'s ``%a`` option to see a file's permissions as an octal number, e.g.

    ```shell
    stat -c "%a %n" <filename>
    ```

## Client side configuration

### Install Ansible

Ansible is a tool with which you can do so-called _provisioning_, i.e. automated system administration of remote
machines. We'll use it to set up the GitHub Actions runner.

Install Ansible from Ubuntu's repositories:

```shell
sudo apt install ansible
```

Make sure your Ansible version is 2.9.9 or later with:
```shell
ansible --version
```

(Find more information [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)).

### Install SSH client

To be able to connect to remote machines via SSH, we'll need an SSH client. We'll use OpenSSH. Install it from Ubuntu's
repositories with:

```shell
sudo apt install openssh-client
```

### Generate SSH key pair

Generate a key pair (files ``id_rsa`` and ``id_rsa.pub``) in directory
[``/ubuntu-virtualbox/``](/ubuntu-virtualbox/) using RSA encryption:

**Note: ``id_rsa`` is the private half of the SSH key pair; don't share it with anybody else.**

```shell
cd ubuntu-virtualbox/
ssh-keygen -t rsa -f ./id_rsa -N ''
```

Make sure that the permissions are set correctly:

```shell
chmod 600 id_rsa
chmod 644 id_rsa.pub
```

Note you can use ``stat``'s ``%a`` option to see a file's permissions as an octal number, e.g.

```shell
stat -c "%a %n" <filename>
stat -c "%a %n" `ls -1`
```

### Copy the key pair to the server

Copy the public half of the key pair (i.e. ``id_rsa.pub``) to the server.

```shell
ssh-copy-id -i ./id_rsa.pub -p 2222 tester@127.0.0.1
```

### Test connection with server using ``ssh``

Test if you can SSH into the server using the other half of the key pair (i.e. ``id_rsa``)

```shell
ssh -i ./id_rsa -p 2222 tester@127.0.0.1
```

If you get a ``Host key verification failed`` error, clear the existing key with

```shell
ssh-keygen -R "[127.0.0.1]:2222"
```

and try again.

Log out of the server with

```shell
exit
```

### Troubleshooting SSH

Getting SSH connections to work can be tricky. Check out [this document](/docs/troubleshooting-ssh.md) if you're
experiencing difficulties.

### The inventory file

Ansible uses so-called _inventory_ files to define how to connect to remote machines. The inventory file is typically
called  ``hosts``. The following inventory file is equivalent to the ``ssh`` command line we just used:

```yaml
all:
  hosts:
    ci-server:
      ansible_connection: ssh
      ansible_host: 127.0.0.1
      ansible_port: 2222
      ansible_python_interpreter: /usr/bin/python3
      ansible_ssh_private_key_file: ./id_rsa
      ansible_user: tester
```

This inventory file defines a group ``all`` with just one machine in it, which we labeled ``ci-server``. ``ci-server``
has a bunch of variables that define how to connect to it. For more information on inventory files, read
[Ansible's documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

### The Ansible configuration file

In addition to the inventory file, it's often convenient to use a configuration file. The default filename for this file
is ``ansible.cfg``, and it can be used to specify Ansible's behavior. The configuration option documentation can be
found [here](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#the-configuration-file).

### Test connection with server using ``ansible``

We're about ready to test if we can connect to the server using Ansible. For this we will use the ``ping`` module, and
we'll instruct Ansible to run the module on all hosts as defined in the inventory, as follows:

```shell
ansible all -m ping
```

Which should return:

```text
ci-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Install the runner using the playbook

For more complicated tasks than ``ping``, it's often inconvenient having to put everything on the command line. Instead,
a better option is to create a so-called _playbook_ containing all the steps that you want to include in your
provisioning. The playbook is a YAML file that defines a series of ``tasks``. When creating new tasks, one can start
from scratch, or make use of tasks that have been published by others (see [https://galaxy.ansible.com/](https://galaxy.ansible.com/)).

We're almost ready to use ``ansible-playbook`` to set up a GitHub Runner on your own server, but first we need to
generate an OAuth token, as follows:

1. Make a copy of the template file. We will store your token in the copied file momentarily.

    ```shell
    cp secret.yml.template secret.yml
    ```
1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens) and click the ``Generate new token`` button.
1. Provide your GitHub password when prompted
1. Fill in a description for the token, for example _Token for self-hosted GitHub runners_
1. Enable the ``repo`` scope and all of its checkboxes, like so:

    ![Token permissions](/images/token_permissions.png)

1. Click ``Generate`` at the bottom, and update the value of ``PERSONAL_ACCESS_TOKEN`` in ``secret.yml``. **Don't share the contents of ``secret.yml``.**

Configuring your server such that it can run continuous integration requires 4 pieces of information, for which you will be prompted:

1. Because our playbook requires elevated permissions, the command uses the ``--ask-become-pass`` option to prompt for
the root password. Fill in the password ``password`` to become ``root`` in the server.
1. Fill in the GitHub organization (which might be simply your GitHub user name) and ...
1. ...the repository name for which you want to run workflows on a self-hosted server
1. Specify how you want the runner to show up in the GitHub interface


Now run this command to provision the GitHub Action runner on your server:

```shell
ansible-playbook --ask-become-pass playbook.yml
```

If you now go to GitHub [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/settings/actions](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/settings/actions),
you should see a self-hosted runner with status "Idle":

![Self hosted runner status is Idle](/images/github-self-hosted-runners-status-idle.png)

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
ansible-playbook --ask-become-pass playbook.yml --tags enable
```

### Start the runner

```shell
ansible-playbook --ask-become-pass playbook.yml --tags start
```

### Managing the runner service through the playbook

```shell
ansible-playbook --ask-become-pass playbook.yml --tags start
ansible-playbook --ask-become-pass playbook.yml --tags stop
ansible-playbook --ask-become-pass playbook.yml --tags restart
ansible-playbook --ask-become-pass playbook.yml --tags status
ansible-playbook --ask-become-pass playbook.yml --tags enable
ansible-playbook --ask-become-pass playbook.yml --tags disable
```

Uninstalling the runner

```shell
ansible-playbook --ask-become-pass playbook.yml --tags uninstall
```

### Verify that your newly configured runner is triggered

Add the following simple workflow as ``.github/workflows/self_hosted_ci.yml`` in your repository
[https://github.com/&lt;your organization&gt;/&lt;your repository&gt;](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E):

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

With this workflow in place, new pushes and new pull requests should trigger your self-hosted server.
Try making a change to one of the files in your repository to see if you can trigger running the simple workflow
on your self-hosted server. If successful, the status will change to "Active" while the workflow is running.
You can see a record of past and current GitHub Actions by pointing your browser to
[https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/actions?query=workflow:"Self-hosted+CI+example"](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/actions?query=workflow%3A%22Self-hosted+CI+example%22).

### What's next

Find instructions for provisioning additional functionality [here](/README.md).
