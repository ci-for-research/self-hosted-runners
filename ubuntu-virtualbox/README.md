# Linux Ubuntu client to local machine via VirtualBox

Describe general layout of the approach

## TL;DR

1. create a virtual machine with an SSH server
1. enable access to the server via SSH keys
1. ``ansible-playbook --key-file id_rsa --inventory inventory -v playbook-set-up-runner.yml``

## Prerequisites

1. Install VirtualBox on the client: https://www.virtualbox.org/wiki/Linux_Downloads
1. Download an Ubuntu iso image from https://ubuntu.com/#download. Both the desktop and the server variant are
suitable --choose whichever you're comfortable with.

## Server side configuration

1. Create a new virtual machine in VirtualBox, accepting the wizard's default settings.
1. For the new virtual machine, go to _Settings_ > _Storage_, then under _IDE controller_ select the item marked _Empty_. Then click the icon to load something into the virtual optical disk, then select the Ubuntu iso file.
1. For the new virtual machine, go to _Settings_ > _Network_, select the _Adapter 1_ tab, then use the _Attached to_ dropdown menu to select _Bridged Adapter_.
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
    chown -R tester:tester /home/.ssh
    ```

    Note you can use ``stat``'s ``%a`` option to see a file's permissions as an octal number, e.g.

    ```shell
    stat -c "%a %n" <filename>
    stat -c "%a %n" `ls -1`
    ```

1. Get the IP address of the VM

    ```shell
    sudo apt install net-tools
    ```

    In the VM, open a terminal and type ``ifconfig``. Look for an entry that has an ``inet`` key. Mine says ``192.168.1.73``.

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

1. Generate a key pair (files ``id_rsa`` and ``id_rsa.pub``) in directory [``ubuntu-virtualbox``](/ubuntu-virtualbox) using RSA encryption:

    ```shell
    cd ubuntu-virtualbox
    ssh-keygen -t rsa -f id_rsa -N ''
    ```

1. Copy the public half of the key pair (i.e. ``id_rsa.pub``) to the server using the ``ifconfig`` IP address (see above).

    ```shell
    ssh-copy-id -i id_rsa.pub -p 22 tester@192.168.1.73
    ```

1. Test if you can SSH into the server

    ```shell
    ssh -i id_rsa -p 22 tester@192.168.1.73
    ```

1. Log out of the server with

    ```shell
    exit
    ```

1. Update ``inventory`` with the IP address of the server. Here are the complete contents of my ``inventory``:

    ```shell
    192.168.1.73:22
    ```

1. Test 'hello ansible' playbook:

    ```
    ansible-playbook --key-file id_rsa --inventory inventory playbook-hello-ansible.yml
    ```

1. Test playbook that needs sudo permissions:

    ```
    ansible-playbook --key-file id_rsa --inventory inventory --ask-become-pass playbook-install-nano.yml
    ```

1. Use ``ansible-playbook``'s verbosity flag ``-v`` to see the directory listing result:

    ```
    ansible-playbook --key-file id_rsa --inventory inventory --ask-become-pass -v playbook-install-nano.yml
    ```

1. Sometimes, the Ansible output can be a bit difficult to read. You can enable pretty-printing Ansible's stdout by
   creating a configuration file, ``ansible.cfg`` in the current directory, with the ``stdout_callback`` option.

    ```
    [defaults]
    # Use a callback plugin to pretty print standard out.
    stdout_callback = yaml
    ```

1. We're almost ready to use ``ansible-playbook`` to set up a GitHub Runner on your own server, but first we need to generate a token, as follows:

    1. On GitHub, go to https://github.com/<org>/<repo>/settings/actions/add-new-runner
    1. Copy the token (see section _Configure_)

    Now, configure your server to be able to run continuous integration with the command below. Fill in your GitHub organization (or your name), your repository name, and the token when prompted:

    ```
    ansible-playbook --key-file id_rsa --inventory inventory -v playbook-set-up-runner.yml
    ```
