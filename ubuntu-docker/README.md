# Setting up a CI server for a GitHub Action runner with Docker from Linux Ubuntu

After following this guide, you'll have a simple GitHub action workflow on a GitHub repository of your choice. When new commits are made to your repository, the workflow delegates work to a server which runs in a [Docker](https://www.docker.com/) container. You can follow these instructions on your own computer or a Linux server.

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is a Docker container running on your own machine.

For guides on how to configure other features in addition to just the runner, go [here](/README.md).

## Prerequisites

1. Install Docker: https://docs.docker.com/engine/install/
2. Follow post-installation steps https://docs.docker.com/engine/install/linux-postinstall/

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

## Server side configuration

E.g. how to configure VirtualBox, how to run docker container, how to configure HPC cloud machine

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

## Client side configuration


### Run the server

#### Temporary mode

The command below will run the docker image and setup the runner. When user presses `CTRL+C`, it automatically removes the runner from GitHub and removes the Docker container as well.

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

The command below will start the Docker container in daemon mode. The Docker container will run in the background and the terminal will be available. To stop the running container you need to run stop command which explained in [](#cleanup) section.

```shell
docker run -d --restart always --name ga-runner \
    -e PERSONAL_ACCESS_TOKEN="<personal access token>" \
    -e RUNNER_NAME="<runner name to appear on Github>" \
    -e RUNNER_WORKDIR="/tmp/actions-runner-repo" \
    -e GITHUB_ORG="<organization or username>" \
    -e GITHUB_REPO="<name of the repository>" \
    ga-runner:latest
```

### Get Docker container details

Use `docker inspect` to display details of the container
```shell
> docker inspect  ga-runner

[
    {
        "Id": "4ff7f37a894e351dc1def53c76959ac30c09083347ada25fcb55dc6687f8d295",
        "Created": "2020-07-02T18:29:53.106234584Z",
        "Path": "/bin/sh",
...
```

You can use the command below to only find out the IP address of the container
```shell
> docker inspect --format '{{ .NetworkSettings.IPAddress }}' ga-runner

172.17.0.2
```

### Accessing Docker container

If you need an access to a shell on running Docker container:

```shell
docker exec -ti ga-runner /bin/bash
```

### Cleanup

To stop the running Docker container:

```shell
docker container stop ga-runner
```

To remove a Docker container

```shell
docker container rm ga-runner
```

To remove a Docker image

```shell
docker image rm ghrunner
```

### Monitoring the runner service's logs

#TODO:

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
