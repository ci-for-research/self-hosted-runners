# Setting up a CI server for a GitHub Action runner with Docker from Linux Ubuntu

After following this guide, you'll have a simple GitHub action workflow on a GitHub repository of your choice. When new commits are made to your repository, the workflow delegates work to a server which runs in a [Docker](https://www.docker.com/) container. You can follow these instructions on your own computer or a Linux server.

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is a Docker container running on your own machine.

For guides on how to configure other features in addition to just the runner, go [here](/README.md).

## Prerequisites

1. Install Docker: https://docs.docker.com/engine/install/
2. Follow post-installation steps https://docs.docker.com/engine/install/linux-postinstall/

## Server side configuration

E.g. how to configure VirtualBox, how to run docker container, how to configure HPC cloud machine

### Testing your Docker setup

Refence: https://docs.docker.com/docker-for-windows/#test-your-installation


1. Open a terminal window (Command Prompt or PowerShell, but not PowerShell ISE).

2. Run docker --version to ensure that you have a supported version of Docker:

```shell
> docker --version

Docker version 19.03.11-ce, build 42e35e61f3
```

3. Pull the hello-world image from Docker Hub and run a container:

```shell
> docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:d58e752213a51785838f9eed2b7a498ffa1cb3aa7f946dda11af39286c3db9a9
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

4. List the hello-world image that was downloaded from Docker Hub:

```shell
> docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        6 months ago        13.3kB
```

5. List the hello-world container (that exited after displaying “Hello from Docker!”):

```shell
> docker container ls --all

CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS                          PORTS               NAMES
1d624a063f22        hello-world         "/hello"            About a minute ago   Exited (0) About a minute ago                       flamboyant_ramanujan
```

### Build image

Now we are ready to build our Docker image. The following command will use [Dockerfile](docker/Dockerfile) in `docker` folder to build the image. It will create a system user, install necassary system packages and dependencies for the runner.

```shell
docker build \
    -t ga-runner \
    --build-arg DOCKER_USER="<username>" \
    --build-arg DOCKER_PASS="<user password>" \
    ./docker
```

You will need to adjust `<username>` and `<user password>` for the normal user which will be added to the Docker image.

### Run the server

#### Temporary mode
```shell
docker run --rm --name ga-runner \
    -e PERSONAL_ACCESS_TOKEN="<personal access token>" \
    -e RUNNER_NAME="<runner name to appear on Github>" \
    -e RUNNER_WORKDIR="/tmp/actions-runner-repo" \
    -e GITHUB_ORG="<organization or username>" \
    -e GITHUB_REPO="<name of the repository>" \
    ga-runner:latest
```

#### Daemon mode

```shell
docker run -d --restart always --name ga-runner \
    -e PERSONAL_ACCESS_TOKEN="<personal access token>" \
    -e RUNNER_NAME="<runner name to appear on Github>" \
    -e RUNNER_WORKDIR="/tmp/actions-runner-repo" \
    -e GITHUB_ORG="<organization or username>" \
    -e GITHUB_REPO="<name of the repository>" \
    ga-runner:latest
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

docker exec -ti test_sshd /bin/bash

### Cleanup

```shell
docker container stop test_sshd
docker container rm test_sshd
docker image rm ghrunner
```




## Client side configuration

### Install Ansible

Ansible is a tool with which you can do so-called _provisioning_, i.e. automated system administration of remote
machines. We'll use it to set up the GitHub Actions runner.

Install Ansible:

- default repositories for the OS if they're available (apt, ndf, apk, homebrew)
- PPA (for Ubuntu)
- PyPI: ``pip install ansible``
- other options see [docs](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#selecting-an-ansible-version-to-install)

Make sure your Ansible version is 2.9.9 or later with:
```shell
ansible --version
```

(Find more information [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)).

### Install SSH Client

e.g.

- sudo apt install openssh-client
- install putty
- homebrew install ssh

### Generate SSH key pair

Generate a key pair (files ``id_rsa`` and ``id_rsa.pub``) in directory
[``something/something``](/somthing/something) using RSA encryption:

**Note: ``id_rsa`` is the private half of the SSH key pair; don't share it with anybody else.**

**e.g.**

```shell
cd something/something/
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


### Copy the key pair to server

Copy the public half of the key pair (i.e. ``id_rsa.pub``) to the server.

**e.g.**

```shell
ssh-copy-id -i id_rsa.pub -p 2222 tester@127.0.0.1
```


### Test connection with server using ``ssh``

Test if you can SSH into the server using the other half of the key pair (i.e. ``id_rsa``)

**e.g.**

```shell
ssh -i id_rsa -p 2222 tester@127.0.0.1
```

Log out of the server with

```shell
exit
```

### Troubleshooting SSH

Getting SSH connections to work can be tricky. Check out [this document](/docs/troubleshooting-ssh.md) if you're
experiencing difficulties.


### Test connection with server


### Install the runner using the playbook

- Get a personal access token from GitHub
- Explain why the playbook asks for REPO, ORG and TOKEN

We're almost ready to use ``ansible-playbook`` to set up a GitHub Runner on your own server, but first we need to
generate a token, as follows:

**TODO**

Now, configure your server to be able to run continuous integration with the command below. Fill in the password
``password`` to become sudo in the server when asked. Next, fill in the GitHub organization (which might be simply
your GitHub user name) and the repository name for which you want to run workflows on a self-hosted server, as well
as the token when prompted:

```shell
ansible-playbook playbook.yml --ask-become-pass -v
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


### Monitoring the runner service's logs

The log of the runner can be viewed with

```shell
ssh -i <keyfile> -p <port> <username>@<hostname>
```

Then

```shell
journalctl -u actions.runner.*
```

### Start the runner

#### Temporary Mode

#### Deamon mode


### Verify that your newly configured runner is triggered

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

With this workflow in place, new pushes and new pull requests should trigger your self-hosted server.
Try making a change to one of the files in your repository to see if you can trigger running the simple workflow
on your self-hosted server. If successful, the status will change to "Active" while the workflow is running.
You can see a record of past and current GitHub Actions by pointing your browser to
https://github.com/ORG/REPO/actions?query=workflow%3A%22Self-hosted+CI+example%22.


### What's next

Find instructions for provisioning additional functionality [here](../README.md).
