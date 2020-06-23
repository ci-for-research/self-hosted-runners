# Linux Ubuntu client to local machine via VirtualBox

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine runs the tests. This document describes the case where the server is a virtual machine, running on your own
physical machine. For guides on how to configure alternative setups, go [here](/README.md).

## TL;DR

1. create a virtual machine with an SSH server
1. enable access to the server via SSH keys
1. ``ansible-playbook --key-file id_rsa --inventory hosts -v playbook-set-up-runner.yml``

## Prerequisites

1. Install VirtualBox on the client: https://www.virtualbox.org/wiki/Linux_Downloads
1. Download an Ubuntu iso image from https://ubuntu.com/#download. Both the desktop and the server variant are
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

    ```
    sudo apt update
    sudo apt upgrade
    ```

1. Configure an SSH server (OpenSSH) for remote connection; check permissions on relevant files and directories:

    ```
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

1. Install Ansible (from PPA; the version you get from the Ubuntu repositories is too old).

    ```shell
    $ sudo apt update
    $ sudo apt install software-properties-common
    $ sudo apt-add-repository --yes --update ppa:ansible/ansible
    $ sudo apt install ansible
    ```

    (Find more information [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)).

1. Install OpenSSH client to be able to connect to remote machines via SSH

    ```shell
    sudo apt install openssh-client
    ```

1. Generate a key pair (files ``id_rsa`` and ``id_rsa.pub``) in directory [``ubuntu-virtualbox``](/ubuntu-virtualbox) using RSA encryption:

    **Note: ``id_rsa`` is the private half of the SSH key pair; don't share it with anybody else.**

    ```shell
    cd ubuntu-virtualbox
    ssh-keygen -t rsa -f id_rsa -N ''
    ```

    Make sure that the permissions are set correctly:

    ```
    chmod 600 id_rsa
    chmod 644 id_rsa.pub
    ```

    Note you can use ``stat``'s ``%a`` option to see a file's permissions as an octal number, e.g.

    ```shell
    stat -c "%a %n" <filename>
    stat -c "%a %n" `ls -1`
    ```


1. Copy the public half of the key pair (i.e. ``id_rsa.pub``) to the server.

    ```shell
    ssh-copy-id -i id_rsa.pub -p 2222 tester@127.0.0.1
    ```

1. Test if you can SSH into the server using the other half of the key pair (i.e. ``id_rsa``)

    ```shell
    ssh -i id_rsa -p 2222 tester@127.0.0.1
    ```

1. Log out of the server with

    ```shell
    exit
    ```

1. Update ``hosts`` with the IP address of the server. Here are the complete contents of my ``hosts``:

    ```shell
    127.0.0.1:2222
    ```

1. Test 'hello ansible' playbook:

    ```
    ansible-playbook --key-file id_rsa --inventory hosts playbook-hello-ansible.yml
    ```

1. Test playbook that needs sudo permissions:

    ```
    ansible-playbook --key-file id_rsa --inventory hosts --ask-become-pass playbook-install-nano.yml
    ```

1. Use ``ansible-playbook``'s verbosity flag ``-v`` to see the directory listing result:

    ```
    ansible-playbook --key-file id_rsa --inventory hosts --ask-become-pass -v playbook-install-nano.yml
    ```

1. Sometimes, the Ansible output can be a bit difficult to read. You can enable pretty-printing Ansible's stdout by
   creating a configuration file, ``ansible.cfg`` in the current directory, with the ``stdout_callback`` option.

    ```
    [defaults]
    # Use a callback plugin to pretty print standard out.
    stdout_callback = yaml
    ```

1. We're almost ready to use ``ansible-playbook`` to set up a GitHub Runner on your own server, but first we need to generate a token, as follows:

    1. On GitHub, go to [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/settings/actions/add-new-runner](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/settings/actions/add-new-runner)
    1. Copy the token (see section _Configure_). It should look something like ``ABCY2KDLTSPUY687UH7IJEK65OBKE`` and is valid for an hour.

    Now, configure your server to be able to run continuous integration with the command below. Fill in the password
    ``password`` to become sudo in the server when asked. Next, fill in the GitHub organization (which might be simply
    your GitHub user name) and the repository name for which you want to run workflows on a self-hosted server, as well
    as the token when prompted:

    ```
    ansible-playbook --key-file id_rsa --inventory hosts --ask-become-pass -v playbook-set-up-runner.yml
    ```

    If you now go to GitHub [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/settings/actions](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/settings/actions),
    you should see a self-hosted runner with status "Idle".

    Add the following simple workflow as ``.github/workflows/self_hosted_ci.yml`` in your repository:

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

    Now try making a change to one of the files in your repository to see if you can trigger running the simple workflow
    on your self-hosted server. If successful, the status will change to "Active" while the workflow is running. You can
    get an overview of previous GitHub actions by navigating to [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/actions](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/actions).
