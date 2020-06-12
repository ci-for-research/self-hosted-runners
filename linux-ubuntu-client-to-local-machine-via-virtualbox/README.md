# Linux Ubuntu client to local machine via VirtualBox

Describe general layout of the approach

## Prerequisites

1. Install VirtualBox on the client: https://www.virtualbox.org/wiki/Linux_Downloads
1. Download Ubuntu 18.04.4-desktop image from http://releases.ubuntu.com/18.04/

## Server side configuration

1. Create a new virtual machine in VirtualBox using Ubuntu 18.04.4-desktop as a base image.
1. Configure the VM with at least 2 CPUs.
1. Configure main memory to use 4 GB.
1. Configure video memory to use the maximum of 128 MB.
1. Call the user ``tester``
1. Set the user's password to ``password``
1. Update packages

    ```
    sudo apt update
    sudo apt upgrade
    ```

1. Configure OpenSSH, check permissions on relevant files and directories

    ```
    sudo apt install openssh-client
    chmod go-w /home/tester
    chmod 700 /home/tester/.ssh
    touch /home/tester/.ssh/known_hosts && chmod 644 /home/tester/.ssh/known_hosts
    touch /home/tester/.ssh/config      && chmod 600 /home/tester/.ssh/config
    chown -R tester:tester /home/.ssh
    ```

1. Configure port forwarding

    1. Get the IP address of the VM
        
        ```shell
        sudo apt install net-tools
        ```

        In the VM, open a terminal and type ``ifconfig``. Look for an entry that has an ``inet`` value starting with ``10.`` (mine is ``10.0.2.15``). We will use this value as Guest IP later.

    1. In VirtualBox, change the port forwarding settings, as follows:
        1. Go to menu item ``Machine``
        1. Go to ``Settings``
        1. Go to ``Network``
        1. On tab ``Adaptor 1``, go to ``Advanced``, click on ``Port Forwarding``
        1. Click the ``plus`` icon to add a rule
            1. Under ``protocol`` fill in ``TCP``
            1. Under ``Host IP`` fill in ``127.0.0.1``
            1. Under ``Host Port`` fill in ``2222``
            1. Under ``Guest IP`` fill in the value we got from ``ifconfig``
            1. Under ``Guest Port`` fill in ``22``


## Client side configuration

1. Install Ansible (from PPA; the version you get from the Ubuntu repositories is too old).

    ```shell
    $ sudo apt update
    $ sudo apt install software-properties-common
    $ sudo apt-add-repository --yes --update ppa:ansible/ansible
    $ sudo apt install ansible
    ```

    (Find the source [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)).

1. Install OpenSSH client to be able to connect to remote machines via SSH

    ```shell
    sudo apt install openssh-client
    ```

1. Generate a key pair (files ``id_rsa`` and ``id_rsa.pub``) in directory ``linux-ubuntu-client-to-local-machine-via-virtualbox`` using RSA encryption:

    ```shell
    cd linux-ubuntu-client-to-local-machine-via-virtualbox
    ssh-keygen -t rsa -f id_rsa -N ''
    ```

1. Copy the public half of the key pair (i.e. ``id_rsa.pub``) to the server

    ```shell
    ssh-copy-id -i id_rsa.pub -p 2222 tester@127.0.0.1
    ```

1. Test if you can SSH into the server

    ```shell
    ssh -i id_rsa -p 2222 tester@127.0.0.1
    ```

1. Test 'hello world' playbook:

    ```
    ansible-playbook --key-file id_rsa --inventory hosts playbook-hello-world.yml
    ```

